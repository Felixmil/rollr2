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
  notations <- c(
    "2d6",
    "3d8-1",
    "4d6h3",
    "3d6l2",
    "1d4-10",
    "2d6!",
    "2d6!!",
    "2d6r1",
    "1d20rr1",
    "4d6r1h3"
  )
  for (nt in notations) {
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
        sole$explode,
        sole$reroll,
        sole$reroll_t
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

# Success-counting pools ----

test_that("success_p is the exact fraction of satisfying faces, clamped (AC-3)", {
  expect_equal(success_p(10L, ">=", 8L), 3 / 10)
  expect_equal(success_p(6L, ">=", 5L), 2 / 6)
  expect_equal(success_p(10L, ">", 8L), 2 / 10)
  expect_equal(success_p(10L, "<=", 3L), 3 / 10)
  expect_equal(success_p(10L, "<", 3L), 2 / 10)
  # Clamping: always-success and never-success targets.
  expect_equal(success_p(10L, ">=", 1L), 1)
  expect_equal(success_p(10L, ">=", 11L), 0)
  expect_equal(success_p(10L, "<", 1L), 0)
  expect_equal(success_p(10L, ">", 10L), 0)
})

test_that("the success-count PMF is Binomial(N, p) over 0..N (AC-7)", {
  pmf <- grand_total_pmf(parse_notation("5d10>=8")$terms)

  expect_equal(sum(pmf), 1)
  expect_true(all(pmf >= 0))
  expect_equal(as.integer(names(pmf)), 0:5)
  expect_equal(unname(pmf), dbinom(0:5, 5, 0.3))
})

test_that("success_pmf equals dbinom named by success count", {
  pmf <- success_pmf(6L, 2 / 6)
  expect_equal(unname(pmf), dbinom(0:6, 6, 2 / 6))
  expect_equal(as.integer(names(pmf)), 0:6)
})

test_that("term_bounds for a success term is c(0, N) (AC-7)", {
  expect_equal(term_bounds(parse_notation("5d10>=8")$terms[[1]]), c(0L, 5L))
  expect_equal(term_bounds(parse_notation("6d6>=5")$terms[[1]]), c(0L, 6L))
  expect_equal(term_bounds(parse_notation("d10>=8")$terms[[1]]), c(0L, 1L))
})

test_that("roll_distribution samples success counts over 0..N reproducibly (AC-6)", {
  withr::local_seed(42)
  dist <- roll_distribution("6d6>=5", n = 1000)

  expect_true(isTRUE(dist$success))
  expect_equal(dist$range, c(0L, 6L))
  expect_equal(sum(dist$counts), 1000L)
  outcomes <- as.integer(names(dist$counts))
  expect_true(all(outcomes >= 0L & outcomes <= 6L))

  first <- withr::with_seed(42, roll_distribution("6d6>=5", n = 500))
  second <- withr::with_seed(42, roll_distribution("6d6>=5", n = 500))
  expect_equal(first$counts, second$counts)
})

test_that("the sampled success range agrees with the exact PMF endpoints (AC-7)", {
  withr::local_seed(42)
  dist <- roll_distribution("6d6>=5", n = 1000)
  pmf <- grand_total_pmf(parse_notation("6d6>=5")$terms)
  outcomes <- as.integer(names(pmf))

  expect_equal(dist$range, c(min(outcomes), max(outcomes)))
})

test_that("a summed-total distribution carries no success flag (AC-11)", {
  withr::local_seed(42)
  expect_null(roll_distribution("2d6", n = 100)$success)
})

test_that("a degenerate success distribution warns once and still samples (AC-10)", {
  withr::local_seed(42)
  expect_snapshot(dist <- roll_distribution("5d10>=1", n = 100))
  # Every roll of an always-success pool is 5 successes.
  expect_equal(names(dist$counts), "5")
  expect_equal(sum(dist$counts), 100L)
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

# Reroll dice ----

test_that("roll_distribution samples reroll notation reproducibly and reports the theoretical range (AC-4)", {
  withr::local_seed(1)
  d_once <- roll_distribution("2d6r1", n = 2000)
  expect_equal(sum(d_once$counts), 2000L)
  # A reroll-once die can still land anywhere in 1..X, so the range matches a
  # plain 2d6: 2..12.
  expect_equal(d_once$range, c(2L, 12L))

  withr::local_seed(2)
  d_until <- roll_distribution("1d20rr1", n = 2000)
  expect_equal(sum(d_until$counts), 2000L)
  # A reroll-until die always lands strictly above T, so 1d20rr1 is 2..20 and
  # never produces a 1.
  expect_equal(d_until$range, c(2L, 20L))
  expect_false("1" %in% names(d_until$counts))

  first <- withr::with_seed(7, roll_distribution("2d6r1", n = 500))
  second <- withr::with_seed(7, roll_distribution("2d6r1", n = 500))
  expect_equal(first$counts, second$counts)
})

test_that("term_bounds reports the reroll per-die support bounds (AC-4)", {
  # Reroll-once keeps the plain 1..X support, so 2d6r1 is 2..12.
  once <- parse_notation("2d6r1")$terms[[1]]
  expect_equal(term_bounds(once), c(2L, 12L))

  # Reroll-until lifts the per-die minimum to T+1, so 1d20rr1 is 2..20 and
  # 2d6rr1 is 4..12.
  until1 <- parse_notation("1d20rr1")$terms[[1]]
  expect_equal(term_bounds(until1), c(2L, 20L))

  until2 <- parse_notation("2d6rr1")$terms[[1]]
  expect_equal(term_bounds(until2), c(4L, 12L))
})

test_that("the reroll-once per-die PMF is not uniform and sums to 1 (AC-5)", {
  # 1d4r1: values <= T carry only the reroll mass T/X^2 = 1/16, while values
  # > T carry the direct plus reroll mass 1/X + T/X^2 = 5/16. Sums to 1.
  pmf <- outcome_pmf(1L, 4L, 0L, NA_character_, NA_integer_, "none", "once", 1L)

  expect_equal(as.integer(names(pmf)), seq(1L, 4L))
  expect_equal(unname(pmf[1]), 1 / 16)
  expect_equal(unname(pmf[2:4]), rep(5 / 16, 3))
  expect_equal(sum(pmf), 1)
})

test_that("the reroll-until per-die PMF is uniform over T+1..X and sums to 1 (AC-5)", {
  # 1d6rr1: zero mass on 1, uniform 1/5 over 2..6.
  pmf <- outcome_pmf(
    1L,
    6L,
    0L,
    NA_character_,
    NA_integer_,
    "none",
    "until",
    1L
  )

  expect_equal(as.integer(names(pmf)), seq(1L, 6L))
  expect_equal(unname(pmf[1]), 0)
  expect_equal(unname(pmf[2:6]), rep(1 / 5, 5))
  expect_equal(sum(pmf), 1)
})

test_that("outcome_pmf matches brute-force enumeration for a reroll-once keep case (AC-5)", {
  # Enumerate all 3^3 per-die-outcome triples of 3d3r1h2 weighted by the exact
  # single-die 1d3r1 distribution, keep the top 2, and tabulate.
  die <- reroll_die_probs(3L, "once", 1L)
  grid <- expand.grid(a = 1:3, b = 1:3, c = 1:3)
  w <- die[grid$a] * die[grid$b] * die[grid$c]
  kept <- apply(grid, 1L, \(r) sum(sort(r, decreasing = TRUE)[1:2]))
  expected <- tapply(w, kept, sum)

  pmf <- outcome_pmf(3L, 3L, 0L, "h", 2L, "none", "once", 1L)
  dense <- setNames(numeric(length(pmf)), names(pmf))
  dense[names(expected)] <- expected

  expect_equal(unname(as.numeric(dense)), unname(as.numeric(pmf)))
})

test_that("grand_total_pmf for a reroll notation is a finite normalized distribution over contiguous outcomes (AC-5)", {
  for (nt in c("2d6r1", "2d6rr1", "4d6r1h3", "4d6rr1l2", "1d20+2d6rr1")) {
    pmf <- grand_total_pmf(parse_notation(nt)$terms)
    outcomes <- as.integer(names(pmf))

    expect_equal(sum(pmf), 1)
    expect_true(all(pmf >= 0))
    expect_equal(outcomes, seq(min(outcomes), max(outcomes)))
  }
})

test_that("the sampled reroll distribution agrees with the exact PMF as n grows (AC-5)", {
  # At large n the empirical proportions converge to the exact PMF; a loose
  # per-outcome absolute tolerance confirms the sampler and the exact
  # distribution describe the same law.
  withr::local_seed(42)
  d <- roll_distribution("2d6r1", n = 200000)
  empirical <- d$counts / sum(d$counts)

  pmf <- grand_total_pmf(parse_notation("2d6r1")$terms)
  pmf <- pmf[pmf > 0]
  common <- intersect(names(empirical), names(pmf))

  expect_setequal(names(empirical), names(pmf))
  expect_lt(max(abs(empirical[common] - pmf[common])), 0.01)
})
