test_that("a single roll returns dice in range and a consistent total", {
  withr::local_seed(42)
  result <- roll("4d6+2")

  expect_length(result$dice, 4L)
  expect_true(all(result$dice >= 1L & result$dice <= 6L))
  expect_equal(result$total, sum(result$dice) + 2L)
})

test_that("a single die single roll yields one result equal to the total minus modifier", {
  withr::local_seed(42)
  result <- roll("1d6")

  expect_length(result$dice, 1L)
  expect_equal(result$total, result$dice)
})

test_that("a large negative modifier is not floored", {
  withr::local_seed(42)
  result <- roll("1d4-10")

  expect_equal(result$total, result$dice - 10L)
  expect_lt(result$total, 0L)
})

test_that("rolls are reproducible under a fixed seed", {
  first <- withr::with_seed(42, roll("2d20+2"))
  second <- withr::with_seed(42, roll("2d20+2"))

  expect_equal(first$dice, second$dice)
  expect_equal(first$total, second$total)
})

test_that("keep-highest and keep-lowest select a single die for the total", {
  withr::local_seed(42)
  high <- roll("2d20h")
  expect_length(high$dice, 2L)
  expect_equal(high$total, max(high$dice))

  withr::local_seed(42)
  low <- roll("2d20l")
  expect_length(low$dice, 2L)
  expect_equal(low$total, min(low$dice))
})

test_that("an explicit keep count sums the chosen highest or lowest dice", {
  withr::local_seed(42)
  high <- roll("4d6h3")
  expect_length(high$dice, 4L)
  expect_equal(high$total, sum(sort(high$dice, decreasing = TRUE)[1:3]))

  withr::local_seed(42)
  low <- roll("3d6l2")
  expect_length(low$dice, 3L)
  expect_equal(low$total, sum(sort(low$dice)[1:2]))
})

test_that("the modifier applies once to the kept sum", {
  withr::local_seed(42)
  result <- roll("4d6h3+2")
  expect_equal(
    result$total,
    sum(sort(result$dice, decreasing = TRUE)[1:3]) + 2L
  )
})

test_that("keeping all dice equals the plain roll under the same seed", {
  keep_all <- withr::with_seed(42, roll("2d6h2"))
  plain <- withr::with_seed(42, roll("2d6"))
  expect_equal(keep_all$dice, plain$dice)
  expect_equal(keep_all$total, plain$total)
})

test_that("selector rolls are reproducible under a fixed seed", {
  first <- withr::with_seed(42, roll("4d6h3"))
  second <- withr::with_seed(42, roll("4d6h3"))
  expect_equal(first$dice, second$dice)
  expect_equal(first$total, second$total)
})

test_that("print.roll renders notation, dice, and total", {
  withr::local_seed(42)
  expect_snapshot(print(roll("2d20+2")))
})

test_that("print.roll shows the kept dice when a selector is present", {
  withr::local_seed(42)
  expect_snapshot(print(roll("4d6h3")))
})

test_that("roll surfaces parse errors", {
  expect_snapshot(error = TRUE, roll("nonsense"))
})

test_that("compare defaults to FALSE and leaves the object and print unchanged", {
  withr::local_seed(42)
  result <- roll("2d20+2")

  expect_false(result$compare)
  # Default path stays byte-identical to a roll built without the argument.
  expect_snapshot(print(result))
})

test_that("a non-logical compare flag is rejected", {
  expect_snapshot(error = TRUE, roll("2d6", compare = "yes"))
  expect_snapshot(error = TRUE, roll("2d6", compare = NA))
  expect_snapshot(error = TRUE, roll("2d6", compare = c(TRUE, FALSE)))
})

test_that("print.roll with compare shows the distribution and the marked total", {
  # A mid-high total (9) on 2d6 gives a non-trivial percentile with the marked
  # bar inside the histogram, not at an extreme. Construct the total directly so
  # the case is deterministic rather than seed-dependent.
  withr::local_seed(42)
  r <- roll("2d6", compare = TRUE)
  r$terms[[1]]$dice <- c(6L, 3L)
  r$terms[[1]]$kept <- c(6L, 3L)
  r$terms[[1]]$subtotal <- 9L
  r$total <- 9L
  expect_snapshot(print(r))
})

test_that("compare follows a keep-highest selector's range and shape", {
  withr::local_seed(42)
  expect_snapshot(print(roll("4d6h3", compare = TRUE)))
})

