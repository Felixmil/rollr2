# rollr2

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

[`roll()`](https://felixmil.github.io/rollr2/reference/roll.md)
simulates a single roll and returns a `roll` object holding the
individual dice and the total. The functions are stochastic, so fix a
seed when you want reproducible output.

``` r

library(rollr2)

set.seed(42)
roll("2d20+2")
#> <roll> 2d20+2
#> Dice:  17, 5
#> Total: 24
```

A keep selector like `4d6h3` keeps only the highest (`h`) or lowest
(`l`) dice; the printout then shows which dice were kept. The inverse
drop spelling `4d6dl1` (drop the lowest of four d6, the conventional D&D
ability-score roll) is the same thing said the other way round.

``` r

set.seed(19)
roll("4d6h3")
#> <roll> 4d6h3
#> Dice:  5, 2, 6, 3
#> Kept:  6, 5, 3
#> Total: 14
```

A reroll marker like `2d6r2` rerolls once any die showing a value at or
below the threshold (here 2), keeping the new value; `rr` instead
rerolls until the die lands above the threshold. This is the D&D 5e
Great Weapon Fighting style reroll.

``` r

set.seed(7)
roll("2d6r2")
#> <roll> 2d6r2
#> Dice:  2, 3, 4
#> Total: 7
```

A notation can also sum several terms and constants, joined with `+` or
`-`.

``` r

set.seed(42)
roll("1d20+1d6+3")
#> <roll> 1d20+1d6+3
#> Dice:  17
#> Dice:  5
#> Total: 25
```

A trailing comparator like `5d10>=8` counts how many dice meet the
target instead of summing them, so the outcome is a success count rather
than a total.

``` r

set.seed(42)
roll("5d10>=8")
#> <roll> 5d10>=8
#> Dice:      1, 5, 1, 9, 10
#> Successes: 2 of 5 (faces >= 8)
```

## Summarise a distribution

[`roll_distribution()`](https://felixmil.github.io/rollr2/reference/roll_distribution.md)
rolls the whole notation many times and summarises the distribution of
totals, printing a count per outcome and a text histogram.

``` r

set.seed(42)
roll_distribution("2d6", n = 1000)
#> <roll_distribution> 2d6
#> Rolls: 1000  Possible total range: 2 to 12
#> 
#>  2 | #####  24
#>  3 | ###############  65
#>  4 | ####################  91
#>  5 | ####################### 104
#>  6 | ################################### 155
#>  7 | ######################################## 178
#>  8 | ############################ 126
#>  9 | ########################### 118
#> 10 | #################  77
#> 11 | #########  38
#> 12 | #####  24
```

## Learn more

See
[`vignette("rollr2")`](https://felixmil.github.io/rollr2/articles/rollr2.md)
to get started, and the “Visualising roll distributions” article on the
[package website](https://felixmil.github.io/rollr2/) for ggplot2
visualisations of roll outcomes.
