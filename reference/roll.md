# Roll dice from notation once

Parses a dice-notation string and simulates a single roll. A notation
may be a sum of several terms joined by `+`/`-` (for example
`1d20+1d6+3`); each dice term draws `N` independent uniform values from
`1..X`, keeps the highest/lowest `K` when it carries a selector, and
contributes its kept sum plus its own modifier `M`. A `-` before a term
subtracts that term's whole contribution. Bare integer terms (constants)
are added directly. The grand `total` is the sum of every term's signed
contribution.

## Usage

``` r
roll(notation, compare = FALSE)

# S3 method for class 'roll'
print(x, ...)

# S3 method for class 'roll'
plot(x, ...)
```

## Arguments

- notation:

  A length-1 character string. A single dice term is `NdX`, `NdX+M`,
  `NdX-M`, or the count-omitted `dX` variants (case-insensitive `d`,
  whitespace-tolerant), optionally with a keep selector `h`/`l` and an
  optional count after the die size (e.g. `2d20h`, `4d6h3`, `3d6l2`),
  which keeps the highest (`h`) or lowest (`l`) `K` dice (defaulting to
  `K = 1`). A per-die marker may follow the die size, before any keep
  selector or modifier: either an explode marker or a reroll marker, but
  not both (they are mutually exclusive within a term). The explode
  marker is `!` (rerolls a maximum-face die exactly once and sums the
  two faces; the extra die does not itself explode) or `!!` (keeps
  rerolling while the maximum recurs, capped at 100 chained rerolls per
  die). So `2d6!`, `2d6!!`, `4d6!h3`, and `2d6!+1` are all valid. When a
  `!!` die reaches the cap, `roll()` emits a warning while still
  returning a valid roll. The reroll marker is `rT` (rerolls any die
  showing `<= T` exactly once and keeps the new value unconditionally,
  even if it is also `<= T`) or `rrT` (rerolls a die showing `<= T`
  repeatedly until it lands strictly above `T`), where the threshold `T`
  is required and bounded `1 <= T <= X - 1`. Contrast the explode
  marker: reroll replaces the die's value, it does not sum. So `2d6r1`,
  `1d20rr1`, `4d6r1h3`, and `2d6r1+2` are all valid, and reroll never
  warns. Several such terms, plus bare integer constants, may be joined
  with `+` or `-` into one notation (e.g. `1d20+1d6`, `2d20h+2d20l`,
  `1d20+1d6+1d4+3`); at least one dice term is required and each keep
  selector applies within its own term only. See
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
  [`print()`](https://rdrr.io/r/base/print.html) and
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) generics.

## Value

A `roll` object: a list with `dice` (integer vector listing every die
rolled, the concatenation of all dice terms in term order), `total`
(integer scalar grand total: the sum of each term's signed
contribution), `kept` (the dice that contribute, the concatenation of
each term's kept dice in term order), `terms` (the per-term breakdown,
each element a list with the term's parsed fields plus its `dice`,
`kept`, and `subtotal`), the original `notation`, and `compare` (the
logical flag controlling the print method). For a single-term notation
the parsed components `n`, `x`, `m`, `keep`, `keep_n`, `explode`,
`reroll`, `reroll_t` are also present at the top level; they are omitted
for a multi-term notation, where per-term access via `terms` is
required. For an exploding or reroll term `dice` still lists every
physical die including rerolls in draw order (for a reroll term, the
rerolled-away faces are listed too), and `kept` lists the kept per-die
values.

## Details

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns a
themed
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
bar chart of the notation's exact theoretical outcome distribution, with
the rolled total's bar highlighted and its percentile standing shown in
the subtitle. The plot always shows the theoretical distribution and
never reads `compare`, which remains a print-only switch. The returned
object auto-prints when called at the top level and can be captured and
extended with `+`.

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
roll("1d20+1d6+3")
#> <roll> 1d20+1d6+3
#> Dice:  18
#> Dice:  3
#> Total: 24
roll("2d6", compare = TRUE)
#> <roll> 2d6
#> Dice:  3, 1
#> Total: 4
#> 
#> Distribution for 2d6: this roll beats 8% of outcomes
#>  2 | #######  7
#>  3 | ############# 13
#>  4 | #################### 20 <- this roll
#>  5 | ########################### 27
#>  6 | ################################# 33
#>  7 | ######################################## 40
#>  8 | ################################# 33
#>  9 | ########################### 27
#> 10 | #################### 20
#> 11 | ############# 13
#> 12 | #######  7
#> 
```
