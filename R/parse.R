# Internal notation parser and component validation. Not exported; consumed by
# `roll()` and `roll_distribution()`.

#' Parse a dice-notation string into its terms
#'
#' A notation is a sum of one or more terms joined by `+` or `-`. A dice term
#' is `NdX`, `NdX+M`, `NdX-M`, or the count-omitted forms `dX`, `dX+M`, `dX-M`
#' (case-insensitive `d`, whitespace-tolerant). A missing leading count
#' defaults to `N = 1` and a missing modifier to `M = 0`.
#'
#' An optional per-die marker may follow the die size, before any keep
#' selector or modifier: either an explode marker or a reroll marker, but not
#' both (they are mutually exclusive within a term). The explode marker is `!`
#' (explode once) or `!!` (explode indefinitely). Under `!` a die that shows
#' its maximum face is rerolled once and the two faces are summed; the extra
#' die does not itself explode. Under `!!` the die keeps rerolling while the
#' maximum recurs, capped at a fixed 100 chained rerolls per die. So `2d6!`,
#' `2d6!!`, `4d6!h3`, and `2d6!+1` are all valid.
#'
#' The reroll marker is `rT` (reroll once) or `rrT` (reroll until above),
#' where `T` is a required integer threshold bounded `1 <= T <= X - 1`. Under
#' `rT` any die showing a value `<= T` is rerolled exactly once and the new
#' value is kept unconditionally (even if it is also `<= T`). Under `rrT` a
#' die showing `<= T` is rerolled repeatedly until it lands strictly above
#' `T`. The `r` marker letter is case-insensitive. So `2d6r1`, `1d20rr1`,
#' `4d6r1h3`, and `2d6r1+2` are all valid; a term carrying both a reroll and
#' an explode marker (for example `2d6!r1`) is not.
#'
#' An optional keep selector may follow the per-die marker, before the
#' modifier: `h`/`l` (case-insensitive) requests keeping only the
#' highest/lowest dice, optionally followed by a keep count `K` (e.g. `2d20h`,
#' `4d6h3`, `3d6l2`). A missing keep count defaults to `K = 1`. Keep selection
#' applies within its own term only; there is no cross-term keep.
#'
#' In the same slot a drop selector discards dice instead of keeping them:
#' `dl`/`dh` (case-insensitive) drops the lowest/highest `K` dice and the
#' shorthand `d` drops the lowest, each with an optional count defaulting to
#' dropping one (e.g. `4d6dl1`, `4d6dh1`, `4d6d1`). Drop is translated here into
#' the equivalent keep selection, so `NdXdlK` becomes `keep = "h"`,
#' `keep_n = N - K` and `NdXdhK` becomes `keep = "l"`, `keep_n = N - K`; the
#' parsed record for a drop notation is identical to its keep equivalent and no
#' new field is added. The drop count `K` must satisfy `1 <= K <= N - 1`. A
#' term carries at most one selector; keep and drop are mutually exclusive.
#'
#' A bare signed integer is a constant term (for example the trailing `+3` in
#' `1d20+1d6+1d4+3`). At least one dice term is required; a notation of only
#' constants (a pure number like `"3"`) is rejected.
#'
#' @param notation A length-1 character string, e.g. `"2d20+2"` or
#'   `"1d20+1d6+3"`.
#'
#' @return A list with a single element `terms`, an ordered list of term
#'   records in the order they appear in the notation. A dice term is
#'   `list(kind = "dice", sign, n, x, m, keep, keep_n, explode, reroll,
#'   reroll_t)` where `sign` is the term's leading sign folded to
#'   `+1L`/`-1L`, `n`/`x` are integer die count and size, `m` the integer
#'   within-term modifier, `keep` the selector direction (`"h"`, `"l"`, or
#'   `NA_character_`), `keep_n` the integer keep count (or `NA_integer_`),
#'   `explode` the explode mode (`"none"`, `"once"`, or `"indef"`), `reroll`
#'   the reroll mode (`"none"`, `"once"` for `rT`, or `"until"` for `rrT`),
#'   and `reroll_t` the integer reroll threshold `T` (or `NA_integer_` when
#'   `reroll` is `"none"`). Explode and reroll are mutually exclusive, so at
#'   most one of `explode` and `reroll` is not `"none"`. A constant term is
#'   `list(kind = "const", value)` where `value` is the signed integer
#'   contribution.
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

  # All parse errors report `parse_notation()` as their origin (not the
  # internal helpers), keeping the error snapshots stable, so the helpers
  # raise against this frame.
  call <- environment()

  tokens <- tokenise_terms(trimmed, notation, call)
  n_terms <- length(tokens)

  terms <- lapply(tokens, function(token) {
    parse_term(token, notation, n_terms, call)
  })

  # FR-2: at least one dice term is required. A pure-constant notation (e.g.
  # "3", or "1+2") never yields a dice term, matching the pre-multi-term
  # behaviour where a bare number failed to parse.
  has_dice <- any(vapply(terms, \(term) term$kind == "dice", logical(1L)))
  if (!has_dice) {
    abort(
      bad_notation_message(notation),
      class = bad_notation_class(),
      call = call
    )
  }

  list(terms = terms)
}

