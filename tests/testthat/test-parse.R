# The parser returns an ordered list of term records under `$terms`; each
# record has several fields, so the structural assertions below use
# `expect_snapshot()` rather than a bundle of `expect_equal()` calls.

test_that("parse_notation extracts components from a full NdX+M form", {
  expect_snapshot(parse_notation("2d20+2"))
})

test_that("parse_notation defaults a missing modifier to zero", {
  expect_snapshot(parse_notation("4d6"))
})

test_that("parse_notation handles a negative modifier", {
  expect_snapshot(parse_notation("1d8-1"))
})

test_that("parse_notation defaults a missing count to one", {
  expect_snapshot(parse_notation("d20"))
})

test_that("parse_notation is case-insensitive and whitespace-tolerant", {
  expect_snapshot(parse_notation("2D20 + 2"))
  expect_snapshot(parse_notation(" 2d20 + 2 "))
})

test_that("parse_notation reads keep-highest and keep-lowest selectors", {
  expect_snapshot(parse_notation("2d20h"))
  expect_snapshot(parse_notation("2d20l"))
  expect_snapshot(parse_notation("4d6h3"))
  expect_snapshot(parse_notation("3d6l2"))
})

test_that("a count-omitted die with a selector keeps the single die", {
  expect_snapshot(parse_notation("d20h"))
})

test_that("selectors are case-insensitive and compose with a modifier", {
  expect_snapshot(parse_notation("2D20H"))
  expect_snapshot(parse_notation("4d6h3 + 2"))
})

test_that("a keep count equal to the die count is valid and keeps all", {
  expect_snapshot(parse_notation("3d6h3"))
})

test_that("an invalid keep count is rejected", {
  expect_snapshot(error = TRUE, parse_notation("2d20h0"))
  expect_snapshot(error = TRUE, parse_notation("2d6h5"))
})

test_that("a malformed selector is rejected as invalid notation", {
  expect_snapshot(error = TRUE, parse_notation("2d6h-1"))
  expect_snapshot(error = TRUE, parse_notation("2d6h1.5"))
})

# Explode marker ----

test_that("parse_notation reads the explode-once and explode-indefinitely markers (AC-1)", {
  expect_snapshot(parse_notation("2d6!"))
  expect_snapshot(parse_notation("2d6!!"))
  expect_snapshot(parse_notation("d6!"))
})

test_that("the explode marker composes with a keep selector and a modifier (AC-1)", {
  expect_snapshot(parse_notation("4d6!h3"))
  expect_snapshot(parse_notation("4d6!!l2"))
  expect_snapshot(parse_notation("2d6!+1"))
  expect_snapshot(parse_notation("2d6!!-2"))
})

test_that("the explode marker parses inside a multi-term notation (AC-1)", {
  expect_snapshot(parse_notation("1d20+2d6!"))
  expect_snapshot(parse_notation("2d6!!+1d4"))
})

test_that("a marker after the selector or modifier is rejected (AC-2)", {
  expect_snapshot(error = TRUE, parse_notation("2d6h!"))
  expect_snapshot(error = TRUE, parse_notation("2d6h3!"))
  expect_snapshot(error = TRUE, parse_notation("2d6+1!"))
})

test_that("a stray count after the marker or an over-long marker is rejected (AC-2)", {
  expect_snapshot(error = TRUE, parse_notation("2d6!3"))
  expect_snapshot(error = TRUE, parse_notation("2d6!!!"))
})

test_that("a malformed selector after a valid marker is rejected as its non-explode form does (AC-2)", {
  expect_snapshot(error = TRUE, parse_notation("2d6!h-1"))
  expect_snapshot(error = TRUE, parse_notation("2d6!h1.5"))
})

# Reroll marker ----

test_that("parse_notation reads the reroll-once and reroll-until markers (AC-1)", {
  expect_snapshot(parse_notation("2d6r1"))
  expect_snapshot(parse_notation("1d20rr1"))
  expect_snapshot(parse_notation("d20r1"))
  expect_snapshot(parse_notation("d20rr1"))
})

test_that("the reroll marker letter is case-insensitive (AC-1)", {
  expect_snapshot(parse_notation("2D6R1"))
  expect_snapshot(parse_notation("1d20RR1"))
})

test_that("the reroll marker composes with a keep selector and a modifier (AC-1)", {
  expect_snapshot(parse_notation("4d6r1h3"))
  expect_snapshot(parse_notation("4d6rr1l2"))
  expect_snapshot(parse_notation("2d6r1+2"))
  expect_snapshot(parse_notation("2d6rr1-1"))
  expect_snapshot(parse_notation("4d6r1h3+2"))
})

test_that("the reroll marker parses inside a multi-term notation (AC-1)", {
  expect_snapshot(parse_notation("1d20+2d6r1"))
  expect_snapshot(parse_notation("2d6rr1+1d4"))
  expect_snapshot(parse_notation("2d6r1-1d4"))
})

test_that("a missing reroll threshold is rejected as invalid notation (AC-2)", {
  expect_snapshot(error = TRUE, parse_notation("2d6r"))
  expect_snapshot(error = TRUE, parse_notation("2d6rr"))
})

