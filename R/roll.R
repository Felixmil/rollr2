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
#'   In the same slot a drop selector `dl`/`dh`/`d` instead discards dice and
#'   sums the rest: `NdXdlK` drops the lowest `K`, `NdXdhK` drops the highest
#'   `K`, and the shorthand `NdXdK` drops the lowest `K`; a missing count drops
#'   one die. Drop is the inverse spelling of keep, so `NdXdlK` is `NdXh(N-K)`
#'   and `NdXdhK` is `NdXl(N-K)`; the conventional D&D roll `4d6dl1` (drop the
#'   lowest of four d6) is `4d6h3`. The drop count `K` must satisfy
#'   `1 <= K <= N - 1` (drop at least one, leave at least one). A per-die marker
#'   may follow the die size, before any keep or drop selector or modifier:
#'   either an explode marker or a reroll marker, but not both (they are
#'   mutually exclusive within a term). The explode marker is `!` (rerolls a
#'   maximum-face die exactly once and sums the two faces; the extra die does
#'   not itself explode) or `!!` (keeps rerolling while the maximum recurs,
#'   capped at 100 chained rerolls per die). So `2d6!`, `2d6!!`, `4d6!h3`, and
#'   `2d6!+1` are all valid. When a `!!` die reaches the cap, `roll()` emits a
#'   warning while still returning a valid roll. The reroll marker is `rT`
#'   (rerolls any die showing `<= T` exactly once and keeps the new value
#'   unconditionally, even if it is also `<= T`) or `rrT` (rerolls a die
#'   showing `<= T` repeatedly until it lands strictly above `T`), where the
#'   threshold `T` is required and bounded `1 <= T <= X - 1`. Contrast the
#'   explode marker: reroll replaces the die's value, it does not sum. So
#'   `2d6r1`, `1d20rr1`, `4d6r1h3`, and `2d6r1+2` are all valid, and reroll
#'   never warns. Several such terms, plus bare integer constants, may be
#'   joined with `+` or `-` into one notation (e.g. `1d20+1d6`, `2d20h+2d20l`,
#'   `1d20+1d6+1d4+3`); at least one dice term is required and each keep or drop
#'   selector applies within its own term only.
#'
#'   A trailing success comparator turns the whole notation into a
#'   success-counting pool: `NdX>=T`, `NdX>T`, `NdX<=T`, or `NdX<T` against an
#'   integer target `T` (e.g. `5d10>=8`, `6d6>=5`). The outcome is then a count
#'   of dice that satisfy the comparator, an integer in `0..N`, not a summed
#'   total. A die succeeds when its face satisfies the comparator against `T`,
#'   with per-die probability `p` equal to the fraction of `1..X` faces that
#'   satisfy it, so the count is exactly Binomial(`N`, `p`). A success-counting
#'   notation is a single bare dice term with a comparator: it takes no keep or
#'   drop selector, explode marker, reroll marker, or modifier, and does not
#'   join with other terms or constants. See [roll_distribution()] to summarise
#'   many rolls.
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
#'   `m`, `keep`, `keep_n`, `explode`, `reroll`, `reroll_t` are also present at
#'   the top level; they are omitted for a multi-term notation, where per-term
#'   access via `terms` is required. For an exploding or reroll term `dice`
#'   still lists every physical die including rerolls in draw order (for a
#'   reroll term, the rerolled-away faces are listed too), and `kept` lists the
#'   kept per-die values. For a success-counting notation the outcome is a
#'   success count, not a summed total: `total` (also `successes`) is the number
#'   of dice that satisfy the comparator (`0..N`), `successful` is the subset of
#'   `dice` that satisfy it, and `success` is `TRUE`; a summed-total roll
#'   carries none of these success fields.
#'
#' @examples
#' set.seed(8)
#' roll("2d20+2")
#' roll("d6")
#' roll("4d6h3")
#' roll("1d20+1d6+3")
#' roll("5d10>=8")
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

  # A `!!` die that hit the reroll cap surfaces a single warning per roll (not
  # per die), making the truncation visible; the roll object is still returned.
  if (any(vapply(terms, \(term) isTRUE(term$capped), logical(1L)))) {
    warn(
      paste0(
        "An exploding die reached the reroll cap of ",
        explode_cap,
        " and its chain was truncated."
      ),
      class = c("rollr2_warning_explode_cap", "rollr2_warning")
    )
  }

  # A success-counting notation is a single dice term carrying a comparator; its
  # outcome is a success count over `0..N`, not a summed total. A degenerate
  # (always/never-success) pool warns once here; the count is still the correct
  # clamped outcome.
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

  # The outcome slot `total` holds the success count for a success notation (the
  # sole term's subtotal is the count) and the summed grand total otherwise.
  # Reusing `total` keeps `comparison_block()`, `percentile_below()`, and
  # `plot.roll()` reading the outcome from one slot; `$success` disambiguates it.
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
    obj$explode <- sole$explode
    obj$reroll <- sole$reroll
    obj$reroll_t <- sole$reroll_t
  }

  # Mark a success-counting roll and expose its detail so the print/plot methods
  # present a success count. A summed-total roll does not gain any of these
  # fields (their absence, tested via `isTRUE()`, means summed total).
  if (success) {
    sole_term <- terms[[1L]]
    obj$success <- TRUE
    obj$successes <- total
    obj$successful <- sole_term$successful
    obj$compare_op <- sole_term$compare_op
    obj$compare_target <- sole_term$compare_target
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

  # A success-counting roll presents a success count, not a summed total: the
  # rolled dice, then a `Successes:` line reporting the count out of N and the
  # comparator against the target. A summed-total roll keeps its existing layout
  # byte-for-byte (the success branch is entered only via `isTRUE(x$success)`).
  if (isTRUE(x$success)) {
    cat("Dice:      ", paste(x$dice, collapse = ", "), "\n", sep = "")
    cat(
      "Successes: ",
      x$successes,
      " of ",
      length(x$dice),
      " (faces ",
      x$compare_op,
      " ",
      x$compare_target,
      ")\n",
      sep = ""
    )

    if (isTRUE(x$compare)) {
      cat("\n")
      cat(comparison_block(x), sep = "\n")
      cat("\n")
    }

    return(invisible(x))
  }

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
  # plotted standing matches the printed one byte for byte. Built from the
  # per-term structure so it works for both single- and multi-term rolls (the
  # flat `$n/$x/...` fields are omitted for multi-term). Consumes no RNG.
  pmf <- grand_total_pmf(x$terms)
  percentile <- percentile_below(pmf, x$total)

  totals <- as.integer(names(pmf))
  bars <- data.frame(
    total = totals,
    prob = as.numeric(pmf),
    highlight = totals == x$total
  )

  # A success-counting roll names successes in the title, subtitle, and x axis;
  # a summed-total roll keeps its existing labels byte-for-byte. The data
  # (PMF over `0..N`) and highlighted bar come from the shared source unchanged.
  if (isTRUE(x$success)) {
    title <- paste0("Success distribution for ", x$notation)
    subtitle <- paste0(
      "This roll (",
      x$total,
      " successes) beats ",
      percentile,
      "% of outcomes"
    )
    x_lab <- "Successes"
  } else {
    title <- paste0("Outcome distribution for ", x$notation)
    subtitle <- paste0(
      "This roll (total ",
      x$total,
      ") beats ",
      percentile,
      "% of outcomes"
    )
    x_lab <- "Total"
  }

  ggplot(bars, aes(x = .data$total, y = .data$prob, fill = .data$highlight)) +
    geom_col() +
    scale_fill_manual(
      values = c(`FALSE` = "grey70", `TRUE` = "firebrick"),
      guide = "none"
    ) +
    scale_x_continuous(breaks = integer_axis_breaks(range(totals))) +
    labs(
      title = title,
      subtitle = subtitle,
      x = x_lab,
      y = "Probability"
    ) +
    theme_minimal()
}