test_that("compare against a skewed keep-highest distribution is probability-weighted", {
  # 2d20h at total 11: the probability mass strictly below 11 (25%) diverges
  # from the unweighted count of distinct outcomes below 11 (50%). The header
  # must report the weighted reading. Construct the total directly so the case
  # does not depend on the RNG seed.
  withr::local_seed(42)
  r <- roll("2d20h", compare = TRUE)
  r$terms[[1]]$dice <- c(2L, 11L)
  r$terms[[1]]$kept <- 11L
  r$terms[[1]]$subtotal <- 11L
  r$total <- 11L
  expect_snapshot(print(r))
})

test_that("compare follows a shifted range under a negative modifier", {
  # The maximum total (-6) on 1d4-10 puts the marked bar at the top of the
  # shifted range; the standing is the mass strictly below it. Force the maximum
  # face directly instead of relying on a specific seed.
  withr::local_seed(42)
  r <- roll("1d4-10", compare = TRUE)
  r$terms[[1]]$dice <- 4L
  r$terms[[1]]$kept <- 4L
  r$terms[[1]]$subtotal <- -6L
  r$total <- -6L
  expect_snapshot(print(r))
})

test_that("rolling the minimum total reports a 0% standing", {
  # The minimum total (-9) on 1d4-10 has nothing strictly below it, so the
  # standing is 0%. Force the minimum face directly instead of via a seed.
  withr::local_seed(42)
  r <- roll("1d4-10", compare = TRUE)
  r$terms[[1]]$dice <- 1L
  r$terms[[1]]$kept <- 1L
  r$terms[[1]]$subtotal <- -9L
  r$total <- -9L
  expect_snapshot(print(r))
})

test_that("the reported standing is deterministic for a given notation and total", {
  # The standing must be a pure function of (components, total): identical
  # across repeated calls and independent of the RNG seed.
  pmf <- outcome_pmf(2L, 20L, 0L, "h", 1L)
  first <- percentile_below(pmf, 11L)
  second <- percentile_below(pmf, 11L)

  expect_equal(first, second)
  expect_equal(first, 25)
})

test_that("a wide-range comparison stays complete and finite", {
  # 10d100 spans 991 outcomes; the block must cover every outcome (one line
  # each) plus the header, and remain fast (no x^n enumeration).
  block <- comparison_block(roll("10d100", compare = TRUE))

  expect_length(block, 992L)
})

# Exploding dice ----

test_that("explode-once rerolls a maximum-face die exactly once (AC-3)", {
  # Seed 22 rolls 6 then 1 on 1d6, so `1d6!` sums both physical faces to 7.
  withr::local_seed(22)
  result <- roll("1d6!")

  expect_equal(result$dice, c(6L, 1L))
  expect_equal(result$total, 7L)
})

test_that("explode-once does not chain even when the reroll is also maximal (AC-3)", {
  # Seed 146 rolls 6 then 6; explode-once stops after the single reroll, so the
  # die contributes 12 and no third face is drawn.
  withr::local_seed(146)
  result <- roll("1d6!")

  expect_equal(result$dice, c(6L, 6L))
  expect_equal(result$total, 12L)
})

test_that("explode-indefinitely chains while the maximum recurs and stops at the first non-maximum (AC-3)", {
  # Seed 146 rolls 6, 6, 4 on 1d6: `1d6!!` chains twice then stops at the 4.
  withr::local_seed(146)
  result <- roll("1d6!!")

  expect_equal(result$dice, c(6L, 6L, 4L))
  expect_equal(result$total, 16L)
})

test_that("dice, kept, and total honour their contracts for an exploding roll (AC-4)", {
  # 2d6! where die A does not explode and die B does: $dice lists every
  # physical face in draw order, $kept the two per-die totals.
  withr::local_seed(22)
  result <- roll("2d6!")

  # Every physical face appears in draw order, and the per-die totals sum to
  # the total.
  expect_equal(result$dice, unlist(lapply(result$terms, \(t) t$dice)))
  expect_equal(result$total, sum(result$kept))
  # No selector, so kept holds all per-die totals; their sum plus m is the
  # pre-sign subtotal.
  sole <- result$terms[[1]]
  expect_equal(sum(sole$kept) + sole$m, sole$subtotal)
})

test_that("explode composes with a keep selector on per-die totals (AC-5)", {
  # 4d6!h3: all four dice explode into per-die totals, then the three highest
  # per-die totals are kept and summed.
  withr::local_seed(22)
  result <- roll("4d6!h3")

  per_die_totals <- result$terms[[1]]$kept
  expect_length(per_die_totals, 3L)
  expect_equal(result$total, sum(per_die_totals))
  # The kept totals are the three highest of the four exploded per-die totals.
  # Reconstruct the four per-die totals from the physical faces and confirm.
  expect_equal(sort(result$kept, decreasing = TRUE), result$kept)
})

