# Summarise the outcome distribution of repeated rolls

Simulates `n` whole-notation rolls and summarises the distribution of
the resulting totals. The distribution is sampled (not computed
analytically), so results vary run to run unless a seed is fixed with
[`set.seed()`](https://rdrr.io/r/base/Random.html). A keep selector
(`h`/`l`) is applied per simulated roll before summing, so each total
reflects the kept dice plus the modifier.

## Usage

``` r
roll_distribution(notation, n)

# S3 method for class 'roll_distribution'
print(x, ...)

# S3 method for class 'roll_distribution'
plot(x, ...)
```

## Arguments

- notation:

  A length-1 character string in the form `NdX`, `NdX+M`, `NdX-M`, or
  the count-omitted `dX` variants (case-insensitive `d`,
  whitespace-tolerant). An optional keep selector `h`/`l` with an
  optional count may follow the die size (e.g. `2d20h`, `4d6h3`),
  keeping the highest/lowest `K` dice per roll (defaulting to `K = 1`).

- n:

  Number of whole-notation rolls to simulate. A positive integer.

- x:

  A `roll_distribution` object, as returned by `roll_distribution()`.

- ...:

  Ignored, for compatibility with the
  [`print()`](https://rdrr.io/r/base/print.html) and
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) generics.

## Value

A `roll_distribution` object: a list with `counts` (an integer vector of
observed totals, named by outcome value, ordered ascending; zero-count
outcomes are omitted), `range` (the theoretical `c(min, max)` of a
total, `c(K + M, K * X + M)` where `K` is the kept count, equal to the
die count `N` when there is no selector), `n`, the parsed components
`dice_n`, `x`, `m`, `keep`, `keep_n`, and the original `notation`. Its
[`print()`](https://rdrr.io/r/base/print.html) method renders the counts
and a text histogram for the console.

## Details

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns a
themed
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
bar chart of the sampled counts across the notation's theoretical total
range. The returned object auto-prints when called at the top level and
can be captured and extended with `+`.

## Examples

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
#> 
roll_distribution("4d6h3", n = 1000)
#> <roll_distribution> 4d6h3
#> Rolls: 1000  Possible total range: 3 to 18
#> 
#>  4 | #   4
#>  5 | ###  11
#>  6 | ####  13
#>  7 | #######  25
#>  8 | ##############  48
#>  9 | #################  60
#> 10 | ###########################  95
#> 11 | ############################## 105
#> 12 | ##################################### 131
#> 13 | ################################### 124
#> 14 | ######################################## 140
#> 15 | ################################ 113
#> 16 | #####################  73
#> 17 | ###########  40
#> 18 | #####  18
#> 
```
