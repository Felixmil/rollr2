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
#' @param ... Ignored, for compatibility with the [print()] generic.
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