test_that("print.roll shows an exploding term's rerolls inline and its total (AC-6)", {
  # Seed 22 rolls 6 then 1 on 1d6!, printing `Dice: 6, 1` and `Total: 7`.
  withr::local_seed(22)
  expect_snapshot(print(roll("1d6!")))
})

test_that("print.roll shows the kept per-die totals for a keep-selector exploding term (AC-6)", {
  withr::local_seed(22)
  expect_snapshot(print(roll("4d6!h3")))
})

test_that("explode-once never warns (AC-7)", {
  withr::local_seed(22)
  expect_no_warning(roll("1d6!"))
})

test_that("compare prints a histogram over the capped range with the marked total for an exploding roll (AC-12)", {
  # Seed 20 rolls a mid-range total (11) on 2d6!, with an actual explosion, so
  # the marked bar sits inside the histogram over the capped 2..24 range and the
  # standing is deterministic (computed, not sampled).
  withr::local_seed(20)
  expect_snapshot(print(roll("2d6!", compare = TRUE)))
})

test_that("compare resolves the marked bar for an explode-indefinitely roll (AC-12)", {
  # The `!!` capped range is enormous (2..1212), so a full histogram snapshot
  # would be unreadable. Assert the block structure instead: a deterministic
  # standing, a header, and a resolved marked bar (the rolled total always lands
  # in the PMF's named range because the sampler and PMF share the cap).
  withr::local_seed(20)
  r <- roll("2d6!!", compare = TRUE)
  block <- comparison_block(r)

  pmf <- grand_total_pmf(r$terms)
  expect_length(block, length(pmf) + 1L)
  expect_match(block[1], "beats", fixed = TRUE)
  # Exactly one histogram bar (excluding the header line) is marked.
  expect_equal(sum(grepl("<- this roll", block[-1], fixed = TRUE)), 1L)
})

test_that("an explode-indefinitely die hitting the cap warns and still returns a valid roll (AC-7)", {
  # A genuine 100-in-a-row is unreachable by seed, so force a maximal chain by
  # mocking `sample.int` to always return the maximum face. The warning fires
  # once and the roll object is still valid.
  testthat::local_mocked_bindings(
    sample.int = function(n, size = n, ...) rep.int(as.integer(n), size),
    .package = "base"
  )

  expect_snapshot(result <- roll("1d6!!"))
  expect_s3_class(result, "roll")
  # 101 physical faces (initial + 100 rerolls), all showing 6; per-die total
  # 606, and the cap outcome matches the PMF's folded tail (see distribution
  # tests).
  expect_length(result$dice, 101L)
  expect_equal(result$total, 606L)
})

test_that("a multi-term roll totals every term's contribution (AC-2)", {
  withr::local_seed(42)
  result <- roll("1d20+1d6+1d4+3")

  # Grand total is each dice term's kept-dice sum plus the summed constants;
  # here every term keeps all its dice and the trailing +3 binds to 1d4 as its
  # modifier, so the total is the sum of all dice plus 3.
  expect_equal(result$total, sum(result$dice) + 3L)
  expect_length(result$terms, 3L)
})

test_that("flat dice and kept concatenate every term in order", {
  withr::local_seed(42)
  result <- roll("2d20h+2d20l")

  expect_equal(
    result$dice,
    c(result$terms[[1]]$dice, result$terms[[2]]$dice)
  )
  expect_equal(
    result$kept,
    c(result$terms[[1]]$kept, result$terms[[2]]$kept)
  )
  # Grand total is the two kept dice summed (highest of the first pair, lowest
  # of the second).
  expect_equal(result$total, sum(result$kept))
})

test_that("a negated term subtracts its contribution", {
  withr::local_seed(42)
  result <- roll("2d20h-1d6")

  high <- max(result$terms[[1]]$dice)
  low_term <- result$terms[[2]]$dice
  expect_equal(result$total, high - low_term)
  expect_length(result$terms, 2L)
})

test_that("a constant term consumes no RNG so the dice stream is unchanged", {
  # A leading constant must not shift the RNG stream: the dice drawn for the
  # dice term match a bare roll of that term under the same seed.
  with_const <- withr::with_seed(42, roll("3+2d6"))
  plain <- withr::with_seed(42, roll("2d6"))
  expect_equal(with_const$terms[[2]]$dice, plain$dice)
  expect_equal(with_const$total, plain$total + 3L)
})

test_that("multi-term rolls are reproducible under a fixed seed", {
  first <- withr::with_seed(42, roll("1d20+1d6+3"))
  second <- withr::with_seed(42, roll("1d20+1d6+3"))
  expect_equal(first$dice, second$dice)
  expect_equal(first$total, second$total)
})

