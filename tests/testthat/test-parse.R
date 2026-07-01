test_that("parse_notation extracts components from a full NdX+M form", {
  expect_equal(
    parse_notation("2d20+2"),
    list(n = 2L, x = 20L, m = 2L, keep = NA_character_, keep_n = NA_integer_)
  )
})

test_that("parse_notation defaults a missing modifier to zero", {
  expect_equal(
    parse_notation("4d6"),
    list(n = 4L, x = 6L, m = 0L, keep = NA_character_, keep_n = NA_integer_)
  )
})

test_that("parse_notation handles a negative modifier", {
  expect_equal(
    parse_notation("1d8-1"),
    list(n = 1L, x = 8L, m = -1L, keep = NA_character_, keep_n = NA_integer_)
  )
})

test_that("parse_notation defaults a missing count to one", {
  expect_equal(
    parse_notation("d20"),
    list(n = 1L, x = 20L, m = 0L, keep = NA_character_, keep_n = NA_integer_)
  )
})

test_that("parse_notation is case-insensitive and whitespace-tolerant", {
  expect_equal(
    parse_notation("2D20 + 2"),
    list(n = 2L, x = 20L, m = 2L, keep = NA_character_, keep_n = NA_integer_)
  )
  expect_equal(
    parse_notation(" 2d20 + 2 "),
    list(n = 2L, x = 20L, m = 2L, keep = NA_character_, keep_n = NA_integer_)
  )
})

test_that("parse_notation reads keep-highest and keep-lowest selectors", {
  expect_equal(
    parse_notation("2d20h"),
    list(n = 2L, x = 20L, m = 0L, keep = "h", keep_n = 1L)
  )
  expect_equal(
    parse_notation("2d20l"),
    list(n = 2L, x = 20L, m = 0L, keep = "l", keep_n = 1L)
  )
  expect_equal(
    parse_notation("4d6h3"),
    list(n = 4L, x = 6L, m = 0L, keep = "h", keep_n = 3L)
  )
  expect_equal(
    parse_notation("3d6l2"),
    list(n = 3L, x = 6L, m = 0L, keep = "l", keep_n = 2L)
  )
})

test_that("a count-omitted die with a selector keeps the single die", {
  expect_equal(
    parse_notation("d20h"),
    list(n = 1L, x = 20L, m = 0L, keep = "h", keep_n = 1L)
  )
})

test_that("selectors are case-insensitive and compose with a modifier", {
  expect_equal(
    parse_notation("2D20H"),
    list(n = 2L, x = 20L, m = 0L, keep = "h", keep_n = 1L)
  )
  expect_equal(
    parse_notation("4d6h3 + 2"),
    list(n = 4L, x = 6L, m = 2L, keep = "h", keep_n = 3L)
  )
})

test_that("a keep count equal to the die count is valid and keeps all", {
  expect_equal(
    parse_notation("3d6h3"),
    list(n = 3L, x = 6L, m = 0L, keep = "h", keep_n = 3L)
  )
})

test_that("an invalid keep count is rejected", {
  expect_snapshot(error = TRUE, parse_notation("2d20h0"))
  expect_snapshot(error = TRUE, parse_notation("2d6h5"))
})

test_that("a malformed selector is rejected as invalid notation", {
  expect_snapshot(error = TRUE, parse_notation("2d6h-1"))
  expect_snapshot(error = TRUE, parse_notation("2d6h1.5"))
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