# Internal constants ----

# Maximum chained rerolls for an explode-indefinitely (`!!`) die. A safety
# backstop, not a tuning knob: shared by the sampler (`roll()`,
# `roll_distribution()`) and the exact-PMF truncation so they cannot drift.
explode_cap <- 100L

# Internal helpers ----

# Roll one parsed term into a per-term record carrying its `dice`, `kept`,
# signed `subtotal`, and a `capped` flag, alongside the parsed fields. A
# constant term draws no dice (empty `dice`/`kept`) and contributes its
# `value`. A dice term draws `n` faces (per-die exploded when the explode
# marker is present, or per-die rerolled when the reroll marker is present),
# applies its keep selector value-based (no tie-break) to the per-die totals,
# and contributes `sign * (sum(kept) + m)`. Explode and reroll are mutually
# exclusive, so at most one per-die branch applies. `capped` is TRUE only when
# some `!!` die in the term hit the reroll cap; reroll never caps.
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

  # A success-counting term draws its `n` dice with the identical batched
  # `sample.int` a bare `NdX` uses (so the RNG stream is byte-identical), then
  # counts the faces that satisfy the comparator. The successful faces are the
  # kept dice, and the success count is the subtotal (a success term is
  # single-term with `sign = +1` and no modifier).
  if (is_success_term(term)) {
    dice <- sample.int(term$x, size = term$n, replace = TRUE)
    mask <- success_mask(dice, term$compare_op, term$compare_target)
    successful <- dice[mask]
    count <- sum(mask)
    return(list(
      kind = "dice",
      sign = term$sign,
      n = term$n,
      x = term$x,
      m = term$m,
      keep = term$keep,
      keep_n = term$keep_n,
      explode = term$explode,
      compare_op = term$compare_op,
      compare_target = term$compare_target,
      dice = dice,
      kept = successful,
      successful = successful,
      subtotal = count,
      capped = FALSE
    ))
  }

  capped <- FALSE
  if (term$explode != "none") {
    # Exploding: draw each die independently, left to right, initial then
    # rerolls. `dice` concatenates every physical face in draw order; the
    # per-die totals feed the keep selector.
    per_die <- lapply(seq_len(term$n), function(i) {
      explode_die(term$x, term$explode)
    })
    dice <- unlist(lapply(per_die, \(d) d$faces), use.names = FALSE)
    per_die_totals <- vapply(per_die, \(d) d$total, integer(1L))
    capped <- any(vapply(per_die, \(d) d$capped, logical(1L)))
  } else if (term$reroll != "none") {
    # Rerolling: draw each die independently, left to right, applying the
    # reroll rule per die. `dice` concatenates every physical face in draw
    # order (including rerolled-away faces); the per-die values feed the keep
    # selector.
    per_die <- lapply(seq_len(term$n), function(i) {
      reroll_die(term$x, term$reroll, term$reroll_t)
    })
    dice <- unlist(lapply(per_die, \(d) d$faces), use.names = FALSE)
    per_die_totals <- vapply(per_die, \(d) d$total, integer(1L))
  } else {
    # Marker-free: draw the whole term in one batched call so the RNG stream is
    # byte-identical to the pre-marker behaviour (no per-die routing).
    dice <- sample.int(term$x, size = term$n, replace = TRUE)
    per_die_totals <- dice
  }

  if (!is.na(term$keep)) {
    sorted <- sort(per_die_totals, decreasing = term$keep == "h")
    kept <- sorted[seq_len(term$keep_n)]
  } else {
    kept <- per_die_totals
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
    explode = term$explode,
    reroll = term$reroll,
    reroll_t = term$reroll_t,
    dice = dice,
    kept = kept,
    subtotal = subtotal,
    capped = capped
  )
}