# Internal helpers ----

# Split a trimmed notation into its raw term tokens (each token carrying its
# own leading sign, if any). Rejects malformed joins and unparseable input.
#
# Locked tokeniser rule (resolves the modifier-vs-constant ambiguity): the
# per-term body regex greedily consumes its own optional trailing `[+/-]M` as
# that dice term's within-term modifier `m`, exactly as the single-term parser
# did. So a `+M`/`-M` immediately following a dice term with no modifier yet is
# absorbed as that term's modifier; a second signed integer, or an integer
# following an already-modified term, becomes a standalone constant term.
# Hence `2d20+2` is one dice term (m = 2), `1d6+3` is one dice term (m = 3),
# `2d6+2+1d4` is a modified dice term plus a dice term, and `1d6+3+1` is a
# dice term (m = 3) plus a constant term (+1). Pinned by the parse tests.
tokenise_terms <- function(trimmed, notation, call) {
  # An empty (or whitespace-only) notation is not valid dice notation.
  if (!nzchar(trimmed)) {
    abort(
      bad_notation_message(notation),
      class = bad_notation_class(),
      call = call
    )
  }

  # A dice-term body without anchors: the single-term grammar. It greedily
  # consumes its own optional signed modifier tail, so a `+M`/`-M` directly
  # after the die (and any selector) binds to that term rather than starting a
  # new term. The modifier's digits carry a `(?![0-9dD])` guard so `-1d4` (or
  # `+10d100`) after a die reads as "minus/plus the dice term", not "modifier
  # then a stray die": the guard rejects any backtracked short digit match, so
  # the modifier binds only when its full integer is not the count of a
  # following die.
  # The countless-selector guard `(?:\\d+|(?![+-])|(?=[+-]\\s*\\d*[dD]))` keeps
  # the single-term rejection of a countless selector abutting a bare signed
  # integer (`2d6h-1`, `2d6h+1` stay unparseable, as before) while allowing a
  # `+`/`-` joiner that introduces a new dice term (`2d20h+2d20l`, `2d20h-1d6`)
  # to end the token so the next term is scanned separately.
  # The post-die-size slot accepts at most one per-die marker: either the
  # explode marker (`!`/`!!`) or the reroll marker (`rT`/`rrT`), never both.
  # Because the two markers are alternatives in a single optional group, a term
  # carrying both (`2d6!r1`, `2d6r1!`) matches only the first marker and leaves
  # the second as unconsumed residue, which the whole-string residue check
  # rejects as bad notation. The reroll sub-pattern `[rR]{1,2}\\d+` requires at
  # least one threshold digit, so a bare `r`/`rr` (`2d6r`) fails to match here
  # and is likewise bad notation, and the `{1,2}` bound rejects `rrr` (`2d6rrr1`),
  # mirroring how `!{1,2}` rejects `!!!`.
  # The selector slot accepts either a keep selector (`h`/`l` then the guard)
  # or a drop selector (the drop marker `d`, an optional direction `h`/`l`,
  # then the same guard). Both spellings share the countless guard, so a
  # countless drop selector abutting a bare signed integer (`4d6dl-1`) stays
  # unparseable while a `+`/`-` joiner introducing a new die (`4d6dl+2d6`) ends
  # the token. A term never carries both selectors: the slot matches at most
  # one alternative, so `4d6h3dl1` and `4d6dl1h2` leave residue and are
  # rejected as invalid notation downstream.
  dice_body <- paste0(
    "(?:\\d*)[dD](?:\\d+)",
    "(?:!{1,2}|[rR]{1,2}\\d+)?",
    "(?:[hHlL](?:\\d+|(?![+-])|(?=[+-]\\s*\\d*[dD]))",
    "|[dD](?:[hHlL])?(?:\\d+|(?![+-])|(?=[+-]\\s*\\d*[dD])))?",
    "(?:\\s*[+-]\\s*\\d+(?![0-9dD]))?"
  )
  # A constant-term body: bare digits (its sign is captured separately as the
  # leading joiner).
  const_body <- "\\d+"
  body_pat <- paste0("(?:", dice_body, "|", const_body, ")")

  # The first token may carry an optional leading sign directly on its body.
  # Every token after the first must be introduced by a `+`/`-` joiner, with
  # tolerated whitespace around it (matching the current whitespace tolerance,
  # e.g. `1d20 + 1d6 - 2`). Requiring the joiner rejects space-separated terms
  # with no operator (`1d6 1d6`).
  first_pat <- paste0("^\\s*[+-]?\\s*", body_pat)
  next_pat <- paste0("^\\s*[+-]\\s*", body_pat)

  tokens <- character(0)
  rest <- trimmed
  first <- TRUE

  repeat {
    if (!nzchar(trimws(rest))) {
      break
    }

    pat <- if (first) first_pat else next_pat
    m <- regexpr(pat, rest, perl = TRUE)
    if (m == -1L) {
      # No leading-sign-plus-body token at the current position: a malformed
      # join (`1d6++1d6`), a dangling sign (`+`, `1d6+`), space-separated
      # terms with no joiner, or otherwise unparseable notation.
      abort(
        bad_notation_message(notation),
        class = bad_notation_class(),
        call = call
      )
    }

    matched <- regmatches(rest, m)
    tokens <- c(tokens, trimws(matched))
    rest <- substr(rest, attr(m, "match.length") + 1L, nchar(rest))
    first <- FALSE
  }

  # Any residue that is not whitespace means the scan failed to consume the
  # whole string: a malformed join (`1d6++1d6`), a trailing dangling sign
  # (`1d6+`), or otherwise unparseable notation.
  if (nzchar(trimws(rest))) {
    abort(
      bad_notation_message(notation),
      class = bad_notation_class(),
      call = call
    )
  }

  tokens
}

