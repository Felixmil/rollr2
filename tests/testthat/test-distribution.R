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