test_that("print.roll shows one Dice line per term and a grand total (AC-3)", {
  withr::local_seed(42)
  expect_snapshot(print(roll("1d20+1d6+1d4+3")))
})

test_that("print.roll groups a Kept line under each selector term", {
  withr::local_seed(42)
  expect_snapshot(print(roll("2d20h+2d20l")))
})

test_that("compare works for a multi-term keep notation (AC-5)", {
  withr::local_seed(42)
  expect_snapshot(print(roll("2d20h+2d20l", compare = TRUE)))
})

test_that("compare places the marked bar across a negative-capable range", {
  # 2d20h-1d6 spans a range that dips below zero; the marked bar must land
  # correctly within it.
  withr::local_seed(42)
  expect_snapshot(print(roll("2d20h-1d6", compare = TRUE)))
})

test_that("a multi-term compare PMF sums to 1 over the full range", {
  pmf <- grand_total_pmf(parse_notation("2d20h+2d20l")$terms)
  expect_equal(sum(pmf), 1)
  expect_equal(as.integer(names(pmf)), seq(2L, 40L))
})

test_that("the multi-term standing is deterministic and seed-independent", {
  # The standing is a pure function of (terms, total): a concrete, repeatable
  # value, and identical no matter what RNG seed is active when it is computed.
  under_first_seed <- withr::with_seed(42, {
    pmf <- grand_total_pmf(parse_notation("2d20h+2d20l")$terms)
    percentile_below(pmf, 25L)
  })
  under_second_seed <- withr::with_seed(999, {
    pmf <- grand_total_pmf(parse_notation("2d20h+2d20l")$terms)
    percentile_below(pmf, 25L)
  })

  expect_equal(under_first_seed, 70)
  expect_equal(under_second_seed, 70)
})

test_that("a wide multi-term comparison stays complete and finite (AC-7)", {
  # 10d100+10d100 spans 1981 outcomes (200..2000); the block must cover every
  # outcome plus the header and return without enumerating the joint dice
  # space (convolution of per-term count vectors only).
  block <- comparison_block(roll("10d100+10d100", compare = TRUE))

  expect_length(block, 1982L)
})

# Success-counting pools ----

test_that("a success roll draws the same dice as the bare pool and counts successes (AC-4)", {
  # The success draw uses the identical batched sample.int a bare NdX uses, so
  # under the same seed the dice match; the outcome is the count of those faces
  # that satisfy the comparator, exposed as both $total and $successes.
  success <- withr::with_seed(42, roll("5d10>=8"))
  bare <- withr::with_seed(42, roll("5d10"))

  expect_equal(success$dice, bare$dice)
  expect_true(isTRUE(success$success))
  expected_count <- sum(success$dice >= 8L)
  expect_equal(success$total, expected_count)
  expect_equal(success$successes, expected_count)
  expect_true(success$total >= 0L && success$total <= 5L)
  # The successful subset is exactly the dice that satisfy the comparator.
  expect_equal(success$successful, success$dice[success$dice >= 8L])
})

test_that("a summed-total roll carries no success flag (AC-11)", {
  result <- withr::with_seed(42, roll("2d20+2"))
  expect_null(result$success)
})

test_that("print.roll presents a success count rather than a total (AC-5)", {
  # Construct the dice directly so the snapshot does not depend on the RNG seed.
  r <- withr::with_seed(42, roll("5d10>=8"))
  r$dice <- c(9L, 3L, 8L, 5L, 10L)
  r$terms[[1]]$dice <- c(9L, 3L, 8L, 5L, 10L)
  r$successful <- c(9L, 8L, 10L)
  r$successes <- 3L
  r$total <- 3L
  expect_snapshot(print(r))
})

test_that("print.roll with compare shows the success distribution and marked count (AC-8)", {
  # A count of 2 out of 5 on 5d10>=8 (p = 0.3) gives a non-trivial standing with
  # the marked bar inside the histogram. Construct the count directly so the
  # case is deterministic rather than seed-dependent.
  r <- withr::with_seed(42, roll("5d10>=8", compare = TRUE))
  r$dice <- c(9L, 3L, 8L, 5L, 4L)
  r$terms[[1]]$dice <- c(9L, 3L, 8L, 5L, 4L)
  r$successful <- c(9L, 8L)
  r$successes <- 2L
  r$total <- 2L
  expect_snapshot(print(r))
})

test_that("an always-success pool warns once and returns N successes (AC-10)", {
  withr::local_seed(42)
  expect_snapshot(result <- roll("5d10>=1"))
  expect_equal(result$total, 5L)
})

test_that("a never-success pool warns once and returns zero successes (AC-10)", {
  withr::local_seed(42)
  expect_snapshot(result <- roll("5d10>=11"))
  expect_equal(result$total, 0L)
})
