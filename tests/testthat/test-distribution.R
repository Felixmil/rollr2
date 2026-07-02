test_that("counts cover only outcomes in the possible range and sum to n", {
  withr::local_seed(42)
  dist <- roll_distribution("2d6", n = 1000)

  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))
  expect_equal(dist$range, c(2L, 12L))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("counts are ordered ascending by outcome value", {
  withr::local_seed(42)
  dist <- roll_distribution("3d8-1", n = 500)

  outcomes <- as.integer(names(dist$counts))
  expect_equal(outcomes, sort(outcomes))
})

test_that("a large die space and repetition count remain functional", {
  withr::local_seed(42)
  dist <- roll_distribution("10d100+5", n = 5000)

  expect_equal(sum(dist$counts), 5000L)
  expect_equal(dist$range, c(15L, 1005L))
})

test_that("the distribution is reproducible under a fixed seed", {
  first <- withr::with_seed(42, roll_distribution("2d6", n = 200))
  second <- withr::with_seed(42, roll_distribution("2d6", n = 200))

  expect_equal(first$counts, second$counts)
})

test_that("a keep-highest selector narrows the range to the kept count", {
  withr::local_seed(42)
  dist <- roll_distribution("2d20h", n = 1000)

  expect_equal(dist$range, c(1L, 20L))
  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("an explicit keep count sets the range from the kept dice", {
  withr::local_seed(42)
  dist <- roll_distribution("4d6h3", n = 1000)

  expect_equal(dist$range, c(3L, 18L))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("a drop notation samples identically to its keep equivalent (AC-5)", {
  drop <- withr::with_seed(42, roll_distribution("4d6dl1", n = 1000))
  keep <- withr::with_seed(42, roll_distribution("4d6h3", n = 1000))
  expect_equal(drop$counts, keep$counts)
  expect_equal(drop$range, keep$range)
})

test_that("a selector on a single die keeps every simulated roll", {
  withr::local_seed(42)
  dist <- roll_distribution("d20h", n = 1000)

  expect_equal(dist$range, c(1L, 20L))
  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("keeping the one die of a single-die roll equals the plain die", {
  with_selector <- withr::with_seed(42, roll_distribution("d20h", n = 1000))
  plain <- withr::with_seed(42, roll_distribution("d20", n = 1000))

  expect_equal(with_selector$counts, plain$counts)
})

test_that("a selector with a large die space bins over the kept range", {
  withr::local_seed(42)
  dist <- roll_distribution("10d100h5+5", n = 5000)

  expect_equal(dist$range, c(10L, 505L))
  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))
  expect_equal(sum(dist$counts), 5000L)
})

test_that("a selector distribution is reproducible under a fixed seed", {
  first <- withr::with_seed(42, roll_distribution("4d6h3", n = 200))
  second <- withr::with_seed(42, roll_distribution("4d6h3", n = 200))
  expect_equal(first$counts, second$counts)
})

test_that("print.roll_distribution renders counts and a histogram", {
  withr::local_seed(42)
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
  withr::local_seed(42)
  dist <- roll_distribution("1d20+1d6", n = 1000)

  expect_equal(sum(dist$counts), 1000L)
  expect_equal(dist$range, c(2L, 26L))
  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= dist$range[1] & outcomes <= dist$range[2]))

  first <- withr::with_seed(42, roll_distribution("1d20+1d6", n = 500))
  second <- withr::with_seed(42, roll_distribution("1d20+1d6", n = 500))
  expect_equal(first$counts, second$counts)
})

test_that("the sampled range agrees with the exact PMF endpoints (AC-6)", {
  withr::local_seed(42)
  dist <- roll_distribution("2d20h+2d20l", n = 1000)
  pmf <- grand_total_pmf(parse_notation("2d20h+2d20l")$terms)
  outcomes <- as.integer(names(pmf))

  expect_equal(dist$range, c(min(outcomes), max(outcomes)))
})

test_that("a negated-term distribution can range below zero", {
  withr::local_seed(42)
  dist <- roll_distribution("2d20h-1d6", n = 1000)

  expect_equal(dist$range, c(-5L, 19L))
  expect_equal(sum(dist$counts), 1000L)
})

test_that("a constant term consumes no RNG in the sampler", {
  # A leading constant shifts every total by its value without perturbing the
  # dice draws, so the counts match the plain notation shifted by the constant.
  with_const <- withr::with_seed(42, roll_distribution("3+2d6", n = 500))
  plain <- withr::with_seed(42, roll_distribution("2d6", n = 500))

  shifted <- plain$counts
  names(shifted) <- as.integer(names(plain$counts)) + 3L
  expect_equal(with_const$counts, shifted)
})

test_that("print.roll_distribution renders a multi-term notation", {
  withr::local_seed(42)
  expect_snapshot(print(roll_distribution("1d20+1d6", n = 100)))
})

test_that("grand_total_pmf reduces to outcome_pmf for a lone dice term", {
  for (nt in c("2d6", "3d8-1", "4d6h3", "3d6l2", "1d4-10", "2d6!", "2d6!!")) {
    terms <- parse_notation(nt)$terms
    sole <- terms[[1]]
    expect_equal(
      grand_total_pmf(terms),
      outcome_pmf(
        sole$n,
        sole$x,
        sole$m,
        sole$keep,
        sole$keep_n,
        sole$explode
      )
    )
  }
})

# Exploding dice ----

test_that("roll_distribution samples exploding notation, terminates, reproduces, and reports the PMF range (AC-8)", {
  withr::local_seed(1)
  d_once <- roll_distribution("2d6!", n = 2000)
  expect_equal(sum(d_once$counts), 2000L)
  pmf_once <- grand_total_pmf(parse_notation("2d6!")$terms)
  expect_equal(
    d_once$range,
    c(min(as.integer(names(pmf_once))), max(as.integer(names(pmf_once))))
  )

  # `!!` always terminates (bounded by the cap) even though its range is huge.
  withr::local_seed(2)
  d_indef <- roll_distribution("2d6!!", n = 2000)
  expect_equal(sum(d_indef$counts), 2000L)
  pmf_indef <- grand_total_pmf(parse_notation("2d6!!")$terms)
  expect_equal(
    d_indef$range,
    c(min(as.integer(names(pmf_indef))), max(as.integer(names(pmf_indef))))
  )

  first <- withr::with_seed(7, roll_distribution("2d6!", n = 500))
  second <- withr::with_seed(7, roll_distribution("2d6!", n = 500))
  expect_equal(first$counts, second$counts)
})

test_that("term_bounds reports the finite capped bounds for an exploding term (AC-10)", {
  once <- parse_notation("2d6!")$terms[[1]]
  expect_equal(term_bounds(once), c(2L, 24L))

  # `!!` per-die max is (explode_cap + 1) * x; 1d6!! is 1..606, 2d6!! is 2..1212.
  indef1 <- parse_notation("1d6!!")$terms[[1]]
  expect_equal(term_bounds(indef1), c(1L, (explode_cap + 1L) * 6L))

  indef2 <- parse_notation("2d6!!")$terms[[1]]
  expect_equal(term_bounds(indef2), c(2L, 2L * (explode_cap + 1L) * 6L))
})

test_that("grand_total_pmf for an exploding notation is a finite normalized distribution over contiguous outcomes (AC-9)", {
  for (nt in c("2d6!", "2d6!!", "4d6!h3", "4d6!!l2", "2d6!+1", "1d20+2d6!")) {
    pmf <- grand_total_pmf(parse_notation(nt)$terms)
    outcomes <- as.integer(names(pmf))

    expect_equal(sum(pmf), 1)
    expect_true(all(pmf >= 0))
    expect_equal(outcomes, seq(min(outcomes), max(outcomes)))
  }
})

test_that("a wide exploding notation stays fast and finite (AC-9, performance)", {
  # 10d100! spans 1991 outcomes; the convolution never enumerates the joint
  # dice space, so this returns quickly and finitely.
  elapsed <- system.time({
    pmf <- grand_total_pmf(parse_notation("10d100!")$terms)
  })[["elapsed"]]

  expect_true(all(is.finite(pmf)))
  expect_equal(sum(pmf), 1)
  expect_lt(elapsed, 5)
})

test_that("the exact single-explode-once per-die PMF has the forced-reroll gap and correct weights (AC-11)", {
  # 1d6!: 1/6 on 1..5, zero at 6 (a maximum first face forces a reroll), 1/36
  # on 7..12.
  pmf <- outcome_pmf(1L, 6L, 0L, NA_character_, NA_integer_, "once")

  expect_equal(as.integer(names(pmf)), seq(1L, 12L))
  expect_equal(unname(pmf[1:5]), rep(1 / 6, 5))
  expect_equal(unname(pmf[6]), 0)
  expect_equal(unname(pmf[7:12]), rep(1 / 36, 6))
})

test_that("the explode-indefinitely per-die PMF folds the depth-cap tail into the largest outcome and sums to 1 (AC-11)", {
  pmf <- outcome_pmf(1L, 6L, 0L, NA_character_, NA_integer_, "indef")

  expect_equal(sum(pmf), 1)
  expect_true(all(pmf >= 0))
  # The largest outcome is the sampler's cap total (explode_cap + 1) * x, and it
  # carries the folded residual tail.
  expect_equal(max(as.integer(names(pmf))), (explode_cap + 1L) * 6L)
  expect_gt(pmf[length(pmf)], 0)
})

test_that("outcome_pmf matches brute-force enumeration for an explode-once keep case (AC-11)", {
  # Enumerate all 3^3 per-die-outcome triples of 3d3!h2 weighted by the exact
  # single-die 1d3! distribution, keep the top 2, and tabulate. 1d3! has support
  # 1,2 (each 1/3), 0 at 3, and 4,5,6 (each 1/9).
  die <- c(1 / 3, 1 / 3, 0, 1 / 9, 1 / 9, 1 / 9)
  grid <- expand.grid(a = 1:6, b = 1:6, c = 1:6)
  w <- die[grid$a] * die[grid$b] * die[grid$c]
  kept <- apply(grid, 1L, \(r) sum(sort(r, decreasing = TRUE)[1:2]))
  expected <- tapply(w, kept, sum)

  pmf <- outcome_pmf(3L, 3L, 0L, "h", 2L, "once")
  dense <- setNames(numeric(length(pmf)), names(pmf))
  dense[names(expected)] <- expected

  expect_equal(unname(as.numeric(dense)), unname(as.numeric(pmf)))
})