# Draw one logical die of size `x` under explode mode `explode` ("none",
# "once", "indef"). Returns a list with `faces` (the physical faces drawn, in
# draw order, including any rerolls), `total` (their sum, the die's
# contribution), and `capped` (TRUE only when an `"indef"` chain was
# force-stopped at `explode_cap` rerolls with the final reroll still showing
# the maximum face). `"none"` and `"once"` never set `capped`; a `"once"` die
# makes at most two physical rolls (the extra never re-explodes).
explode_die <- function(x, explode) {
  first <- sample.int(x, size = 1L)

  if (explode == "none" || first != x) {
    return(list(faces = first, total = first, capped = FALSE))
  }

  if (explode == "once") {
    extra <- sample.int(x, size = 1L)
    faces <- c(first, extra)
    return(list(faces = faces, total = sum(faces), capped = FALSE))
  }

  # explode == "indef": keep rerolling while the max recurs, capped. The
  # initial draw plus up to `explode_cap` rerolls, so at most `explode_cap + 1`
  # physical faces. `capped` is TRUE only when the chain was force-stopped with
  # the final reroll still maximal.
  faces <- first
  capped <- FALSE
  rerolls <- 0L
  repeat {
    extra <- sample.int(x, size = 1L)
    faces <- c(faces, extra)
    rerolls <- rerolls + 1L
    if (extra != x) {
      break
    }
    if (rerolls >= explode_cap) {
      capped <- TRUE
      break
    }
  }
  list(faces = faces, total = sum(faces), capped = capped)
}

