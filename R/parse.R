# Internal notation parser and component validation. Not exported; consumed by
# `roll()` and `roll_distribution()`.

#' Parse a dice-notation string into its components
#'
#' Recognises `NdX`, `NdX+M`, `NdX-M`, and the count-omitted forms `dX`,
#' `dX+M`, `dX-M` (case-insensitive `d`, whitespace-tolerant). A missing
#' leading count defaults to `N = 1` and a missing modifier to `M = 0`.
#'
#' An optional keep selector may follow the die size, before the modifier:
#' `h`/`l` (case-insensitive) requests keeping only the highest/lowest dice,
#' optionally followed by a keep count `K` (e.g. `2d20h`, `4d6h3`, `3d6l2`).
#' A missing keep count defaults to `K = 1`.
#'
#' @param notation A length-1 character string, e.g. `"2d20+2"`.
#'
#' @return A list with integer scalars `n` (number of dice), `x` (die size),
#'   and `m` (signed modifier), plus the keep selector: `keep`, a length-1
#'   character (`"h"`, `"l"`, or `NA_character_` when no selector is present),
#'   and `keep_n`, the integer keep count (or `NA_integer_` when absent).
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

  # Anchored, case-insensitive: optional count, `d`, die size, an optional
  # keep selector (`h`/`l` plus an optional integer count), then an optional
  # whitespace-tolerant signed modifier. `\\d` forces integer components, so
  # non-integer counts/sizes (e.g. "2.5d6") and non-integer keep counts (e.g.
  # "2d6h1.5") never match and fail as unparseable. Inside the selector,
  # `(?:\\d+|(?![+-]))` forbids a bare direction letter from abutting a sign,
  # so "2d6h-1" is read as a malformed keep count "-1" (rejected) rather than
  # a countless selector followed by a "-1" modifier; a whitespace-separated
  # modifier ("2d6h -1") is unaffected.
  match <- regmatches(
    trimmed,
    regexec(
      "^(\\d*)[dD](\\d+)([hHlL](?:\\d+|(?![+-])))?\\s*([+-]\\s*\\d+)?$",
      trimmed,
      perl = TRUE
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
  selector_str <- match[[4]]
  modifier_str <- match[[5]]

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

  # Keep selector. Absent when the selector group is empty, in which case
  # both callers sum every die. When present, the direction is the leading
  # letter and the remaining digits are the keep count (defaulting to 1).
  if (nzchar(selector_str)) {
    keep <- tolower(substr(selector_str, 1L, 1L))
    count_part <- substr(selector_str, 2L, nchar(selector_str))
    keep_n <- if (nzchar(count_part)) as.integer(count_part) else 1L

    if (keep_n == 0L) {
      abort(
        c(
          "Keep count must be at least 1.",
          i = paste0(
            "Received keep count 0 in ",
            encodeString(notation, quote = "\""),
            "."
          )
        ),
        class = c("rollr2_error_bad_keep", "rollr2_error")
      )
    }

    if (keep_n > n) {
      abort(
        c(
          "Keep count cannot exceed the number of dice.",
          i = paste0(
            "Received keep count ",
            keep_n,
            " for ",
            n,
            " dice in ",
            encodeString(notation, quote = "\""),
            "."
          )
        ),
        class = c("rollr2_error_bad_keep", "rollr2_error")
      )
    }
  } else {
    keep <- NA_character_
    keep_n <- NA_integer_
  }

  list(n = n, x = x, m = m, keep = keep, keep_n = keep_n)
}
