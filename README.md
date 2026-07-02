

<!-- README.md is generated from README.qmd. Please edit that file and re-render. -->

# rollr2

<!-- badges: start -->

[![R-CMD-check](https://github.com/Felixmil/rollr2/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Felixmil/rollr2/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/Felixmil/rollr2/graph/badge.svg)](https://app.codecov.io/gh/Felixmil/rollr2)
<!-- badges: end -->

`rollr2` parses and rolls tabletop RPG dice notation such as `"2d20+2"`.
From a single notation string it reports every individual die, the kept
dice, and the adjusted total, and it can summarise the outcome
distribution across many repeated rolls.

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("Felixmil/rollr2")
```

## Roll once

`roll()` simulates a single roll and returns a `roll` object holding the
individual dice and the total. The functions are stochastic, so fix a
seed when you want reproducible output.

``` r
library(rollr2)

set.seed(1)
roll("2d20+2")
#> <roll> 2d20+2
#> Dice:  4, 7
#> Total: 13
```

A keep selector like `4d6h3` keeps only the highest (`h`) or lowest
(`l`) dice; the printout then shows which dice were kept.

``` r
set.seed(1)
roll("4d6h3")
#> <roll> 4d6h3
#> Dice:  1, 4, 1, 2
#> Kept:  4, 2, 1
#> Total: 7
```

A notation can also sum several terms and constants, joined with `+` or
`-`.

``` r
set.seed(1)
roll("1d20+1d6+3")
#> <roll> 1d20+1d6+3
#> Dice:  4
#> Dice:  1
#> Total: 8
```

## Summarise a distribution

`roll_distribution()` rolls the whole notation many times and summarises
the distribution of totals, printing a count per outcome and a text
histogram.

``` r
set.seed(1)
roll_distribution("2d6", n = 1000)
#> <roll_distribution> 2d6
#> Rolls: 1000  Possible total range: 2 to 12
#> 
#>  2 | #######  28
#>  3 | ############  50
#>  4 | ###################  79
#>  5 | ########################### 112
#>  6 | ################################### 148
#>  7 | ######################################## 167
#>  8 | #################################### 150
#>  9 | ######################### 105
#> 10 | ####################  82
#> 11 | ##############  58
#> 12 | #####  21
```

## Learn more

See `vignette("rollr2")` to get started, and the “Visualising roll
distributions” article on the [package
website](https://felixmil.github.io/rollr2/) for ggplot2 visualisations
of roll outcomes.