test_that("a malformed reroll marker is rejected as invalid notation (AC-2)", {
  expect_snapshot(error = TRUE, parse_notation("2d6rrr1"))
  expect_snapshot(error = TRUE, parse_notation("2d6r1.5"))
})

test_that("an out-of-range reroll threshold names the threshold and die size (AC-2)", {
  expect_snapshot(error = TRUE, parse_notation("2d6r0"))
  expect_snapshot(error = TRUE, parse_notation("2d6r6"))
  expect_snapshot(error = TRUE, parse_notation("2d6rr6"))
  expect_snapshot(error = TRUE, parse_notation("1d20rr20"))
  # A multi-term case exercises the ` in term "..." of "..."` phrasing.
  expect_snapshot(error = TRUE, parse_notation("2d6r6+1d4"))
})

test_that("a term carrying both a reroll and an explode marker is rejected (AC-2)", {
  expect_snapshot(error = TRUE, parse_notation("2d6!r1"))
  expect_snapshot(error = TRUE, parse_notation("2d6r1!"))
  expect_snapshot(error = TRUE, parse_notation("2d6rr1!!"))
  expect_snapshot(error = TRUE, parse_notation("2d6!!rr1"))
})

test_that("a reroll marker after the selector or modifier is rejected (AC-2)", {
  expect_snapshot(error = TRUE, parse_notation("2d6h1r1"))
  expect_snapshot(error = TRUE, parse_notation("2d6+1r1"))
})

test_that("a valid threshold reports the keep-count error, not the reroll error (AC-2)", {
  # 4d6r1h5 has a valid threshold (1 <= 1 <= 5) but an invalid keep count
  # (5 > 4), so the keep-count check fires; the reroll check does not.
  expect_snapshot(error = TRUE, parse_notation("4d6r1h5"))
})

test_that("explicit zero modifier equals no modifier", {
  expect_equal(parse_notation("2d6+0"), parse_notation("2d6"))
})

test_that("unparseable notation is rejected", {
  expect_snapshot(error = TRUE, parse_notation("abc"))
  expect_snapshot(error = TRUE, parse_notation("2x20"))
  expect_snapshot(error = TRUE, parse_notation(""))
  expect_snapshot(error = TRUE, parse_notation("2.5d6"))
})

test_that("non-string or non-length-1 input is rejected", {
  expect_snapshot(error = TRUE, parse_notation(character(0)))
  expect_snapshot(error = TRUE, parse_notation(c("2d6", "1d8")))
  expect_snapshot(error = TRUE, parse_notation(206))
  expect_snapshot(error = TRUE, parse_notation(NA_character_))
})

test_that("a die count below one is rejected", {
  expect_snapshot(error = TRUE, parse_notation("0d6"))
})

test_that("a degenerate or invalid die size is rejected", {
  expect_snapshot(error = TRUE, parse_notation("1d1"))
  expect_snapshot(error = TRUE, parse_notation("d0"))
})

# Multi-term notation ----

test_that("parse_notation reads a sum of dice terms plus a constant (AC-1)", {
  expect_snapshot(parse_notation("2d20h+1d6+1"))
  expect_snapshot(parse_notation("2d20h+2d20l"))
  expect_snapshot(parse_notation("1d20+1d6+1d4+3"))
})

test_that("a leading `+M`/`-M` binds as the term modifier under the locked rule", {
  # A bare `+M`/`-M` right after a dice term with no modifier is that term's
  # within-term modifier, not a separate constant; a further signed integer
  # then becomes a standalone constant term.
  expect_snapshot(parse_notation("2d20+2")) # one term, m = 2
  expect_snapshot(parse_notation("1d6+3")) # one term, m = 3
  expect_snapshot(parse_notation("2d6+2+1d4")) # modified dice term + dice term
  expect_snapshot(parse_notation("1d6+3+1")) # dice term (m = 3) + constant
})

test_that("a negated dice term captures a -1 sign", {
  expect_snapshot(parse_notation("2d20h-1d6"))
})

test_that("a leading bare constant is accepted since terms commute", {
  expect_snapshot(parse_notation("3+1d20"))
})

test_that("whitespace-separated terms and signs parse", {
  expect_snapshot(parse_notation("1d20 + 1d6 - 2"))
})

test_that("a repeated identical term is not merged at the object level", {
  # 1d6+1d6 keeps two distinct term records rather than collapsing to 2d6.
  expect_snapshot(parse_notation("1d6+1d6"))
})

test_that("a per-term validation error names the offending term", {
  # The `of "<notation>"` clause appears only for a multi-term notation; a
  # single-term error keeps the pre-multi-term wording.
  expect_snapshot(error = TRUE, parse_notation("2d6h5+1d4"))
  expect_snapshot(error = TRUE, parse_notation("0d6+1d4"))
})

test_that("malformed joins and pure-constant notation are rejected", {
  expect_snapshot(error = TRUE, parse_notation("1d6++1d6"))
  expect_snapshot(error = TRUE, parse_notation("1d6+"))
  expect_snapshot(error = TRUE, parse_notation("+"))
  expect_snapshot(error = TRUE, parse_notation("3"))
  expect_snapshot(error = TRUE, parse_notation("1+2"))
  expect_snapshot(error = TRUE, parse_notation("1d6 1d6"))
})
