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
#'
#' @return A `roll` object: a list with `dice` (integer vector of length `N`,
#'   each in `1..X`, listing every die rolled), `total` (integer scalar equal
#'   to the sum of the kept dice plus `M`), `kept` (the kept dice, equal to
#'   `dice` when there is no selector), the parsed components `n`, `x`, `m`,
#'   `keep`, `keep_n`, and the original `notation`.
#'
#' @examples
#' set.seed(1)
#' roll("2d20+2")
#' roll("d6")
#' roll("4d6h3")
#'
#' @export
roll <- function(notation) {
  components <- parse_notation(notation)

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
      notation = notation
    ),
    class = "roll"
  )
}

#' @export
print.roll <- function(x, ...) {
  cat("<roll> ", x$notation, "\n", sep = "")
  cat("Dice:  ", paste(x$dice, collapse = ", "), "\n", sep = "")
  if (!is.na(x$keep)) {
    cat("Kept:  ", paste(x$kept, collapse = ", "), "\n", sep = "")
  }
  cat("Total: ", x$total, "\n", sep = "")
  invisible(x)
}
