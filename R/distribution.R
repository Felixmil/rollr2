#' Summarise the outcome distribution of repeated rolls
#'
#' Simulates `n` whole-notation rolls and summarises the distribution of the
#' resulting totals. The distribution is sampled (not computed analytically),
#' so results vary run to run unless a seed is fixed with [set.seed()]. A keep
#' selector (`h`/`l`) is applied per simulated roll before summing, so each
#' total reflects the kept dice plus the modifier.
#'
#' @param notation A length-1 character string in the form `NdX`, `NdX+M`,
#'   `NdX-M`, or the count-omitted `dX` variants (case-insensitive `d`,
#'   whitespace-tolerant). An optional keep selector `h`/`l` with an optional
#'   count may follow the die size (e.g. `2d20h`, `4d6h3`), keeping the
#'   highest/lowest `K` dice per roll (defaulting to `K = 1`).
#' @param n Number of whole-notation rolls to simulate. A positive integer.
#'
#' @return A `roll_distribution` object: a list with `counts` (an integer
#'   vector of observed totals, named by outcome value, ordered ascending;
#'   zero-count outcomes are omitted), `range` (the theoretical
#'   `c(min, max)` of a total, `c(K + M, K * X + M)` where `K` is the kept
#'   count, equal to the die count `N` when there is no selector), `n`, the
#'   parsed components `dice_n`, `x`, `m`, `keep`, `keep_n`, and the original
#'   `notation`. Its `print()` method renders the counts and a text histogram
#'   for the console.
#'
#' @examples
#' set.seed(1)
#' roll_distribution("2d6", n = 1000)
#' roll_distribution("4d6h3", n = 1000)
#'
#' @export
roll_distribution <- function(notation, n) {
  components <- parse_notation(notation)
  n <- validate_reps(n)

  dice_n <- components$n
  x <- components$x
  m <- components$m
  keep <- components$keep
  keep_n <- components$keep_n

  # Effective kept count: the selector's `keep_n`, or every die when absent.
  k <- if (is.na(keep)) dice_n else keep_n

  # Draw all n * dice_n dice at once, shaped into an n-by-dice_n matrix.
  # `sample.int(x, ..., replace = TRUE)` is required: without replacement it
  # would error whenever the draw count exceeds x. The draw order is
  # unchanged by the selector, so seeded runs stay reproducible; selection
  # happens afterwards on the fixed matrix.
  draws <- sample.int(x, size = n * dice_n, replace = TRUE)
  rolls <- matrix(draws, nrow = n, ncol = dice_n)

  if (is.na(keep)) {
    totals <- rowSums(rolls) + m
  } else {
    # Sort each row ascending, then sum the kept slice: the top `keep_n`
    # columns for highest, the bottom `keep_n` for lowest. `apply(..., sort)`
    # returns a `dice_n`-by-`n` result when `dice_n >= 2` but collapses to a
    # length-`n` vector when `dice_n == 1`; rebuilding the matrix explicitly
    # (rather than relying on `t()`) keeps the `n`-by-`dice_n` orientation for
    # any `dice_n`, including 1.
    sorted <- matrix(
      apply(rolls, 1L, sort),
      nrow = n,
      ncol = dice_n,
      byrow = TRUE
    )
    cols <- if (keep == "h") {
      seq(dice_n - keep_n + 1L, dice_n)
    } else {
      seq_len(keep_n)
    }
    totals <- rowSums(sorted[, cols, drop = FALSE]) + m
  }

  min_total <- k + m
  max_total <- k * x + m

  binned <- table(factor(totals, levels = seq(min_total, max_total)))
  counts <- as.integer(binned)
  names(counts) <- names(binned)
  counts <- counts[counts > 0L]

  structure(
    list(
      counts = counts,
      range = c(min_total, max_total),
      n = n,
      dice_n = dice_n,
      x = x,
      m = m,
      keep = keep,
      keep_n = keep_n,
      notation = notation
    ),
    class = "roll_distribution"
  )
}

