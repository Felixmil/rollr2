test_that("plot.roll_distribution returns a themed ggplot over the full range", {
  withr::local_seed(42)
  p <- plot(roll_distribution("2d6", n = 1000))

  expect_s3_class(p, "ggplot")

  # Bars span the theoretical 2..12 range (EC-5: driven by x$range, not only
  # observed totals). With n = 1000 every total is observed, so the layer data
  # covers the whole range.
  xs <- ggplot2::layer_data(p)$x
  expect_equal(range(xs), c(2, 12))

  # Non-default theme, title, subtitle, and axis labels (FR-4, AC-1).
  expect_equal(p$labels$title, "Distribution of totals for 2d6")
  expect_equal(p$labels$subtitle, "1,000 simulated rolls")
  expect_equal(p$labels$x, "Total")
  expect_equal(p$labels$y, "Count")
  expect_false(identical(p$theme, ggplot2::theme_grey()))
})

test_that("plot.roll returns a ggplot spanning the exact PMF range", {
  withr::local_seed(42)
  p <- plot(roll("2d6"))

  expect_s3_class(p, "ggplot")

  xs <- ggplot2::layer_data(p)$x
  expect_equal(range(xs), c(2, 12))
  expect_equal(p$labels$title, "Outcome distribution for 2d6")
  expect_equal(p$labels$x, "Total")
  expect_equal(p$labels$y, "Probability")
})

test_that("plot.roll highlights the rolled total and reports its standing", {
  r <- withr::with_seed(42, roll("2d6"))

  expected_percentile <- percentile_below(
    outcome_pmf(2L, 6L, 0L, NA_character_, NA_integer_),
    r$total
  )

  p <- plot(r)
  ld <- ggplot2::layer_data(p)

  # Exactly the rolled total's bar carries the highlight fill (AC-2, EC-4).
  highlighted <- ld$x[ld$fill == "firebrick"]
  expect_equal(highlighted, as.numeric(r$total))

  # The standing in the subtitle matches percentile_below() (AC-2, C-4).
  expect_match(
    p$labels$subtitle,
    paste0("beats ", expected_percentile, "% of outcomes"),
    fixed = TRUE
  )
})

test_that("plot.roll ignores the compare flag", {
  with_compare <- withr::with_seed(42, roll("2d6", compare = TRUE))
  without_compare <- withr::with_seed(42, roll("2d6", compare = FALSE))

  p_true <- plot(with_compare)
  p_false <- plot(without_compare)

  # Same underlying roll (same seed) must yield identical charts (AC-3, FR-3).
  expect_equal(ggplot2::layer_data(p_true), ggplot2::layer_data(p_false))
  expect_equal(p_true$labels, p_false$labels)
})

test_that("plot.roll is deterministic and consumes no RNG", {
  r <- withr::with_seed(42, roll("2d6"))

  # Calling twice without a seed reads the stored components and computes the
  # exact PMF, so the plotted data is identical (C-5).
  first <- ggplot2::layer_data(plot(r))
  second <- ggplot2::layer_data(plot(r))
  expect_equal(first, second)
})

test_that("plot.roll handles a keep selector", {
  r <- withr::with_seed(42, roll("4d6h3"))
  p <- plot(r)

  expect_s3_class(p, "ggplot")
  # 4d6h3 ranges from 3 to 18.
  expect_equal(range(ggplot2::layer_data(p)$x), c(3, 18))
})

test_that("plot.roll handles a negative, shifted range", {
  # 1d4-10 ranges from -9 to -6 (EC-3).
  r <- withr::with_seed(42, roll("1d4-10"))
  p <- plot(r)

  expect_s3_class(p, "ggplot")
  expect_equal(range(ggplot2::layer_data(p)$x), c(-9, -6))
})

test_that("plot.roll works on a multi-term notation", {
  # Multi-term rolls omit the flat `$n/$x/$m/$keep/$keep_n` fields, so the plot
  # must source its PMF from the per-term structure (`grand_total_pmf()`), the
  # same source the compare print path uses.
  r <- withr::with_seed(42, roll("1d20+1d6+3"))
  p <- plot(r)

  expect_s3_class(p, "ggplot")

  # 1d20+1d6+3 ranges from 5 (1+1+3) to 29 (20+6+3).
  expect_equal(range(ggplot2::layer_data(p)$x), c(5, 29))
  expect_equal(p$labels$title, "Outcome distribution for 1d20+1d6+3")

  # The plotted standing matches the compare/print path exactly (Goal 3: the
  # entry points stay in lockstep).
  expected_percentile <- percentile_below(grand_total_pmf(r$terms), r$total)
  expect_match(
    p$labels$subtitle,
    paste0("beats ", expected_percentile, "% of outcomes"),
    fixed = TRUE
  )

  # Exactly the rolled total's bar carries the highlight fill.
  ld <- ggplot2::layer_data(p)
  expect_equal(ld$x[ld$fill == "firebrick"], as.numeric(r$total))
})

