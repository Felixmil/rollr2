test_that("counts cover only outcomes in the possible range and sum to n", {
  withr::local_seed(1)
  dist <- roll_distribution("2d6", n = 1000)

  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))
  expect_equal(dist$range, c(2L, 12L))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("counts are ordered ascending by outcome value", {
  withr::local_seed(2)
  dist <- roll_distribution("3d8-1", n = 500)

  outcomes <- as.integer(names(dist$counts))
  expect_equal(outcomes, sort(outcomes))
})

test_that("a large die space and repetition count remain functional", {
  withr::local_seed(3)
  dist <- roll_distribution("10d100+5", n = 5000)

  expect_equal(sum(dist$counts), 5000L)
  expect_equal(dist$range, c(15L, 1005L))
})

test_that("the distribution is reproducible under a fixed seed", {
  first <- withr::with_seed(99, roll_distribution("2d6", n = 200))
  second <- withr::with_seed(99, roll_distribution("2d6", n = 200))

  expect_equal(first$counts, second$counts)
})

test_that("a keep-highest selector narrows the range to the kept count", {
  withr::local_seed(10)
  dist <- roll_distribution("2d20h", n = 1000)

  expect_equal(dist$range, c(1L, 20L))
  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("an explicit keep count sets the range from the kept dice", {
  withr::local_seed(11)
  dist <- roll_distribution("4d6h3", n = 1000)

  expect_equal(dist$range, c(3L, 18L))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("a selector on a single die keeps every simulated roll", {
  withr::local_seed(13)
  dist <- roll_distribution("d20h", n = 1000)

  expect_equal(dist$range, c(1L, 20L))
  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("keeping the one die of a single-die roll equals the plain die", {
  with_selector <- withr::with_seed(14, roll_distribution("d20h", n = 1000))
  plain <- withr::with_seed(14, roll_distribution("d20", n = 1000))

  expect_equal(with_selector$counts, plain$counts)
})

test_that("a selector with a large die space bins over the kept range", {
  withr::local_seed(12)
  dist <- roll_distribution("10d100h5+5", n = 5000)

  expect_equal(dist$range, c(10L, 505L))
  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))
  expect_equal(sum(dist$counts), 5000L)
})

test_that("a selector distribution is reproducible under a fixed seed", {
  first <- withr::with_seed(88, roll_distribution("4d6h3", n = 200))
  second <- withr::with_seed(88, roll_distribution("4d6h3", n = 200))
  expect_equal(first$counts, second$counts)
})

test_that("print.roll_distribution renders counts and a histogram", {
  withr::local_seed(4)
  expect_snapshot(print(roll_distribution("2d6", n = 100)))
})

test_that("a non-positive-integer repetition count is rejected", {
  expect_snapshot(error = TRUE, roll_distribution("2d6", n = 0))
  expect_snapshot(error = TRUE, roll_distribution("2d6", n = -5))
  expect_snapshot(error = TRUE, roll_distribution("2d6", n = 2.5))
  expect_snapshot(error = TRUE, roll_distribution("2d6", n = c(1, 2)))
  expect_snapshot(error = TRUE, roll_distribution("2d6", n = "many"))
})

test_that("roll_distribution surfaces parse errors", {
  expect_snapshot(error = TRUE, roll_distribution("bad", n = 10))
})

test_that("outcome_pmf is a probability distribution over the full range", {
  cases <- list(
    plain = list(
      n = 2L,
      x = 6L,
      m = 0L,
      keep = NA_character_,
      keep_n = NA_integer_
    ),
    modifier = list(
      n = 3L,
      x = 8L,
      m = -1L,
      keep = NA_character_,
      keep_n = NA_integer_
    ),
    high = list(n = 4L, x = 6L, m = 0L, keep = "h", keep_n = 3L),
    low = list(n = 3L, x = 6L, m = 0L, keep = "l", keep_n = 2L)
  )

  for (case in cases) {
    pmf <- outcome_pmf(case$n, case$x, case$m, case$keep, case$keep_n)
    k <- if (is.na(case$keep)) case$n else case$keep_n

    expect_equal(sum(pmf), 1)
    expect_true(all(pmf >= 0))
    expect_equal(
      as.integer(names(pmf)),
      seq(k + case$m, k * case$x + case$m)
    )
  }
})

test_that("outcome_pmf matches brute-force enumeration for a keep-highest case", {
  # Enumerate all 6^4 outcomes of 4d6h3, keep the top 3, and tabulate exact
  # probabilities to pin the dynamic program to ground truth.
  grid <- expand.grid(rep(list(seq_len(6L)), 4L))
  totals <- apply(grid, 1L, \(row) sum(sort(row, decreasing = TRUE)[1:3]))
  expected <- prop.table(table(factor(totals, levels = seq(3L, 18L))))

  pmf <- outcome_pmf(4L, 6L, 0L, "h", 3L)

  expect_equal(unname(pmf), as.numeric(expected))
})

test_that("outcome_pmf reflects a keep-lowest distribution from keep-highest", {
  # 3d6l2 keeps the lowest 2; its shape is the face reflection of 3d6h2.
  grid <- expand.grid(rep(list(seq_len(6L)), 3L))
  totals <- apply(grid, 1L, \(row) sum(sort(row)[1:2]))
  expected <- prop.table(table(factor(totals, levels = seq(2L, 12L))))

  pmf <- outcome_pmf(3L, 6L, 0L, "l", 2L)

  expect_equal(unname(pmf), as.numeric(expected))
})

test_that("percentile_below reports 0 at the minimum and mass-below at the maximum", {
  pmf <- outcome_pmf(2L, 6L, 0L, NA_character_, NA_integer_)

  expect_equal(percentile_below(pmf, 2L), 0)
  # Everything except the maximum (probability 1/36) is strictly below 12.
  expect_equal(percentile_below(pmf, 12L), round(100 * (1 - 1 / 36)))
})

# Multi-term notation ----

test_that("a multi-term distribution sums, ranges, and reproduces (AC-4)", {
  withr::local_seed(1)
  dist <- roll_distribution("1d20+1d6", n = 1000)

  expect_equal(sum(dist$counts), 1000L)
  expect_equal(dist$range, c(2L, 26L))
  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))

  first <- withr::with_seed(50, roll_distribution("1d20+1d6", n = 500))
  second <- withr::with_seed(50, roll_distribution("1d20+1d6", n = 500))
  expect_equal(first$counts, second$counts)
})

test_that("the sampled range agrees with the exact PMF endpoints (AC-6)", {
  withr::local_seed(2)
  dist <- roll_distribution("2d20h+2d20l", n = 1000)
  pmf <- grand_total_pmf(parse_notation("2d20h+2d20l")$terms)
  outcomes <- as.integer(names(pmf))

  expect_equal(dist$range, c(min(outcomes), max(outcomes)))
})

test_that("a negated-term distribution can range below zero", {
  withr::local_seed(4)
  dist <- roll_distribution("2d20h-1d6", n = 1000)

  expect_equal(dist$range, c(-5L, 19L))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("a constant term consumes no RNG in the sampler", {
  # A leading constant shifts every total by its value without perturbing the
  # dice draws, so the counts match the plain notation shifted by the constant.
  with_const <- withr::with_seed(9, roll_distribution("3+2d6", n = 500))
  plain <- withr::with_seed(9, roll_distribution("2d6", n = 500))

  shifted <- plain$counts
  names(shifted) <- as.integer(names(plain$counts)) + 3L
  expect_equal(with_const$counts, shifted)
})

test_that("print.roll_distribution renders a multi-term notation", {
  withr::local_seed(4)
  expect_snapshot(print(roll_distribution("1d20+1d6", n = 100)))
})

test_that("grand_total_pmf reduces to outcome_pmf for a lone dice term", {
  for (nt in c("2d6", "3d8-1", "4d6h3", "3d6l2", "1d4-10")) {
    terms <- parse_notation(nt)$terms
    sole <- terms[[1]]
    expect_equal(
      grand_total_pmf(terms),
      outcome_pmf(sole$n, sole$x, sole$m, sole$keep, sole$keep_n)
    )
  }
})