# Parse one raw term token into a term record. `n_terms` is the number of
# terms in the whole notation, used only to decide whether an error names the
# offending term separately from the full notation (FR-4): for a single-term
# notation the term and the notation are the same string, so the message stays
# byte-identical to the pre-multi-term wording.
parse_term <- function(token, notation, n_terms, call) {
  token <- trimws(token)

  # Strip a leading sign into the term's sign; the remainder is the term body.
  sign <- 1L
  body <- token
  if (grepl("^[+-]", body)) {
    if (startsWith(body, "-")) {
      sign <- -1L
    }
    body <- trimws(sub("^[+-]\\s*", "", body))
  }

  # A constant term: the body is bare digits.
  if (grepl("^\\d+$", body)) {
    return(list(kind = "const", value = sign * as.integer(body)))
  }

  # The per-die marker (capture group 4) is a single alternation of the explode
  # and reroll forms, so a term carries at most one; the keep selector and
  # modifier keep their group indices (5 and 6). The reroll form requires a
  # threshold digit, so a bare `r`/`rr` never matches here.
  match <- regmatches(
    body,
    regexec(
      paste0(
        "^(\\d*)[dD](\\d+)((?:!{1,2})|(?:[rR]{1,2}\\d+))?",
        "((?:[hHlL](?:\\d+|(?![+-])))",
        "|(?:[dD](?:[hHlL])?(?:\\d+|(?![+-]))))?",
        "\\s*([+-]\\s*\\d+)?$"
      ),
      body,
      perl = TRUE
    )
  )[[1]]

  # Should not happen (the tokeniser only emits dice or constant bodies), but
  # guard defensively: an unrecognised body is unparseable notation.
  if (length(match) == 0L) {
    abort(
      bad_notation_message(notation),
      class = bad_notation_class(),
      call = call
    )
  }

  count_str <- match[[2]]
  size_str <- match[[3]]
  marker_str <- match[[4]]
  selector_str <- match[[5]]
  modifier_str <- match[[6]]

  # Per-die marker (capture group 4): either an explode marker (`!`/`!!`) or a
  # reroll marker (`rT`/`rrT`), never both, so exactly one of `explode` and
  # `reroll` can leave its "none" default. A marker-free record only gains the
  # appended `explode = "none"`, `reroll = "none"`, `reroll_t = NA_integer_`
  # defaults.
  explode <- "none"
  reroll <- "none"
  reroll_t <- NA_integer_
  if (nzchar(marker_str)) {
    if (startsWith(marker_str, "!")) {
      explode <- if (marker_str == "!") "once" else "indef"
    } else {
      # Reroll marker: the leading `r`/`rr` run is the mode, the trailing digits
      # the threshold. The threshold is validated (`1 <= T <= X - 1`) below,
      # after the die-size check so `x` is known.
      letters_part <- tolower(sub("[0-9]+$", "", marker_str))
      reroll <- if (letters_part == "r") "once" else "until"
      reroll_t <- as.integer(sub("^[rR]+", "", marker_str))
    }
  }

  n <- if (nzchar(count_str)) as.integer(count_str) else 1L
  x <- as.integer(size_str)
  m <- if (nzchar(modifier_str)) {
    as.integer(gsub("\\s+", "", modifier_str))
  } else {
    0L
  }

  # The term text as it appears in the notation, used to locate the offending
  # term in a validation error.
  term_text <- if (sign == -1L) paste0("-", body) else body

  if (n < 1L) {
    abort(
      c(
        "Number of dice must be a positive integer.",
        i = paste0(
          "Received ",
          n,
          in_clause(term_text, notation, n_terms)
        )
      ),
      class = c("rollr2_error_bad_count", "rollr2_error"),
      call = call
    )
  }

  if (x < 2L) {
    abort(
      c(
        "Die size must be an integer of at least 2.",
        i = paste0(
          "Received ",
          x,
          in_clause(term_text, notation, n_terms)
        )
      ),
      class = c("rollr2_error_bad_die_size", "rollr2_error"),
      call = call
    )
  }

  # Reroll threshold must be `1 <= T <= X - 1` (checked after the die-size
  # check so `x` is known, and before the keep-count check). A threshold of 0
  # or less never fires; a threshold at or above the die size would reroll
  # every face (and never terminate under `rr`). A bare `r`/`rr` with no digit
  # never reaches here (it fails the term regex as bad notation).
  if (reroll != "none" && (reroll_t < 1L || reroll_t > x - 1L)) {
    abort(
      c(
        "Reroll threshold must be between 1 and the die size minus 1.",
        i = paste0(
          "Received threshold ",
          reroll_t,
          " for a ",
          x,
          "-sided die",
          in_clause(term_text, notation, n_terms)
        )
      ),
      class = c("rollr2_error_bad_reroll", "rollr2_error"),
      call = call
    )
  }

  # Selector slot. Absent when the group is empty, in which case both callers
  # sum every die of the term. When present it is either a keep selector
  # (leading `h`/`l`) or a drop selector (leading drop marker `d`). A drop
  # selector is translated here into the equivalent keep fields, so the parsed
  # record for a drop notation is byte-identical to its keep equivalent and no
  # downstream code sees the drop spelling (it survives only in `notation`).
  if (nzchar(selector_str)) {
    selector <- parse_selector(
      selector_str,
      n,
      term_text,
      notation,
      n_terms,
      call
    )
    keep <- selector$keep
    keep_n <- selector$keep_n
  } else {
    keep <- NA_character_
    keep_n <- NA_integer_
  }

  list(
    kind = "dice",
    sign = sign,
    n = n,
    x = x,
    m = m,
    keep = keep,
    keep_n = keep_n,
    explode = explode,
    reroll = reroll,
    reroll_t = reroll_t
  )
}