#' @param x A `roll_distribution` object, as returned by `roll_distribution()`.
#' @param ... Ignored, for compatibility with the [print()] and [plot()]
#'   generics.
#' @rdname roll_distribution
#' @export
print.roll_distribution <- function(x, ...) {
  cat("<roll_distribution> ", x$notation, "\n", sep = "")
  cat(
    "Rolls: ",
    x$n,
    "  Possible total range: ",
    x$range[1],
    " to ",
    x$range[2],
    "\n\n",
    sep = ""
  )
  cat(format_histogram(x$counts), sep = "\n")
  cat("\n")
  invisible(x)
}

#' @details
#' `plot()` returns a themed [ggplot2::ggplot()] bar chart of the sampled
#' counts across the notation's theoretical total range. The returned object
#' auto-prints when called at the top level and can be captured and extended
#' with `+`.
#'
#' @rdname roll_distribution
#' @export
plot.roll_distribution <- function(x, ...) {
  bars <- data.frame(
    total = as.integer(names(x$counts)),
    count = as.integer(x$counts)
  )

  ggplot(bars, aes(x = .data$total, y = .data$count)) +
    geom_col(fill = "steelblue") +
    scale_x_continuous(breaks = integer_axis_breaks(x$range)) +
    labs(
      title = paste0("Distribution of totals for ", x$notation),
      subtitle = paste0(
        format(x$n, big.mark = ","),
        " simulated rolls"
      ),
      x = "Total",
      y = "Count"
    ) +
    theme_minimal()
}

# Internal helpers ----

# Reject a repetition count that is not a single positive integer. Returns the
# value coerced to integer on success.
validate_reps <- function(n) {
  ok <- is.numeric(n) &&
    length(n) == 1L &&
    !is.na(n) &&
    n >= 1 &&
    n == as.integer(n)

  if (!ok) {
    abort(
      c(
        "`n` must be a single positive integer.",
        i = paste0(
          "Received ",
          class(n)[1],
          " of length ",
          length(n),
          if (length(n) == 1L && is.numeric(n) && !is.na(n)) {
            paste0(" (value ", n, ")")
          } else {
            ""
          },
          "."
        )
      ),
      class = c("rollr2_error_bad_reps", "rollr2_error")
    )
  }

  as.integer(n)
}

# Exact probability mass function of a notation's total, over its full
# theoretical range. Pure combinatorics: consumes no RNG, so the standing it
# feeds is deterministic for a given (notation, total). Returns a numeric
# vector of probabilities summing to 1, named by outcome total (already
# shifted by the modifier `m`) and ordered ascending over the whole range
# `c(K + m, K * x + m)` where `K` is the kept count. Every outcome in the
# range is present, even with tiny probability, so callers can index the
# range without gaps.
#
# `keep` is the selector direction (`"h"`, `"l"`, or `NA`), `keep_n` the kept
# count, `n` the die count, `x` the die size, `m` the modifier. Absent a
# selector every die is kept (`K = n`).
outcome_pmf <- function(n, x, m, keep, keep_n) {
  k <- if (is.na(keep)) n else keep_n

  # Keep-highest sum counts over the full range k..k*x. Keep-lowest is the
  # face reflection of keep-highest, so compute highest once either way.
  counts <- keep_highest_counts(n, x, k)

  probs <- counts / sum(counts)
  sums <- seq(k, k * x)

  if (!is.na(keep) && keep == "l") {
    # Reflect each kept sum through the range midpoint: a lowest-kept sum s
    # occurs exactly as often as the highest-kept sum k * (x + 1) - s.
    reflected <- k * (x + 1L) - sums
    probs <- probs[order(reflected)]
    sums <- sort(reflected)
  }

  names(probs) <- sums + m
  probs
}

# Total probability mass of outcomes strictly below `total`, as a whole
# percent. This is the percentile-rank reading of "beats P% of outcomes": the
# minimum total reports 0, the maximum reports the mass strictly below it.
# `pmf` is an `outcome_pmf()` result (named by outcome total).
percentile_below <- function(pmf, total) {
  outcomes <- as.integer(names(pmf))
  round(100 * sum(pmf[outcomes < total]))
}

