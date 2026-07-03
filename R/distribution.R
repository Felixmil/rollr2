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
#'   highest/lowest `K` dice per roll (defaulting to `K = 1`). A per-die marker
#'   may follow the die size, before any keep selector or modifier: either an
#'   explode marker or a reroll marker, but not both (they are mutually
#'   exclusive within a term). The explode marker is `!` (rerolls a
#'   maximum-face die once and sums both faces) or `!!` (rerolls while the
#'   maximum recurs, capped at 100 chained rerolls per die), e.g. `2d6!`,
#'   `2d6!!`, `4d6!h3`; sampling is bounded by the same cap so it always
#'   terminates, and `roll_distribution()` does not itself warn on the cap. The
#'   reroll marker is `rT` (rerolls any die showing `<= T` once and keeps the
#'   new value) or `rrT` (rerolls a die showing `<= T` until it lands strictly
#'   above `T`), where the threshold `T` is required and bounded
#'   `1 <= T <= X - 1`, e.g. `2d6r1`, `1d20rr1`, `4d6r1h3`. Several such terms,
#'   plus bare integer constants, may be joined with `+` or `-` into one
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
#'   `dice_n`, `x`, `m`, `keep`, `keep_n`, `reroll`, `reroll_t` are also
#'   present at the top level; they are omitted for a multi-term notation. Its
#'   `print()` method renders the counts and a text histogram for the console.
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
    obj$reroll <- sole$reroll
    obj$reroll_t <- sole$reroll_t
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
# RNG). A dice term builds an n-by-n_term matrix of per-die totals (a single
# batched draw for a marker-free term, per-die exploded or rerolled draws
# otherwise), applies its keep selector with the existing sort-and-slice logic,
# and returns `sign * (rowSums(kept) + m)`. The cap bounds the explode chain so
# explode sampling always terminates; the reroll chain terminates almost surely
# without a cap. `roll_distribution()` does not itself warn on the cap.
term_totals <- function(term, n) {
  if (term$kind == "const") {
    return(rep.int(term$value, n))
  }

  dice_n <- term$n
  x <- term$x
  m <- term$m
  keep <- term$keep
  keep_n <- term$keep_n

  if (term$explode != "none") {
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
  } else if (term$reroll != "none") {
    # Rerolling: fill the per-die-totals matrix by drawing each of the
    # n * dice_n dice with the shared reroll primitive. Mirrors `roll_term()`;
    # only the per-die value is needed for the distribution.
    totals <- vapply(
      seq_len(n * dice_n),
      function(i) reroll_die(x, term$reroll, term$reroll_t)$total,
      integer(1L)
    )
    rolls <- matrix(totals, nrow = n, ncol = dice_n)
  } else {
    # Marker-free: draw all n * dice_n dice at once, shaped into an
    # n-by-dice_n matrix. `sample.int(x, ..., replace = TRUE)` is required:
    # without replacement it would error whenever the draw count exceeds x.
    # Selection happens afterwards on the fixed matrix, so the draw order (and
    # seeded reproducibility) is unchanged by the selector. This keeps the RNG
    # stream byte-identical to the pre-marker behaviour.
    draws <- sample.int(x, size = n * dice_n, replace = TRUE)
    rolls <- matrix(draws, nrow = n, ncol = dice_n)
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
# `+` dice term the kept sum ranges `k * per_die_min .. k * per_die_max`, so
# the contribution ranges `k * per_die_min + m .. k * per_die_max + m`; a `-`
# term negates and swaps those ends; a constant is a single point `value`. `k`
# is the kept count, `n` when there is no selector.
#
# The per-die support depends on the marker. A plain die is `1..x`. An
# exploding term keeps the unexploded minimum 1 and uses the capped per-die
# maximum (`2 * x` for `!`, `(explode_cap + 1) * x` for `!!`, the outcome the
# capped sampler produces, matching the exact PMF's folded tail). A reroll-once
# (`rT`) die can still land anywhere in `1..x`, so its bounds match a plain
# die. A reroll-until (`rrT`) die always lands strictly above `T`, so its
# per-die minimum is `T + 1` (its maximum is still `x`).
term_bounds <- function(term) {
  if (term$kind == "const") {
    return(c(term$value, term$value))
  }

  k <- if (is.na(term$keep)) term$n else term$keep_n
  per_die_min <- if (term$reroll == "until") term$reroll_t + 1L else 1L
  per_die_max <- if (term$reroll != "none") {
    term$x
  } else {
    explode_per_die_max(term$x, term$explode)
  }
  lo <- k * per_die_min + term$m
  hi <- k * per_die_max + term$m

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
# `m`, `keep`, `keep_n`, `explode`, `reroll`, `reroll_t`; each constant carries
# `value`).
grand_total_pmf <- function(terms) {
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

    # Convolve the running weight vector with this term's. `conv_open()`
    # multiplies the two as polynomials, giving a vector whose length is the sum
    # of the spans (additive growth), never the product of the dice spaces.
    counts <- conv_open(counts, tc)
    offset <- offset + term_offset
  }

  probs <- clamp_probs(counts / sum(counts))
  names(probs) <- offset + seq_along(probs) - 1L
  probs
}

# Open (polynomial) convolution of two non-negative vectors, with FFT round-off
# clamped away. `stats::convolve()` computes the convolution through the FFT, so
# entries whose exact value is zero (impossible outcomes) come back as tiny
# numbers that may land just below zero, and the sign of that round-off differs
# across platforms. Both inputs here are non-negative (dice counts or
# probabilities), so the true convolution is non-negative; clamping the
# sub-epsilon negatives to zero removes the platform-dependent noise without
# touching any genuine mass.
conv_open <- function(a, b) {
  out <- convolve(a, rev(b), type = "open")
  out[out < 0] <- 0
  out
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
# convolution primitive `grand_total_pmf()` combines. Explode and reroll are
# mutually exclusive, so the marker-free path stays a count vector over
# `k..k*x` (byte-identical to the pre-marker behaviour), an exploding term
# routes through the order-statistic machinery over its explode per-die
# distribution, and a reroll term routes through the same machinery over its
# reroll per-die distribution. For a reroll-until (`rrT`) term the leading
# entries below `k*(T+1)` are exact zeros (the die never lands `<= T`), which
# keeps `lo = k` and the range contiguous, consistent with how
# `grand_total_pmf()` names every outcome in the range.
term_weights <- function(term) {
  n <- term$n
  x <- term$x
  keep <- term$keep
  keep_n <- term$keep_n
  k <- if (is.na(keep)) n else keep_n

  if (term$explode != "none") {
    die <- explode_die_probs(x, term$explode)
    return(list(weights = kept_sum_probs(die, n, keep, keep_n), lo = k))
  }

  if (term$reroll != "none") {
    die <- reroll_die_probs(x, term$reroll, term$reroll_t)
    return(list(weights = kept_sum_probs(die, n, keep, keep_n), lo = k))
  }

  list(weights = term_counts(n, x, keep, keep_n), lo = k)
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
# truncation is numerically invisible yet finite.
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
  # equals the sampler's force-stopped total.
  probs[per_die_max] <- 1 - sum(probs)
  probs
}

# The exact probability distribution of a single reroll die's contribution, as
# a dense probability vector over the support `1..x` (index v is P(value = v)).
# Finite, non-negative, sums to 1. The reroll analogue of
# `explode_die_probs()`, feeding the same kept-sum machinery.
#
# `"once"` (`rT`): the final value `v` arises either from a first draw `> t`
# that stays (probability `1/x` for each `v` in `t+1..x`) or from a first draw
# `<= t` (total probability `t/x`) followed by any second draw landing on `v`
# (probability `1/x`). So the reroll mass `t/x^2` is spread uniformly over all
# `x` faces, on top of the direct `1/x` a face `> t` gets from a surviving
# first draw:
#   P(v) = t/x^2                for v in 1..t   (only the reroll path reaches v)
#   P(v) = 1/x + t/x^2          for v in t+1..x (direct plus reroll path)
# This sums to 1: `t*(t/x^2) + (x-t)*(1/x + t/x^2) = (x-t)/x + t/x = 1`. Note it
# is not uniform: values `<= t` carry less mass than values `> t`.
#
# `"until"` (`rrT`): the die always ends strictly above `t`, uniformly over the
# `x - t` surviving faces (conditioning a uniform draw on `> t` is uniform):
#   P(v) = 0                    for v in 1..t
#   P(v) = 1/(x - t)            for v in t+1..x
# Exact and finite, no cap, no fold. The leading zeros over `1..t` keep the
# vector length `x` so it composes with the order-statistic machinery, which
# indexes values `1..length(die)`.
reroll_die_probs <- function(x, reroll, t) {
  probs <- numeric(x)

  if (reroll == "once") {
    probs[seq_len(t)] <- t / x^2
    probs[(t + 1L):x] <- 1 / x + t / x^2
    return(probs)
  }

  # reroll == "until".
  probs[(t + 1L):x] <- 1 / (x - t)
  probs
}

# The exact kept-sum distribution of a term of `n` iid dice drawn from an
# arbitrary per-die probability vector `die` (`die[v]` is the probability of
# value `v` over support `1..length(die)`), under a keep selector, as a
# probability vector over the contiguous kept-sum range
# `k .. k * length(die)` (index 1 is sum k). This is the shared kept-sum
# primitive for any per-die distribution: the explode path builds `die` from
# `explode_die_probs()`, the reroll path from `reroll_die_probs()`, and both
# then compose it identically. When every die is kept it is the N-fold
# convolution of `die`; when a selector keeps the top/bottom K it is the
# order-statistic dynamic program over `die`. Polynomial in n and the support
# size; never enumerates the joint dice space.
kept_sum_probs <- function(die, n, keep, keep_n) {
  if (is.na(keep)) {
    # No selector: the n-fold convolution of the single-die distribution. The
    # single-die support starts at 1, so the n-fold sum starts at n.
    acc <- die
    if (n >= 2L) {
      for (i in seq_len(n - 1L)) {
        acc <- conv_open(acc, die)
      }
    }
    return(acc)
  }

  order_stat_kept_probs(die, n, keep_n, keep)
}

# Exact single-term probability mass function over its full range, named by
# outcome total (shifted by the modifier `m`). Retained as the single-term
# view of `term_weights()`; `grand_total_pmf()` reduces to this for a lone dice
# term with no constant, for marker-free, exploding, and reroll terms.
#
# `keep` is the selector direction (`"h"`, `"l"`, or `NA`), `keep_n` the kept
# count, `n` the die count, `x` the die size, `m` the modifier, `explode` the
# explode mode (defaulting to `"none"`), `reroll` the reroll mode (defaulting
# to `"none"`), `reroll_t` the reroll threshold (defaulting to `NA_integer_`).
# Absent a selector every die is kept (`K = n`). The range is sourced from the
# term's weight vector so it is correct for the capped exploding support and
# the reroll support, not only the uniform `k..k*x`.
outcome_pmf <- function(
  n,
  x,
  m,
  keep,
  keep_n,
  explode = "none",
  reroll = "none",
  reroll_t = NA_integer_
) {
  term <- list(
    kind = "dice",
    sign = 1L,
    n = n,
    x = x,
    m = m,
    keep = keep,
    keep_n = keep_n,
    explode = explode,
    reroll = reroll,
    reroll_t = reroll_t
  )
  tw <- term_weights(term)
  weights <- tw$weights
  lo <- tw$lo

  probs <- clamp_probs(weights / sum(weights))
  names(probs) <- seq(lo, lo + length(weights) - 1L) + m
  probs
}

# Clamp sub-epsilon negative floating noise in a probability vector to zero.
# The order-statistic and convolution machinery over a per-die vector with a
# leading exact-zero region (a reroll-until `rrT` die never lands `<= T`) can
# leave rounding noise on the order of `.Machine$double.eps` on the impossible
# low outcomes, dipping minutely below zero. Probabilities are non-negative, so
# this restores that invariant. The `-1e-9` threshold is far above the noise
# scale and far below any real mass, so it never masks a genuine value; a
# vector with no such noise (every marker-free and explode term) is unchanged.
clamp_probs <- function(probs) {
  probs[probs < 0 & probs > -1e-9] <- 0
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
