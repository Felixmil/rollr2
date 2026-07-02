#' Summarise the outcome distribution of repeated rolls
#'
#' Simulates `n` whole-notation rolls and summarises the distribution of the
#' resulting totals. The distribution is sampled (not computed analytically),
#' so results vary run to run unless a seed is fixed with [set.seed()]. A
#' notation may be a sum of several terms joined by `+`/`-`; each simulated
#' roll draws every dice term, applies each term's keep selector (`h`/`l`)
#' within that term before summing, and adds the term modifiers and any bare
#' integer constants, so each total is the grand total across all terms.
#'
#' @param notation A length-1 character string. A single dice term is `NdX`,
#'   `NdX+M`, `NdX-M`, or the count-omitted `dX` variants (case-insensitive
#'   `d`, whitespace-tolerant), optionally with a keep selector `h`/`l` and an
#'   optional count after the die size (e.g. `2d20h`, `4d6h3`), keeping the
#'   highest/lowest `K` dice per roll (defaulting to `K = 1`). Several such
#'   terms, plus bare integer constants, may be joined with `+` or `-` into one
#'   notation (e.g. `1d20+1d6`, `2d20h+2d20l`); at least one dice term is
#'   required and each keep selector applies within its own term only.
#' @param n Number of whole-notation rolls to simulate. A positive integer.
#'
#' @return A `roll_distribution` object: a list with `counts` (an integer
#'   vector of observed totals, named by outcome value, ordered ascending;
#'   zero-count outcomes are omitted), `range` (the theoretical `c(min, max)`
#'   of a grand total, the sum across terms of each term's own min/max plus the
#'   signed constants), `n`, `terms` (the parsed per-term breakdown), and the
#'   original `notation`. For a single-term notation the parsed components
#'   `dice_n`, `x`, `m`, `keep`, `keep_n` are also present at the top level;
#'   they are omitted for a multi-term notation. Its `print()` method renders
#'   the counts and a text histogram for the console.
#'
#' @examples
#' set.seed(1)
#' roll_distribution("2d6", n = 1000)
#' roll_distribution("4d6h3", n = 1000)
#' roll_distribution("1d20+1d6", n = 1000)
#'
#' @export
roll_distribution <- function(notation, n) {
  parsed <- parse_notation(notation)
  n <- validate_reps(n)

  # Simulate n whole-notation rolls: accumulate the length-n vector of grand
  # totals term by term, left-to-right in term order so seeded runs stay
  # reproducible. Constant terms add their value without drawing.
  totals <- integer(n)
  for (term in parsed$terms) {
    totals <- totals + term_totals(term, n)
  }

  # Theoretical grand-total range: the sum over terms of each term's own
  # min/max contribution (FR-7, FR-9), from the same signed-contribution
  # bounds the exact PMF uses, so the sampler and the exact range cannot drift.
  bounds <- lapply(parsed$terms, term_bounds)
  min_total <- sum(vapply(bounds, \(b) b[[1L]], integer(1L)))
  max_total <- sum(vapply(bounds, \(b) b[[2L]], integer(1L)))

  binned <- table(factor(totals, levels = seq(min_total, max_total)))
  counts <- as.integer(binned)
  names(counts) <- names(binned)
  counts <- counts[counts > 0L]

  obj <- list(
    counts = counts,
    range = c(min_total, max_total),
    n = n,
    terms = parsed$terms,
    notation = notation
  )

  # For a single-term notation, expose the parsed components at the top level
  # (unchanged from the pre-multi-term object). Omitted for multi-term.
  if (length(parsed$terms) == 1L && parsed$terms[[1L]]$kind == "dice") {
    sole <- parsed$terms[[1L]]
    obj$dice_n <- sole$n
    obj$x <- sole$x
    obj$m <- sole$m
    obj$keep <- sole$keep
    obj$keep_n <- sole$keep_n
  }

  structure(obj, class = "roll_distribution")
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

# The length-n vector of one term's signed contributions across n simulated
# rolls. A constant term contributes its `value` to every roll (drawing no
# RNG). A dice term draws an n-by-n_term matrix, applies its keep selector with
# the existing sort-and-slice logic, and returns `sign * (rowSums(kept) + m)`.
term_totals <- function(term, n) {
  if (term$kind == "const") {
    return(rep.int(term$value, n))
  }

  dice_n <- term$n
  x <- term$x
  m <- term$m
  keep <- term$keep
  keep_n <- term$keep_n

  # Draw all n * dice_n dice at once, shaped into an n-by-dice_n matrix.
  # `sample.int(x, ..., replace = TRUE)` is required: without replacement it
  # would error whenever the draw count exceeds x. Selection happens afterwards
  # on the fixed matrix, so the draw order (and seeded reproducibility) is
  # unchanged by the selector.
  draws <- sample.int(x, size = n * dice_n, replace = TRUE)
  rolls <- matrix(draws, nrow = n, ncol = dice_n)

  if (is.na(keep)) {
    subtotals <- rowSums(rolls) + m
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
    subtotals <- rowSums(sorted[, cols, drop = FALSE]) + m
  }

  term$sign * subtotals
}

# The `c(min, max)` signed contribution of one term, used for the grand-total
# range and (via `grand_total_pmf`) the exact distribution's endpoints. For a
# `+` dice term the kept sum ranges `k..k*x`, so the contribution ranges
# `k + m .. k*x + m`; a `-` term negates and swaps those ends; a constant is a
# single point `value`. `k` is the kept count, `n` when there is no selector.
term_bounds <- function(term) {
  if (term$kind == "const") {
    return(c(term$value, term$value))
  }

  k <- if (is.na(term$keep)) term$n else term$keep_n
  lo <- k + term$m
  hi <- k * term$x + term$m

  if (term$sign == -1L) {
    c(-hi, -lo)
  } else {
    c(lo, hi)
  }
}

# Exact probability mass function of a whole notation's grand total, over its
# full theoretical range. Pure combinatorics: consumes no RNG, so the standing
# it feeds is deterministic for a given (notation, total). Convolves each dice
# term's exact per-term count vector, shifts by the term modifiers, and folds
# in the constant terms; never enumerates the joint dice space, so wide
# notations stay fast. Returns a numeric vector of probabilities summing to 1,
# named by grand-total outcome and ordered ascending over the whole range, with
# every outcome present (even at zero probability) so callers can index the
# range without gaps.
#
# `terms` is the parsed term list (each dice term carries `sign`, `n`, `x`,
# `m`, `keep`, `keep_n`; each constant carries `value`).
grand_total_pmf <- function(terms) {
  # Running distribution as an integer count vector with an integer `offset`:
  # index i (1-based) holds the weight of grand-total `offset + i - 1`. Start
  # from "sum 0 with weight 1".
  counts <- 1
  offset <- 0L

  for (term in terms) {
    if (term$kind == "const") {
      offset <- offset + term$value
      next
    }

    # Per-term count vector over the kept-dice sum `k..k*x` (before modifier
    # and sign), keyed so index 1 is sum `k`.
    tc <- term_counts(term$n, term$x, term$keep, term$keep_n)
    k <- if (is.na(term$keep)) term$n else term$keep_n
    term_offset <- k + term$m # the outcome for the first entry of `tc`

    if (term$sign == -1L) {
      # Negating a term reverses its count vector (the largest kept sum becomes
      # the smallest contribution) and negates its outcome range.
      tc <- rev(tc)
      term_offset <- -(k * term$x + term$m)
    }

    # Convolve the running count vector with this term's. `stats::convolve(...,
    # type = "open")` multiplies the two as polynomials, giving a vector whose
    # length is the sum of the spans (additive growth), never the product of
    # the dice spaces.
    counts <- convolve(counts, rev(tc), type = "open")
    offset <- offset + term_offset
  }

  probs <- counts / sum(counts)
  names(probs) <- offset + seq_along(probs) - 1L
  probs
}

# Total probability mass of outcomes strictly below `total`, as a whole
# percent. This is the percentile-rank reading of "beats P% of outcomes": the
# minimum total reports 0, the maximum reports the mass strictly below it.
# `pmf` is a `grand_total_pmf()` result (named by outcome total).
percentile_below <- function(pmf, total) {
  outcomes <- as.integer(names(pmf))
  round(100 * sum(pmf[outcomes < total]))
}

# Integer x-axis breaks that cover a total range without cluttering wide
# ranges. Shared by both plot methods. Bars are always drawn at their true
# integer totals from the data; these breaks only label the axis. For a narrow
# range (e.g. 2..12) `pretty()` returns roughly every meaningful integer; for a
# wide range (e.g. 10..1000 for `10d100`) it returns a handful of round breaks,
# so the axis never gets one label per outcome. Rounding and filtering to the
# integers inside the range keeps breaks correct across negative or shifted
# ranges. `range` is `c(min, max)`.
integer_axis_breaks <- function(range) {
  candidates <- unique(round(pretty(range)))
  candidates[candidates >= range[1] & candidates <= range[2]]
}

# Per-term kept-sum count vector over the full range `k..k*x` (index i holds
# the count for kept sum `k - 1 + i`), before any modifier or sign. Absent a
# selector every die is kept (`k = n`); a keep-lowest selector is the face
# reflection of keep-highest. This is the convolution primitive that
# `grand_total_pmf()` combines and the single-term shape `outcome_pmf()`
# reuses, so the two cannot diverge.
term_counts <- function(n, x, keep, keep_n) {
  k <- if (is.na(keep)) n else keep_n

  # Keep-highest sum counts over the full range k..k*x. Keep-lowest is the
  # face reflection of keep-highest, so compute highest once either way.
  counts <- keep_highest_counts(n, x, k)

  if (!is.na(keep) && keep == "l") {
    # Reflect each kept sum through the range midpoint: a lowest-kept sum s
    # occurs exactly as often as the highest-kept sum k * (x + 1) - s. The
    # reflection over the symmetric range k..k*x is just reversal.
    counts <- rev(counts)
  }

  counts
}

# Exact single-term probability mass function over its full range, named by
# outcome total (shifted by the modifier `m`). Retained as the single-term
# view of `term_counts()`; `grand_total_pmf()` reduces to this for a lone dice
# term with no constant.
#
# `keep` is the selector direction (`"h"`, `"l"`, or `NA`), `keep_n` the kept
# count, `n` the die count, `x` the die size, `m` the modifier. Absent a
# selector every die is kept (`K = n`).
outcome_pmf <- function(n, x, m, keep, keep_n) {
  k <- if (is.na(keep)) n else keep_n
  counts <- term_counts(n, x, keep, keep_n)

  probs <- counts / sum(counts)
  names(probs) <- seq(k, k * x) + m
  probs
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
