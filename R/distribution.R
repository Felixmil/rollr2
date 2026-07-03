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
#'   highest/lowest `K` dice per roll (defaulting to `K = 1`). An explode marker
#'   may follow the die size, before any keep selector or modifier: `!` rerolls
#'   a maximum-face die once and sums both faces, `!!` rerolls while the maximum
#'   recurs, capped at 100 chained rerolls per die (e.g. `2d6!`, `2d6!!`,
#'   `4d6!h3`). Sampling is bounded by the same cap so it always terminates;
#'   `roll_distribution()` does not itself warn on the cap. Several such terms,
#'   plus bare integer constants, may be joined with `+` or `-` into one
#'   notation (e.g. `1d20+1d6`, `2d20h+2d20l`); at least one dice term is
#'   required and each keep selector applies within its own term only. A
#'   trailing success comparator (`NdX>=T`, `NdX>T`, `NdX<=T`, `NdX<T` against an
#'   integer target `T`, e.g. `5d10>=8`, `6d6>=5`) turns the whole notation into
#'   a success-counting pool: each simulated roll is then a count of dice that
#'   satisfy the comparator (`0..N`), not a summed total. A success-counting
#'   notation is a single bare dice term with a comparator (no keep selector,
#'   explode marker, modifier, join, or constant).
#' @param n Number of whole-notation rolls to simulate. A positive integer.
#'
#' @return A `roll_distribution` object: a list with `counts` (an integer
#'   vector of observed totals, named by outcome value, ordered ascending;
#'   zero-count outcomes are omitted), `range` (the theoretical `c(min, max)`
#'   of a grand total, the sum across terms of each term's own min/max plus the
#'   signed constants), `n`, `terms` (the parsed per-term breakdown), and the
#'   original `notation`. For a single-term notation the parsed components
#'   `dice_n`, `x`, `m`, `keep`, `keep_n` are also present at the top level;
#'   they are omitted for a multi-term notation. For a success-counting notation
#'   the outcome is a success count rather than a summed total: `range` is the
#'   success-count range `c(0, N)`, `counts` are observed success counts, and
#'   `success` is `TRUE`; a summed-total distribution carries no `success` field.
#'   Its `print()` method renders the counts and a text histogram for the
#'   console.
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

  # A success-counting notation is a single dice term carrying a comparator; its
  # outcome is a success count over `0..N`, not a summed total. A degenerate
  # (always/never-success) pool warns once here, before sampling, then samples
  # the correct clamped outcome.
  success <- is_success_term(parsed$terms[[1L]])
  if (success) {
    sole <- parsed$terms[[1L]]
    warn_degenerate_pool(
      sole$x,
      sole$compare_op,
      sole$compare_target,
      success_p(sole$x, sole$compare_op, sole$compare_target)
    )
  }

  # Simulate n whole-notation rolls: accumulate the length-n vector of grand
  # totals term by term, left-to-right in term order so seeded runs stay
  # reproducible. Constant terms add their value without drawing. For a success
  # notation each accumulated value is a success count.
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

  # Mark a success-counting distribution so the print/plot methods present a
  # success count rather than a summed total. A summed-total object does not
  # gain the field (its absence, tested via `isTRUE()`, means summed total).
  if (success) {
    obj$success <- TRUE
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
  # A success-counting distribution reports a success-count range; a
  # summed-total distribution is byte-identical to before.
  range_label <- if (isTRUE(x$success)) {
    "  Possible success range: "
  } else {
    "  Possible total range: "
  }
  cat(
    "Rolls: ",
    x$n,
    range_label,
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

  # A success-counting distribution names successes on the title and x axis; a
  # summed-total distribution keeps its existing labels byte-for-byte.
  title <- if (isTRUE(x$success)) {
    paste0("Success distribution for ", x$notation)
  } else {
    paste0("Distribution of totals for ", x$notation)
  }
  x_lab <- if (isTRUE(x$success)) "Successes" else "Total"

  ggplot(bars, aes(x = .data$total, y = .data$count)) +
    geom_col(fill = "steelblue") +
    scale_x_continuous(breaks = integer_axis_breaks(x$range)) +
    labs(
      title = title,
      subtitle = paste0(
        format(x$n, big.mark = ","),
        " simulated rolls"
      ),
      x = x_lab,
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
# RNG). A dice term builds an n-by-n_term matrix of per-die totals (a single
# batched draw for a marker-free term, per-die exploded draws otherwise),
# applies its keep selector with the existing sort-and-slice logic, and returns
# `sign * (rowSums(kept) + m)`. The cap bounds the explode chain so sampling
# always terminates; `roll_distribution()` does not itself warn on the cap.
term_totals <- function(term, n) {
  if (term$kind == "const") {
    return(rep.int(term$value, n))
  }

  dice_n <- term$n
  x <- term$x
  m <- term$m
  keep <- term$keep
  keep_n <- term$keep_n

  # A success-counting term draws its `n * dice_n` dice with the identical
  # batched `sample.int` the marker-free path uses (so a seeded run matches the
  # equivalent bare `NdX` draw order and count), then counts per-row successes.
  # Success counting consumes no RNG. A success term is single-term with
  # `sign = +1` and no modifier, so the per-row success count is the outcome
  # directly.
  if (is_success_term(term)) {
    draws <- sample.int(x, size = n * dice_n, replace = TRUE)
    rolls <- matrix(draws, nrow = n, ncol = dice_n)
    return(rowSums(success_mask(rolls, term$compare_op, term$compare_target)))
  }

  if (term$explode == "none") {
    # Marker-free: draw all n * dice_n dice at once, shaped into an
    # n-by-dice_n matrix. `sample.int(x, ..., replace = TRUE)` is required:
    # without replacement it would error whenever the draw count exceeds x.
    # Selection happens afterwards on the fixed matrix, so the draw order (and
    # seeded reproducibility) is unchanged by the selector. This keeps the RNG
    # stream byte-identical to the pre-explode behaviour.
    draws <- sample.int(x, size = n * dice_n, replace = TRUE)
    rolls <- matrix(draws, nrow = n, ncol = dice_n)
  } else {
    # Exploding: fill the per-die-totals matrix by drawing each of the
    # n * dice_n dice with the shared explode primitive (initial then rerolls,
    # capped). The physical faces are not needed for the distribution, only the
    # per-die totals.
    totals <- vapply(
      seq_len(n * dice_n),
      function(i) explode_die(x, term$explode)$total,
      integer(1L)
    )
    rolls <- matrix(totals, nrow = n, ncol = dice_n)
  }

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
# `+` dice term the kept sum ranges `k .. k * per_die_max`, so the contribution
# ranges `k + m .. k * per_die_max + m`; a `-` term negates and swaps those
# ends; a constant is a single point `value`. `k` is the kept count, `n` when
# there is no selector. For an exploding term the low bound is unchanged (the
# unexploded minimum) and the high bound uses the capped per-die maximum:
# `2 * x` for `!`, `(explode_cap + 1) * x` for `!!` (the outcome the capped
# sampler produces, matching the exact PMF's folded tail).
term_bounds <- function(term) {
  if (term$kind == "const") {
    return(c(term$value, term$value))
  }

  # A success-counting term's outcome is a success count over `0..N`, so its
  # bounds are `c(0, N)` regardless of die size, target, or comparator. This is
  # the same range the exact PMF spans and the sampler bins over, so they cannot
  # drift.
  if (is_success_term(term)) {
    return(c(0L, term$n))
  }

  k <- if (is.na(term$keep)) term$n else term$keep_n
  lo <- k + term$m
  hi <- k * explode_per_die_max(term$x, term$explode) + term$m

  if (term$sign == -1L) {
    c(-hi, -lo)
  } else {
    c(lo, hi)
  }
}

# The maximum single-die contribution under an explode mode. `x` for no
# explode, `2 * x` for `!` (a maximum first face forces one reroll: `x + x`),
# and `(explode_cap + 1) * x` for `!!` (the cap outcome the sampler produces
# when a chain is force-stopped after `explode_cap` maximal rerolls: the
# initial max plus `explode_cap` maximal rerolls). Defined once so the sampler
# cap, the `!!` PMF fold target, and the high bound cannot drift.
explode_per_die_max <- function(x, explode) {
  switch(
    explode,
    none = x,
    once = 2L * x,
    indef = (explode_cap + 1L) * x
  )
}

# TRUE when a parsed term is a success-counting term: a dice term carrying a
# non-`NA` comparator. A summed-total term lacks the `compare_op` field
# entirely, so the `is.null()` guard keeps it out of every success branch (and
# its record byte-identical to before). Defined once so every success branch
# tests membership the same way.
is_success_term <- function(term) {
  term$kind == "dice" &&
    !is.null(term$compare_op) &&
    !is.na(term$compare_op)
}

# Emit a single class-tagged warning when a success pool is degenerate: an
# always-success (`p = 1`) or never-success (`p = 0`) target, almost always a
# user mistake (a target off the face range). The result is still returned
# (the correct clamped outcome). Shared by `roll()` and `roll_distribution()`
# so the wording and class cannot drift; parallel to the explode-cap warning.
# No-op for a non-degenerate pool.
warn_degenerate_pool <- function(x, op, target, p) {
  if (p == 1) {
    warn(
      paste0(
        "A success pool with target ",
        target,
        " against d",
        x,
        " ",
        op,
        " can never fail (p = 1)."
      ),
      class = c("rollr2_warning_degenerate_pool", "rollr2_warning")
    )
  } else if (p == 0) {
    warn(
      paste0(
        "A success pool with target ",
        target,
        " against d",
        x,
        " ",
        op,
        " can never succeed (p = 0)."
      ),
      class = c("rollr2_warning_degenerate_pool", "rollr2_warning")
    )
  }
}

# The exact per-die success probability for a die of size `x` under comparator
# `op` against integer target `target`: the fraction of `1..x` faces that
# satisfy the comparator, clamped to `[0, 1]`. Pure and RNG-free. A target
# outside `1..x` clamps to an always-success (`p = 1`) or never-success
# (`p = 0`) pool.
success_p <- function(x, op, target) {
  raw <- switch(
    op,
    ">=" = (x - target + 1L) / x,
    ">" = (x - target) / x,
    "<=" = target / x,
    "<" = (target - 1L) / x
  )
  max(0, min(1, raw))
}

# The per-die success mask: TRUE where a drawn face satisfies comparator `op`
# against integer `target`. Works elementwise on a vector or matrix of faces
# (used both by the single roll and the sampler). This is the actual-face
# count, distinct from `success_p()` (the exact per-die probability).
success_mask <- function(faces, op, target) {
  switch(
    op,
    ">=" = faces >= target,
    ">" = faces > target,
    "<=" = faces <= target,
    "<" = faces < target
  )
}

# The exact success-count PMF of a pool of `n` iid dice each succeeding with
# probability `p`: Binomial(n, p) over `0..n`, a named numeric vector (names the
# integer success counts, ascending, summing to 1). Finite by construction, so
# no truncation is needed. The success-count analogue of `term_weights()` /
# `outcome_pmf()`.
success_pmf <- function(n, p) {
  probs <- dbinom(0:n, n, p)
  names(probs) <- 0:n
  probs
}

# Exact probability mass function of a whole notation's grand total, over its
# full theoretical range. Pure combinatorics: consumes no RNG, so the standing
# it feeds is deterministic for a given (notation, total). Convolves each dice
# term's exact per-term weight vector, shifts by the term modifiers, and folds
# in the constant terms; never enumerates the joint dice space, so wide
# notations stay fast. Returns a numeric vector of probabilities summing to 1,
# named by grand-total outcome and ordered ascending over the whole range, with
# every outcome present (even at zero probability) so callers can index the
# range without gaps.
#
# Each dice term is reduced to a `(weights, low endpoint)` pair by
# `term_weights()`: a count vector for a marker-free term (byte-identical to
# the pre-explode behaviour) or a finite depth-capped probability vector for an
# exploding term (`term_weights()` normalizes an exploding term to sum to 1).
# The convolution primitive is agnostic to counts versus probabilities, so both
# paths compose the same way and the final normalization keeps the sum-to-1
# invariant.
#
# `terms` is the parsed term list (each dice term carries `sign`, `n`, `x`,
# `m`, `keep`, `keep_n`, `explode`; each constant carries `value`).
grand_total_pmf <- function(terms) {
  # A success-counting notation is always a single dice term carrying a
  # comparator; its outcome is a success count over `0..N`, distributed exactly
  # as Binomial(N, p). Return that PMF directly (RNG-free, finite, sums to 1),
  # so every PMF-consuming surface reads the success-count distribution from the
  # same single source of truth. A summed-total term lacks `compare_op` and
  # takes the convolution path below unchanged.
  sole <- terms[[1L]]
  if (is_success_term(sole)) {
    p <- success_p(sole$x, sole$compare_op, sole$compare_target)
    return(success_pmf(sole$n, p))
  }

  # Running distribution as a weight vector with an integer `offset`: index i
  # (1-based) holds the weight of grand-total `offset + i - 1`. Start from
  # "sum 0 with weight 1".
  counts <- 1
  offset <- 0L

  for (term in terms) {
    if (term$kind == "const") {
      offset <- offset + term$value
      next
    }

    # Per-term weight vector over the kept-dice sum `lo .. lo + length - 1`
    # (before modifier and sign), keyed so index 1 is sum `lo`.
    tw <- term_weights(term)
    tc <- tw$weights
    lo <- tw$lo
    hi <- lo + length(tc) - 1L
    term_offset <- lo + term$m # the outcome for the first entry of `tc`

    if (term$sign == -1L) {
      # Negating a term reverses its weight vector (the largest kept sum becomes
      # the smallest contribution) and negates its outcome range.
      tc <- rev(tc)
      term_offset <- -(hi + term$m)
    }

    # Convolve the running weight vector with this term's. `stats::convolve(...,
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

# A term's exact pre-sign, pre-modifier kept-sum distribution as a
# `list(weights, lo)`: `weights[i]` is the probability (or, for a marker-free
# term, the integer count) of kept sum `lo + i - 1`. This is the single
# convolution primitive `grand_total_pmf()` combines. Branching on `explode`
# keeps the marker-free path a count vector over `k..k*x` (byte-identical to
# the pre-explode behaviour) and routes an exploding term through the
# order-statistic machinery over its per-die distribution.
term_weights <- function(term) {
  n <- term$n
  x <- term$x
  keep <- term$keep
  keep_n <- term$keep_n
  k <- if (is.na(keep)) n else keep_n

  if (term$explode == "none") {
    return(list(weights = term_counts(n, x, keep, keep_n), lo = k))
  }

  probs <- explode_kept_sum_probs(n, x, term$explode, keep, keep_n)
  list(weights = probs, lo = k)
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

# The exact probability distribution of a single exploding die's contribution,
# as a dense probability vector over the contiguous integer support
# `1 .. explode_per_die_max(x, explode)` (index i is outcome i). Finite,
# non-negative, sums to 1.
#
# `!` (explode once): P(f) = 1/x for f in 1..x-1, P(x) = 0 (a maximum first
# face forces a reroll, so a total of exactly x is impossible), and
# P(x + g) = 1/x^2 for g in 1..x (outcomes x+1..2x). Sums to
# (x-1)/x + x/x^2 = 1.
#
# `!!` (explode indefinitely) truncated at `explode_cap`: a chain of j maximal
# faces (j in 0..explode_cap-1) then a non-maximum face f in 1..x-1 contributes
# j*x + f with probability x^-(j+1). The residual mass beyond the cap is folded
# into the single largest enumerated outcome `explode_per_die_max`, the outcome
# the capped sampler produces, so the vector sums to 1 and matches the sampler
# by construction. The residual is order x^-100, below float resolution, so the
# truncation is numerically invisible yet finite. The folded residual is
# clamped at zero: summing ~explode_cap probability terms accumulates
# floating-point round-off whose sign is platform-dependent (the same reason
# the FFT-based `conv_open` comment documents), so `1 - sum(probs)` can land a
# few ULPs below zero on some platforms. Clamping removes only that sub-epsilon
# noise (never any genuine mass) so a negative probability cannot escape into
# the exact PMF downstream.
explode_die_probs <- function(x, explode) {
  per_die_max <- explode_per_die_max(x, explode)
  probs <- numeric(per_die_max)

  if (explode == "once") {
    probs[seq_len(x - 1L)] <- 1 / x
    # probs[x] stays 0 (the forced-reroll gap).
    probs[(x + 1L):(2L * x)] <- 1 / x^2
    return(probs)
  }

  # explode == "indef".
  for (j in 0:(explode_cap - 1L)) {
    base <- j * x
    faces <- seq_len(x - 1L)
    probs[base + faces] <- 1 / x^(j + 1L)
  }
  # Fold the residual tail into the cap outcome so the vector sums to 1 and
  # equals the sampler's force-stopped total. Clamp at zero so a
  # platform-dependent round-off overshoot in `sum(probs)` (a few ULPs above 1)
  # cannot turn the residual negative; the true residual is order x^-100, so
  # clamping only removes sub-epsilon noise, never genuine mass.
  probs[per_die_max] <- max(0, 1 - sum(probs))
  probs
}

# The exact kept-sum distribution of a term of `n` iid exploding dice under a
# keep selector, as a probability vector over the contiguous kept-sum range
# `k .. k * per_die_max` (index 1 is sum k). Composes the single-die
# distribution from `explode_die_probs()`: an N-fold convolution when every die
# is kept, or an order-statistic dynamic program over the per-die support when
# a selector keeps the top/bottom K. Polynomial in n, x, and the cap; never
# enumerates the joint dice space.
explode_kept_sum_probs <- function(n, x, explode, keep, keep_n) {
  die <- explode_die_probs(x, explode)
  k <- if (is.na(keep)) n else keep_n

  if (is.na(keep)) {
    # No selector: the n-fold convolution of the single-die distribution. The
    # single-die support starts at 1, so the n-fold sum starts at n.
    acc <- die
    if (n >= 2L) {
      for (i in seq_len(n - 1L)) {
        acc <- convolve(acc, rev(die), type = "open")
      }
    }
    return(acc)
  }

  probs <- order_stat_kept_probs(die, n, keep_n, keep)
  probs
}

# Exact single-term probability mass function over its full range, named by
# outcome total (shifted by the modifier `m`). Retained as the single-term
# view of `term_weights()`; `grand_total_pmf()` reduces to this for a lone dice
# term with no constant, for both marker-free and exploding terms.
#
# `keep` is the selector direction (`"h"`, `"l"`, or `NA`), `keep_n` the kept
# count, `n` the die count, `x` the die size, `m` the modifier, `explode` the
# explode mode (defaulting to `"none"`). Absent a selector every die is kept
# (`K = n`). The range is sourced from the term's weight vector so it is
# correct for the capped exploding support, not only the uniform `k..k*x`.
outcome_pmf <- function(n, x, m, keep, keep_n, explode = "none") {
  term <- list(
    kind = "dice",
    sign = 1L,
    n = n,
    x = x,
    m = m,
    keep = keep,
    keep_n = keep_n,
    explode = explode
  )
  tw <- term_weights(term)
  weights <- tw$weights
  lo <- tw$lo

  probs <- weights / sum(weights)
  names(probs) <- seq(lo, lo + length(weights) - 1L) + m
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

# Exact kept-sum probability vector for the top/bottom `keep_n` of `n` iid dice
# drawn from an arbitrary per-die distribution `die` (`die[v]` is the
# probability of outcome value `v`, over support `1..length(die)`), returned
# over the kept-sum range `keep_n .. keep_n * length(die)` (index i is sum
# `keep_n - 1 + i`). This generalizes `keep_highest_counts()` from uniform
# integer counts to an arbitrary per-die distribution: the same
# (dice assigned, kept slots filled) dynamic program, but each value `v`
# contributes `choose(remaining, cc) * die[v]^cc` (the multinomial probability
# of `cc` dice showing `v`) instead of a pure `choose` count. Keep-highest
# processes values from largest to smallest; keep-lowest from smallest to
# largest (a direct traversal, not the uniform-support reversal trick, which
# does not hold for the skewed exploding distribution). Polynomial in n, the
# support size, keep_n, and the kept-sum span.
order_stat_kept_probs <- function(die, n, keep_n, keep) {
  v_max <- length(die)
  k <- keep_n
  max_sum <- k * v_max
  zero_vec <- numeric(max_sum + 1L)

  # Process values in the order that fills kept slots with the extreme first:
  # descending for keep-highest, ascending for keep-lowest.
  value_order <- if (keep == "h") seq(v_max, 1L) else seq_len(v_max)

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

  for (value in value_order) {
    p_v <- die[value]
    new_state <- empty_state()
    for (a in 0:n) {
      remaining <- n - a
      for (f in 0:k) {
        vec <- state[[a + 1L]][[f + 1L]]
        if (is.null(vec)) {
          next
        }
        for (cc in 0:remaining) {
          # Multinomial weight for `cc` of the remaining dice showing `value`.
          # p_v^0 == 1 keeps a zero-probability value (e.g. value x under `!`)
          # contributing only through the cc = 0 branch, as required.
          weight <- choose(remaining, cc) * p_v^cc
          if (weight == 0) {
            next
          }
          fill <- min(cc, k - f) # kept slots this value can still fill
          new_a <- a + cc
          new_f <- f + fill
          shift <- fill * value

          add <- zero_vec
          if (shift == 0L) {
            add <- vec * weight
          } else {
            idx <- seq_len(max_sum + 1L - shift)
            add[idx + shift] <- vec[idx] * weight
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