# Draw one logical die of size `x` under reroll mode `reroll` ("once" for `rT`,
# "until" for `rrT`) at threshold `t`. Returns the same shape as
# `explode_die()`: `faces` (the physical faces drawn in draw order, including
# any rerolled-away face), `total` (the die's contributing value), and `capped`
# (always FALSE; reroll never caps). Unlike explode, reroll *replaces* the
# die's value rather than summing: the total is the surviving face, not the sum
# of the physical faces.
#
# `"once"`: draw a face; if it is `<= t`, draw one replacement and keep that
# replacement unconditionally (even if it too is `<= t`), otherwise keep the
# first face. At most two physical faces.
#
# `"until"`: draw faces while the last is `<= t`; the value is the first face
# strictly greater than `t`. The chain terminates almost surely because
# `1 <= t <= x - 1` guarantees face `x > t` is always reachable, so no cap is
# needed.
reroll_die <- function(x, reroll, t) {
  first <- sample.int(x, size = 1L)

  if (reroll == "once") {
    if (first <= t) {
      second <- sample.int(x, size = 1L)
      return(list(faces = c(first, second), total = second, capped = FALSE))
    }
    return(list(faces = first, total = first, capped = FALSE))
  }

  # reroll == "until": keep drawing while the latest face is `<= t`.
  faces <- first
  repeat {
    if (faces[length(faces)] > t) {
      break
    }
    faces <- c(faces, sample.int(x, size = 1L))
  }
  list(faces = faces, total = faces[length(faces)], capped = FALSE)
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

  # Mark the bar for the rolled outcome (total, or success count for a success
  # roll). The names are the full ascending range, so the outcome's line is at
  # offset `outcome - range_min`.
  outcomes <- as.integer(names(pmf))
  marked <- match(x$total, outcomes)
  bars[marked] <- paste0(bars[marked], " <- this roll")

  # A success-counting roll names successes in the header; a summed-total roll
  # keeps its existing header.
  header <- if (isTRUE(x$success)) {
    paste0(
      "Success distribution for ",
      x$notation,
      ": this roll (",
      x$total,
      " successes) beats ",
      percentile,
      "% of outcomes"
    )
  } else {
    paste0(
      "Distribution for ",
      x$notation,
      ": this roll beats ",
      percentile,
      "% of outcomes"
    )
  }

  c(header, bars)
}