# Integer x-axis breaks that cover a total range without cluttering wide
# ranges. Shared by both plot methods. Bars are always drawn at their true
# integer totals from the data; these breaks only label the axis. For a narrow
# range (e.g. 2..12) `pretty()` returns roughly every meaningful integer; for a
# wide range (e.g. 10..1000 for `10d100`) it returns a handful of round breaks,
# so the axis never gets one label per outcome (EC-2). Rounding and filtering
# to the integers inside the range keeps breaks correct across negative or
# shifted ranges (EC-3). `range` is `c(min, max)`.
integer_axis_breaks <- function(range) {
  candidates <- unique(round(pretty(range)))
  candidates[candidates >= range[1] & candidates <= range[2]]
}

# Keep-highest sum counts for the top `k` of `n` iid dice with faces `1..x`,
# over the full range `k..k*x` (index i holds the count for sum `k - 1 + i`).
# Exact and RNG-free: a dynamic program over faces from `x` down to `1`. State
# is indexed by (dice assigned so far, kept slots filled), each cell a count
# vector over the kept partial sum; at each face it chooses how many of the
# remaining dice show that face (`choose` orderings) and greedily fills up to
# `k` kept slots with it. This avoids enumerating the `x^n` grid, so wide
# notations like `10d100` stay fast.
keep_highest_counts <- function(n, x, k) {
  max_sum <- k * x
  zero_vec <- numeric(max_sum + 1L)

  # state[[a + 1]][[f + 1]]: count vector over kept partial sums (index
  # sum + 1) for `a` dice assigned and `f` kept slots filled. NULL means the
  # (a, f) combination is unreached.
  empty_state <- function() {
    s <- vector("list", n + 1L)
    for (a in 0:n) {
      s[[a + 1L]] <- vector("list", k + 1L)
    }
    s
  }

  state <- empty_state()
  init <- zero_vec
  init[1L] <- 1 # zero dice, zero slots, partial sum 0
  state[[1L]][[1L]] <- init

  for (face in seq(x, 1L)) {
    new_state <- empty_state()
    for (a in 0:n) {
      remaining <- n - a
      for (f in 0:k) {
        vec <- state[[a + 1L]][[f + 1L]]
        if (is.null(vec)) {
          next
        }
        for (cc in 0:remaining) {
          ways <- choose(remaining, cc)
          fill <- min(cc, k - f) # slots this face can still fill
          new_a <- a + cc
          new_f <- f + fill
          shift <- fill * face

          add <- zero_vec
          if (shift == 0L) {
            add <- vec * ways
          } else {
            idx <- seq_len(max_sum + 1L - shift)
            add[idx + shift] <- vec[idx] * ways
          }

          cur <- new_state[[new_a + 1L]][[new_f + 1L]]
          new_state[[new_a + 1L]][[new_f + 1L]] <- if (is.null(cur)) {
            add
          } else {
            cur + add
          }
        }
      }
    }
    state <- new_state
  }

  final <- state[[n + 1L]][[k + 1L]]
  final[seq(k, max_sum) + 1L]
}

# Render counts-per-outcome as a right-aligned label plus a scaled bar. Bars
# are scaled so the largest count fills `width` characters, keeping wide
# ranges or large counts from overflowing the console.
format_histogram <- function(counts, width = 40L) {
  outcomes <- names(counts)
  label_w <- max(nchar(outcomes))
  count_w <- max(nchar(as.character(counts)))
  max_count <- max(counts)

  bar_len <- round(counts / max_count * width)
  # A non-zero count always shows at least one bar character.
  bar_len[counts > 0L & bar_len == 0L] <- 1L

  bars <- strrep("#", bar_len)
  labels <- formatC(outcomes, width = label_w, flag = " ")
  count_labels <- formatC(counts, width = count_w)

  paste0(labels, " | ", bars, " ", count_labels)
}