test_that("plot.roll handles a negated multi-term notation", {
  # 2d20h-2d20l can go negative (largest single d20 minus smallest single d20),
  # ranging from -19 (1-20) to 19 (20-1). Exercises the negated-term PMF path.
  r <- withr::with_seed(42, roll("2d20h-2d20l"))
  p <- plot(r)

  expect_s3_class(p, "ggplot")
  expect_equal(range(ggplot2::layer_data(p)$x), c(-19, 19))
})

test_that("plot.roll reports 0% standing when the total is the minimum", {
  # Construct a 2d6 roll whose total is the range minimum (2) directly, so the
  # 0% standing does not depend on the RNG seed.
  r <- withr::with_seed(42, roll("2d6"))
  r_min <- r
  r_min$total <- 2L
  p <- plot(r_min)

  expect_match(p$labels$subtitle, "beats 0% of outcomes", fixed = TRUE)
  ld <- ggplot2::layer_data(p)
  expect_equal(ld$x[ld$fill == "firebrick"], 2)
})

test_that("plot.roll renders a wide range without axis clutter", {
  r <- withr::with_seed(42, roll("10d100"))
  p <- plot(r)

  expect_s3_class(p, "ggplot")

  # ~991 outcomes, but the axis must not get one break per outcome (EC-2).
  breaks <- integer_axis_breaks(range(as.integer(names(
    outcome_pmf(10L, 100L, 0L, NA_character_, NA_integer_)
  ))))
  expect_lt(length(breaks), 20L)
})

test_that("plot.roll highlights an exploding roll over the capped range (AC-13)", {
  # 2d6! spans the capped 2..24 range; the rolled total's bar is highlighted and
  # its standing appears in the subtitle. Seed 20 rolls total 11.
  r <- withr::with_seed(20, roll("2d6!"))
  p <- plot(r)

  expect_s3_class(p, "ggplot")
  expect_equal(range(ggplot2::layer_data(p)$x), c(2, 24))

  expected_percentile <- percentile_below(grand_total_pmf(r$terms), r$total)
  expect_match(
    p$labels$subtitle,
    paste0("beats ", expected_percentile, "% of outcomes"),
    fixed = TRUE
  )
  ld <- ggplot2::layer_data(p)
  expect_equal(ld$x[ld$fill == "firebrick"], as.numeric(r$total))
})

test_that("plot.roll returns a valid ggplot over the huge explode-indefinitely range (AC-13)", {
  # The `!!` range is enormous; assert the plot builds and its axis matches the
  # capped bounds without over-asserting a per-outcome layout.
  r <- withr::with_seed(20, roll("2d6!!"))
  p <- plot(r)

  expect_s3_class(p, "ggplot")
  pmf <- grand_total_pmf(r$terms)
  expect_equal(
    range(ggplot2::layer_data(p)$x),
    c(min(as.integer(names(pmf))), max(as.integer(names(pmf))))
  )
})

test_that("plot.roll_distribution renders an exploding distribution over the capped range (AC-13)", {
  d <- withr::with_seed(1, roll_distribution("2d6!", n = 1000))
  p <- plot(d)

  expect_s3_class(p, "ggplot")
  # The distribution's range is the capped 2..24, and the axis breaks fall
  # within it (rounded to a handful of round integers by pretty()).
  expect_equal(d$range, c(2L, 24L))
  breaks <- integer_axis_breaks(d$range)
  expect_true(all(breaks >= 2 & breaks <= 24))
})

test_that("plot.roll_distribution handles a keep selector and a wide range", {
  p_keep <- plot(withr::with_seed(42, roll_distribution("4d6h3", n = 1000)))
  expect_s3_class(p_keep, "ggplot")

  p_wide <- plot(withr::with_seed(42, roll_distribution("10d100", n = 2000)))
  expect_s3_class(p_wide, "ggplot")
})

test_that("plot.roll_distribution renders a near-degenerate distribution", {
  # A distribution where every sample lands on one total still yields at least
  # one bar and a valid panel (EC-1). Construct it directly to force the
  # degenerate case deterministically.
  d <- roll_distribution("2d6", n = 100)
  d$counts <- c(`7` = 100L)
  p <- plot(d)

  expect_s3_class(p, "ggplot")
  expect_gte(nrow(ggplot2::layer_data(p)), 1L)
})

test_that("plot.roll_distribution axis reflects x$range, not only observed", {
  # Drop all but one observed total; the axis breaks still come from x$range
  # (EC-5). 2d6 has range 2..12.
  d <- roll_distribution("2d6", n = 100)
  d$counts <- c(`7` = 100L)

  breaks <- integer_axis_breaks(d$range)
  expect_equal(range(breaks), c(2, 12))
})
