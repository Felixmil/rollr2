test_that("a single roll returns dice in range and a consistent total", {
  withr::local_seed(42)
  result <- roll("4d6+2")

  expect_length(result$dice, 4L)
  expect_true(all(result$dice >= 1L & result$dice <= 6L))
  expect_equal(result$total, sum(result$dice) + 2L)
})

test_that("a single die single roll yields one result equal to the total minus modifier", {
  withr::local_seed(1)
  result <- roll("1d6")

  expect_length(result$dice, 1L)
  expect_equal(result$total, result$dice)
})

test_that("a large negative modifier is not floored", {
  withr::local_seed(1)
  result <- roll("1d4-10")

  expect_equal(result$total, result$dice - 10L)
  expect_lt(result$total, 0L)
})

test_that("rolls are reproducible under a fixed seed", {
  first <- withr::with_seed(123, roll("2d20+2"))
  second <- withr::with_seed(123, roll("2d20+2"))

  expect_equal(first$dice, second$dice)
  expect_equal(first$total, second$total)
})

test_that("print.roll renders notation, dice, and total", {
  withr::local_seed(7)
  expect_snapshot(print(roll("2d20+2")))
})

test_that("roll surfaces parse errors", {
  expect_snapshot(error = TRUE, roll("nonsense"))
})
