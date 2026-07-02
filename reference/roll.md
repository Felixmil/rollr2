# Roll dice from notation once

Parses a dice-notation string and simulates a single roll: `N`
independent uniform draws from `1..X`, summed and adjusted by the
modifier `M`. When the notation carries a keep selector (`h`/`l`), only
the highest or lowest `K` of the rolled dice contribute to the total;
the modifier is still applied once to that kept sum.

## Usage

``` r
roll(notation, compare = FALSE)

# S3 method for class 'roll'
print(x, ...)
```

## Arguments

- notation:

  A length-1 character string in the form `NdX`, `NdX+M`, `NdX-M`, or
  the count-omitted `dX` variants (case-insensitive `d`,
  whitespace-tolerant). An optional keep selector `h`/`l` with an
  optional count may follow the die size (e.g. `2d20h`, `4d6h3`,
  `3d6l2`); it keeps the highest (`h`) or lowest (`l`) `K` dice,
  defaulting to `K = 1`. See
  [`roll_distribution()`](https://felixmil.github.io/rollr2/reference/roll_distribution.md)
  to summarise many rolls.

- compare:

  A length-1 logical. When `TRUE`, printing the roll also shows where
  the total sits within the notation's full theoretical outcome
  distribution: a header line stating what percent of outcomes the roll
  beats, then a text histogram of the exact outcome probabilities with
  the rolled total's bar marked. Defaults to `FALSE`, which prints only
  the roll itself. The comparison is computed, not sampled, so a given
  (notation, total) pair always reports the same standing.

- x:

  A `roll` object, as returned by `roll()`.

- ...:

  Ignored, for compatibility with the
  [`print()`](https://rdrr.io/r/base/print.html) generic.

## Value

A `roll` object: a list with `dice` (integer vector of length `N`, each
in `1..X`, listing every die rolled), `total` (integer scalar equal to
the sum of the kept dice plus `M`), `kept` (the kept dice, equal to
`dice` when there is no selector), the parsed components `n`, `x`, `m`,
`keep`, `keep_n`, the original `notation`, and `compare` (the logical
flag from the argument, controlling the print method).

## Examples

``` r
set.seed(1)
roll("2d20+2")
#> <roll> 2d20+2
#> Dice:  4, 7
#> Total: 13
roll("d6")
#> <roll> d6
#> Dice:  1
#> Total: 1
roll("4d6h3")
#> <roll> 4d6h3
#> Dice:  2, 5, 3, 6
#> Kept:  6, 5, 3
#> Total: 14
roll("2d6", compare = TRUE)
#> <roll> 2d6
#> Dice:  2, 3
#> Total: 5
#> 
#> Distribution for 2d6: this roll beats 17% of outcomes
#>  2 | #######  7
#>  3 | ############# 13
#>  4 | #################### 20
#>  5 | ########################### 27 <- this roll
#>  6 | ################################# 33
#>  7 | ######################################## 40
#>  8 | ################################# 33
#>  9 | ########################### 27
#> 10 | #################### 20
#> 11 | ############# 13
#> 12 | #######  7
#> 
```
