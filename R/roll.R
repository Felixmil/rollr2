#' Roll dice from notation once
#'
#' Parses a dice-notation string and simulates a single roll: `N` independent
#' uniform draws from `1..X`, summed and adjusted by the modifier `M`.
#'
#' @param notation A length-1 character string in the form `NdX`, `NdX+M`,
#'   `NdX-M`, or the count-omitted `dX` variants (case-insensitive `d`,
#'   whitespace-tolerant). See [roll_distribution()] to summarise many rolls.
#'
#' @return A `roll` object: a list with `dice` (integer vector of length `N`,
#'   each in `1..X`), `total` (integer scalar equal to `sum(dice) + M`), the
#'   parsed components `n`, `x`, `m`, and the original `notation`.
#'
#' @examples
#' set.seed(1)
#' roll("2d20+2")
#' roll("d6")
#'
#' @export
roll <- function(notation) {
  components <- parse_notation(notation)

  dice <- sample.int(components$x, size = components$n, replace = TRUE)
  total <- sum(dice) + components$m

  structure(
    list(
      dice = dice,
      total = total,
      n = components$n,
      x = components$x,
      m = components$m,
      notation = notation
    ),
    class = "roll"
  )
}

#' @export
print.roll <- function(x, ...) {
  cat("<roll> ", x$notation, "\n", sep = "")
  cat("Dice:  ", paste(x$dice, collapse = ", "), "\n", sep = "")
  cat("Total: ", x$total, "\n", sep = "")
  invisible(x)
}
