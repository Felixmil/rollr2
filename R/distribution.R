#' Summarise the outcome distribution of repeated rolls
#'
#' Simulates `n` whole-notation rolls and summarises the distribution of the
#' resulting totals. The distribution is sampled (not computed analytically),
#' so results vary run to run unless a seed is fixed with [set.seed()].
#'
#' @param notation A length-1 character string in the form `NdX`, `NdX+M`,
#'   `NdX-M`, or the count-omitted `dX` variants (case-insensitive `d`,
#'   whitespace-tolerant).
#' @param n Number of whole-notation rolls to simulate. A positive integer.
#'
#' @return A `roll_distribution` object: a list with `counts` (an integer
#'   vector of observed totals, named by outcome value, ordered ascending;
#'   zero-count outcomes are omitted), `range` (the theoretical
#'   `c(min, max)` of a total, `c(N + M, N * X + M)`), `n`, the parsed
#'   components `dice_n`, `x`, `m`, and the original `notation`. Its `print()`
#'   method renders the counts and a text histogram for the console.
#'
#' @examples
#' set.seed(1)
#' roll_distribution("2d6", n = 1000)
#'
#' @export
roll_distribution <- function(notation, n) {
  components <- parse_notation(notation)
  n <- validate_reps(n)

  dice_n <- components$n
  x <- components$x
  m <- components$m

  # Draw all n * dice_n dice at once, shape into an n-by-dice_n matrix, and
  # sum each row. `sample.int(x, ..., replace = TRUE)` is required: without
  # replacement it would error whenever the draw count exceeds x.
  draws <- sample.int(x, size = n * dice_n, replace = TRUE)
  totals <- rowSums(matrix(draws, nrow = n, ncol = dice_n)) + m

  min_total <- dice_n + m
  max_total <- dice_n * x + m

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
      notation = notation
    ),
    class = "roll_distribution"
  )
}

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