# Resolve the selector slot of a dice term into the `keep`/`keep_n` fields.
# `selector_str` is the raw selector text the capture regex extracted (never
# empty when this is called), `n` the number of dice in the term. The first
# character tells the two spellings apart: `h`/`l` is a keep selector (its
# meaning and error wording unchanged), `d` is a drop selector, translated into
# the equivalent keep selection so downstream code never sees the drop
# spelling. Returns `list(keep, keep_n)`. Aborts against `call` on an
# out-of-bounds count, so the error origin stays `parse_notation()`.
parse_selector <- function(
  selector_str,
  n,
  term_text,
  notation,
  n_terms,
  call
) {
  lead <- tolower(substr(selector_str, 1L, 1L))

  if (lead != "d") {
    # Keep selector: direction is the leading letter, the remaining digits are
    # the keep count (defaulting to 1). Behaviour and error wording are
    # unchanged from before the drop spelling was added.
    keep <- lead
    count_part <- substr(selector_str, 2L, nchar(selector_str))
    keep_n <- if (nzchar(count_part)) as.integer(count_part) else 1L

    if (keep_n == 0L) {
      abort(
        c(
          "Keep count must be at least 1.",
          i = paste0(
            "Received keep count 0",
            in_clause(term_text, notation, n_terms)
          )
        ),
        class = c("rollr2_error_bad_keep", "rollr2_error"),
        call = call
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
            " dice",
            in_clause(term_text, notation, n_terms)
          )
        ),
        class = c("rollr2_error_bad_keep", "rollr2_error"),
        call = call
      )
    }

    return(list(keep = keep, keep_n = keep_n))
  }

  # Drop selector. Strip the leading drop marker `d`; the next character, if a
  # direction letter, is the drop direction, else the direction defaults to
  # lowest (the shorthand `NdXdK` and the count-omitted `NdXd` both drop the
  # lowest). The remaining digits are the drop count `K`, defaulting to 1.
  rest <- substr(selector_str, 2L, nchar(selector_str))
  direction <- "l"
  if (nzchar(rest) && tolower(substr(rest, 1L, 1L)) %in% c("h", "l")) {
    direction <- tolower(substr(rest, 1L, 1L))
    rest <- substr(rest, 2L, nchar(rest))
  }
  drop_n <- if (nzchar(rest)) as.integer(rest) else 1L

  # Validate on the drop count `K`, not on the derived `keep_n`: the drop bound
  # `1 <= K <= n - 1` (drop at least one, leave at least one) is not identical
  # to the keep bound after translation. `K = 0` derives `keep_n = n`, a valid
  # keep count the keep check would not catch, so it must be rejected here. The
  # `K >= n` end derives `keep_n <= 0` (drop all), which mirrors the keep-zero
  # rejection; both are phrased in drop terms and carry `rollr2_error_bad_keep`.
  if (drop_n < 1L) {
    abort(
      c(
        "Drop count must be at least 1.",
        i = paste0(
          "Received drop count 0",
          in_clause(term_text, notation, n_terms)
        )
      ),
      class = c("rollr2_error_bad_keep", "rollr2_error"),
      call = call
    )
  }

  if (drop_n > n - 1L) {
    abort(
      c(
        "Drop count cannot leave fewer than one die.",
        i = paste0(
          "Received drop count ",
          drop_n,
          " for ",
          n,
          " dice",
          in_clause(term_text, notation, n_terms)
        )
      ),
      class = c("rollr2_error_bad_keep", "rollr2_error"),
      call = call
    )
  }

  # Drop is the inverse of keep: dropping the lowest `K` keeps the highest
  # `n - K`; dropping the highest `K` keeps the lowest `n - K`.
  keep <- if (direction == "l") "h" else "l"
  list(keep = keep, keep_n = n - drop_n)
}

# The `in "<location>"` clause of a per-term validation error (FR-4). For a
# single-term notation the term and the notation are the same string, so the
# clause is ` in "<notation>".`, byte-identical to the pre-multi-term wording.
# For a multi-term notation it names the offending term within the notation:
# ` in term "<term>" of "<notation>".`.
in_clause <- function(term_text, notation, n_terms) {
  if (n_terms > 1L) {
    paste0(
      " in term ",
      encodeString(term_text, quote = "\""),
      " of ",
      encodeString(notation, quote = "\""),
      "."
    )
  } else {
    paste0(" in ", encodeString(notation, quote = "\""), ".")
  }
}

# The shared "not valid dice notation" error body and class, reused by the
# tokeniser and the constant/dice-body guards so every unparseable-input path
# reports identically (and keeps the single-term error snapshots unchanged).
bad_notation_message <- function(notation) {
  c(
    "`notation` is not valid dice notation.",
    i = paste0("Received ", encodeString(notation, quote = "\""), "."),
    i = "Expected a form like \"2d20+2\", \"4d6\", \"1d8-1\", or \"d20\"."
  )
}

bad_notation_class <- function() {
  c("rollr2_error_bad_notation", "rollr2_error")
}
