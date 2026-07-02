#' Roll dice from notation once
#'
#' Parses a dice-notation string and simulates a single roll: `N` independent
#' uniform draws from `1..X`, summed and adjusted by the modifier `M`. When
#' the notation carries a keep selector (`h`/`l`), only the highest or lowest
#' `K` of the rolled dice contribute to the total; the modifier is still
#' applied once to that kept sum.
#'
#' @param notation A length-1 character string in the form `NdX`, `NdX+M`,
#'   `NdX-M`, or the count-omitted `dX` variants (case-insensitive `d`,
#'   whitespace-tolerant). An optional keep selector `h`/`l` with an optional
#'   count may follow the die size (e.g. `2d20h`, `4d6h3`, `3d6l2`); it keeps
#'   the highest (`h`) or lowest (`l`) `K` dice, defaulting to `K = 1`. See
#'   [roll_distribution()] to summarise many rolls.
#' @param compare A length-1 logical. When `TRUE`, printing the roll also
#'   shows where the total sits within the notation's full theoretical outcome
#'   distribution: a header line stating what percent of outcomes the roll
#'   beats, then a text histogram of the exact outcome probabilities with the
#'   rolled total's bar marked. Defaults to `FALSE`, which prints only the
#'   roll itself. The comparison is computed, not sampled, so a given
#'   (notation, total) pair always reports the same standing.
#'
#' @return A `roll` object: a list with `dice` (integer vector of length `N`,
#'   each in `1..X`, listing every die rolled), `total` (integer scalar equal
#'   to the sum of the kept dice plus `M`), `kept` (the kept dice, equal to
#'   `dice` when there is no selector), the parsed components `n`, `x`, `m`,
#'   `keep`, `keep_n`, the original `notation`, and `compare` (the logical
#'   flag from the argument, controlling the print method).
#'
#' @examples
#' set.seed(1)
#' roll("2d20+2")
#' roll("d6")
#' roll("4d6h3")
#' roll("2d6", compare = TRUE)
#'
#' @export
roll <- function(notation, compare = FALSE) {
  components <- parse_notation(notation)
  compare <- validate_compare(compare)

  dice <- sample.int(components$x, size = components$n, replace = TRUE)

  # A keep selector reduces the summed dice to the highest/lowest `keep_n`.
  # Selection is value-based (sort on values), so equal dice are
  # interchangeable and no tie-break is needed. Absent a selector every die
  # is kept, reproducing the plain sum.
  if (!is.na(components$keep)) {
    sorted <- sort(dice, decreasing = components$keep == "h")
    kept <- sorted[seq_len(components$keep_n)]
  } else {
    kept <- dice
  }

  total <- sum(kept) + components$m

  structure(
    list(
      dice = dice,
      total = total,
      kept = kept,
      n = components$n,
      x = components$x,
      m = components$m,
      keep = components$keep,
      keep_n = components$keep_n,
      notation = notation,
      compare = compare
    ),
    class = "roll"
  )
}

#' @param x A `roll` object, as returned by `roll()`.
#' @param ... Ignored, for compatibility with the [print()] generic.
#' @rdname roll
#' @export
print.roll <- function(x, ...) {
  cat("<roll> ", x$notation, "\n", sep = "")
  cat("Dice:  ", paste(x$dice, collapse = ", "), "\n", sep = "")
  if (!is.na(x$keep)) {
    cat("Kept:  ", paste(x$kept, collapse = ", "), "\n", sep = "")
  }
  cat("Total: ", x$total, "\n", sep = "")

  if (isTRUE(x$compare)) {
    cat("\n")
    cat(comparison_block(x), sep = "\n")
    cat("\n")
  }

  invisible(x)
}

# Internal helpers ----

# Reject a comparison flag that is not a single non-missing logical. Returns
# the value unchanged on success.
validate_compare <- function(compare) {
  ok <- is.logical(compare) && length(compare) == 1L && !is.na(compare)

  if (!ok) {
    abort(
      c(
        "`compare` must be a single non-missing logical.",
        i = paste0(
          "Received ",
          class(compare)[1],
          " of length ",
          length(compare),
          "."
        )
      ),
      class = c("rollr2_error_bad_compare", "rollr2_error")
    )
  }

  compare
}

# Build the comparison block for a roll: a header naming the notation and the
# percentile standing, then the outcome-distribution histogram with the
# rolled total's bar marked. The percentile and histogram are derived here
# from the roll's stored components (never persisted on the object) so the
# standing is a pure function of the notation and total. Returns a character
# vector, one line per element, for `cat(sep = "\n")`.
comparison_block <- function(x) {
  pmf <- outcome_pmf(x$n, x$x, x$m, x$keep, x$keep_n)
  percentile <- percentile_below(pmf, x$total)

  # Scale probabilities to a non-negative integer vector so the existing
  # `format_histogram()` (largest bar fills the width) renders them directly;
  # any outcome with non-zero probability keeps at least one bar character.
  width <- 40L
  scaled <- pmax(round(pmf / max(pmf) * width), as.integer(pmf > 0))
  names(scaled) <- names(pmf)
  bars <- format_histogram(scaled, width = width)

  # Mark the bar for the rolled total. The names are the full ascending range,
  # so the total's line is at offset `total - range_min`.
  outcomes <- as.integer(names(pmf))
  marked <- match(x$total, outcomes)
  bars[marked] <- paste0(bars[marked], " <- this roll")

  header <- paste0(
    "Distribution for ",
    x$notation,
    ": this roll beats ",
    percentile,
    "% of outcomes"
  )

  c(header, bars)
}
