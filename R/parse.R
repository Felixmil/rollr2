# Internal notation parser and component validation. Not exported; consumed by
# `roll()` and `roll_distribution()`.

#' Parse a dice-notation string into its components
#'
#' Recognises `NdX`, `NdX+M`, `NdX-M`, and the count-omitted forms `dX`,
#' `dX+M`, `dX-M` (case-insensitive `d`, whitespace-tolerant). A missing
#' leading count defaults to `N = 1` and a missing modifier to `M = 0`.
#'
#' @param notation A length-1 character string, e.g. `"2d20+2"`.
#'
#' @return A list with integer scalars `n` (number of dice), `x` (die size),
#'   and `m` (signed modifier).
#'
#' @keywords internal
#' @noRd
parse_notation <- function(notation) {
  if (!is.character(notation) || length(notation) != 1L || is.na(notation)) {
    abort(
      c(
        "`notation` must be a single non-missing string.",
        i = paste0(
          "Received ",
          class(notation)[1],
          " of length ",
          length(notation),
          "."
        )
      ),
      class = c("rollr2_error_bad_notation", "rollr2_error")
    )
  }

  trimmed <- trimws(notation)

  # Anchored, case-insensitive: optional count, `d`, die size, optional
  # whitespace-tolerant signed modifier. `\\d` forces integer components, so
  # non-integer counts/sizes (e.g. "2.5d6") never match and fail as
  # unparseable rather than through a separate numeric check.
  match <- regmatches(
    trimmed,
    regexec(
      "^(\\d*)[dD](\\d+)\\s*([+-]\\s*\\d+)?$",
      trimmed
    )
  )[[1]]

  if (length(match) == 0L) {
    abort(
      c(
        "`notation` is not valid dice notation.",
        i = paste0("Received ", encodeString(notation, quote = "\""), "."),
        i = "Expected a form like \"2d20+2\", \"4d6\", \"1d8-1\", or \"d20\"."
      ),
      class = c("rollr2_error_bad_notation", "rollr2_error")
    )
  }

  count_str <- match[[2]]
  size_str <- match[[3]]
  modifier_str <- match[[4]]

  n <- if (nzchar(count_str)) as.integer(count_str) else 1L
  x <- as.integer(size_str)
  m <- if (nzchar(modifier_str)) {
    as.integer(gsub("\\s+", "", modifier_str))
  } else {
    0L
  }

  if (n < 1L) {
    abort(
      c(
        "Number of dice must be a positive integer.",
        i = paste0(
          "Received ",
          n,
          " in ",
          encodeString(notation, quote = "\""),
          "."
        )
      ),
      class = c("rollr2_error_bad_count", "rollr2_error")
    )
  }

  if (x < 2L) {
    abort(
      c(
        "Die size must be an integer of at least 2.",
        i = paste0(
          "Received ",
          x,
          " in ",
          encodeString(notation, quote = "\""),
          "."
        )
      ),
      class = c("rollr2_error_bad_die_size", "rollr2_error")
    )
  }

  list(n = n, x = x, m = m)
}
