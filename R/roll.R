#' Roll dice from notation once
#'
#' Parses a dice-notation string and simulates a single roll. A notation may
#' be a sum of several terms joined by `+`/`-` (for example `1d20+1d6+3`); each
#' dice term draws `N` independent uniform values from `1..X`, keeps the
#' highest/lowest `K` when it carries a selector, and contributes its kept sum
#' plus its own modifier `M`. A `-` before a term subtracts that term's whole
#' contribution. Bare integer terms (constants) are added directly. The grand
#' `total` is the sum of every term's signed contribution.
#'
#' @param notation A length-1 character string. A single dice term is `NdX`,
#'   `NdX+M`, `NdX-M`, or the count-omitted `dX` variants (case-insensitive
#'   `d`, whitespace-tolerant), optionally with a keep selector `h`/`l` and an
#'   optional count after the die size (e.g. `2d20h`, `4d6h3`, `3d6l2`), which
#'   keeps the highest (`h`) or lowest (`l`) `K` dice (defaulting to `K = 1`).
#'   Several such terms, plus bare integer constants, may be joined with `+` or
#'   `-` into one notation (e.g. `1d20+1d6`, `2d20h+2d20l`, `1d20+1d6+1d4+3`);
#'   at least one dice term is required and each keep selector applies within
#'   its own term only. See [roll_distribution()] to summarise many rolls.
#' @param compare A length-1 logical. When `TRUE`, printing the roll also
#'   shows where the total sits within the notation's full theoretical outcome
#'   distribution: a header line stating what percent of outcomes the roll
#'   beats, then a text histogram of the exact outcome probabilities with the
#'   rolled total's bar marked. Defaults to `FALSE`, which prints only the
#'   roll itself. The comparison is computed, not sampled, so a given
#'   (notation, total) pair always reports the same standing.
#'
#' @return A `roll` object: a list with `dice` (integer vector listing every
#'   die rolled, the concatenation of all dice terms in term order), `total`
#'   (integer scalar grand total: the sum of each term's signed contribution),
#'   `kept` (the dice that contribute, the concatenation of each term's kept
#'   dice in term order), `terms` (the per-term breakdown, each element a list
#'   with the term's parsed fields plus its `dice`, `kept`, and `subtotal`),
#'   the original `notation`, and `compare` (the logical flag controlling the
#'   print method). For a single-term notation the parsed components `n`, `x`,
#'   `m`, `keep`, `keep_n` are also present at the top level; they are omitted
#'   for a multi-term notation, where per-term access via `terms` is required.
#'
#' @examples
#' set.seed(1)
#' roll("2d20+2")
#' roll("d6")
#' roll("4d6h3")
#' roll("1d20+1d6+3")
#' roll("2d6", compare = TRUE)
#'
#' @export
roll <- function(notation, compare = FALSE) {
  parsed <- parse_notation(notation)
  compare <- validate_compare(compare)

  # Roll each term left-to-right in term order so that, under a fixed seed,
  # the RNG stream is well-defined and reproducible. Constant terms consume no
  # RNG, keeping the stream identical to a dice-only notation up to that point.
  terms <- lapply(parsed$terms, roll_term)

  total <- sum(vapply(terms, \(term) term$subtotal, integer(1L)))

  # Flat top-level fields (FR-5): `dice` is every die rolled and `kept` is the
  # contributing dice, both concatenated across dice terms in term order.
  # Constant terms have no dice, so they contribute nothing here.
  dice <- unlist(lapply(terms, \(term) term$dice), use.names = FALSE)
  kept <- unlist(lapply(terms, \(term) term$kept), use.names = FALSE)
  if (is.null(dice)) {
    dice <- integer(0)
  }
  if (is.null(kept)) {
    kept <- integer(0)
  }

  obj <- list(
    dice = dice,
    total = total,
    kept = kept,
    terms = terms,
    notation = notation,
    compare = compare
  )

  # For a single-term notation, expose the parsed components at the top level
  # (unchanged from the pre-multi-term object) so existing accessors keep
  # working. They are not meaningful for a multi-term notation and are omitted.
  if (length(parsed$terms) == 1L && parsed$terms[[1L]]$kind == "dice") {
    sole <- parsed$terms[[1L]]
    obj$n <- sole$n
    obj$x <- sole$x
    obj$m <- sole$m
    obj$keep <- sole$keep
    obj$keep_n <- sole$keep_n
  }

  structure(obj, class = "roll")
}

#' @param x A `roll` object, as returned by `roll()`.
#' @param ... Ignored, for compatibility with the [print()] and [plot()]
#'   generics.
#' @rdname roll
#' @export
print.roll <- function(x, ...) {
  cat("<roll> ", x$notation, "\n", sep = "")

  # One `Dice:` line per dice term (and a `Kept:` line for any selector term),
  # in term order, then a single grand `Total:`. Constant terms have no dice
  # and are not listed; they are visible in the notation header and folded into
  # the total. For a single-term notation this reproduces the original
  # three/four-line layout exactly.
  for (term in x$terms) {
    if (term$kind != "dice") {
      next
    }
    cat("Dice:  ", paste(term$dice, collapse = ", "), "\n", sep = "")
    if (!is.na(term$keep)) {
      cat("Kept:  ", paste(term$kept, collapse = ", "), "\n", sep = "")
    }
  }

  cat("Total: ", x$total, "\n", sep = "")

  if (isTRUE(x$compare)) {
    cat("\n")
    cat(comparison_block(x), sep = "\n")
    cat("\n")
  }

  invisible(x)
}

#' @details
#' `plot()` returns a themed [ggplot2::ggplot()] bar chart of the notation's
#' exact theoretical outcome distribution, with the rolled total's bar
#' highlighted and its percentile standing shown in the subtitle. The plot
#' always shows the theoretical distribution and never reads `compare`, which
#' remains a print-only switch. The returned object auto-prints when called at
#' the top level and can be captured and extended with `+`.
#'
#' @rdname roll
#' @export
plot.roll <- function(x, ...) {
  # Same exact-PMF source the print path uses (comparison_block()), so the
  # plotted standing matches the printed one byte for byte. Consumes no RNG.
  pmf <- outcome_pmf(x$n, x$x, x$m, x$keep, x$keep_n)
  percentile <- percentile_below(pmf, x$total)

  totals <- as.integer(names(pmf))
  bars <- data.frame(
    total = totals,
    prob = as.numeric(pmf),
    highlight = totals == x$total
  )

  ggplot(bars, aes(x = .data$total, y = .data$prob, fill = .data$highlight)) +
    geom_col() +
    scale_fill_manual(
      values = c(`FALSE` = "grey70", `TRUE` = "firebrick"),
      guide = "none"
    ) +
    scale_x_continuous(breaks = integer_axis_breaks(range(totals))) +
    labs(
      title = paste0("Outcome distribution for ", x$notation),
      subtitle = paste0(
        "This roll (total ",
        x$total,
        ") beats ",
        percentile,
        "% of outcomes"
      ),
      x = "Total",
      y = "Probability"
    ) +
    theme_minimal()
}

# Internal helpers ----

# Roll one parsed term into a per-term record carrying its `dice`, `kept`, and
# signed `subtotal`, alongside the parsed fields. A constant term draws no dice
# (empty `dice`/`kept`) and contributes its `value`; a dice term draws `n`
# uniform faces, applies its keep selector value-based (no tie-break), and
# contributes `sign * (sum(kept) + m)`.
roll_term <- function(term) {
  if (term$kind == "const") {
    return(list(
      kind = "const",
      value = term$value,
      dice = integer(0),
      kept = integer(0),
      subtotal = term$value
    ))
  }

  dice <- sample.int(term$x, size = term$n, replace = TRUE)

  if (!is.na(term$keep)) {
    sorted <- sort(dice, decreasing = term$keep == "h")
    kept <- sorted[seq_len(term$keep_n)]
  } else {
    kept <- dice
  }

  subtotal <- term$sign * (sum(kept) + term$m)

  list(
    kind = "dice",
    sign = term$sign,
    n = term$n,
    x = term$x,
    m = term$m,
    keep = term$keep,
    keep_n = term$keep_n,
    dice = dice,
    kept = kept,
    subtotal = subtotal
  )
}

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
# from the roll's per-term structure (never persisted on the object) so the
# standing is a pure function of the notation and total. Returns a character
# vector, one line per element, for `cat(sep = "\n")`.
comparison_block <- function(x) {
  pmf <- grand_total_pmf(x$terms)
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
