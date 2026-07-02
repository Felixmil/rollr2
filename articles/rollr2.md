# Get started with rollr2

``` r

library(rollr2)
```

`rollr2` turns tabletop RPG dice notation into simulated rolls. This
article walks through rolling once and reading the result, summarising
the distribution of many rolls, and the full notation grammar the parser
accepts.

Both [`roll()`](https://felixmil.github.io/rollr2/reference/roll.md) and
[`roll_distribution()`](https://felixmil.github.io/rollr2/reference/roll_distribution.md)
draw random numbers, so their output varies run to run. Fix a seed with
[`set.seed()`](https://rdrr.io/r/base/Random.html) whenever you want
reproducible results, as this article does throughout.

## Roll once

[`roll()`](https://felixmil.github.io/rollr2/reference/roll.md) takes a
single notation string and returns a `roll` object. Printing it shows
the notation, the individual dice, and the adjusted total.

``` r

set.seed(1)
r <- roll("2d20+2")
r
#> <roll> 2d20+2
#> Dice:  4, 7
#> Total: 13
```

A `roll` object is a list. The three fields you will use most are:

- `dice`: an integer vector of every die rolled (across all terms, in
  order, when the notation has several).
- `kept`: the dice that contribute to the total (equal to `dice` when
  there is no keep selector).
- `total`: the grand total, the sum of every term’s kept dice plus its
  modifier.

For a multi-term notation, `terms` holds the per-term breakdown (each
term’s own `dice`, `kept`, and `subtotal`), while `dice` and `kept` stay
the concatenation across terms.

``` r

r$dice
#> [1] 4 7
r$kept
#> [1] 4 7
r$total
#> [1] 13
```

When the notation carries a keep selector, `kept` is a subset of `dice`
and the printout gains a `Kept:` line. Here `4d6h3` rolls four six-sided
dice and keeps the highest three.

``` r

set.seed(1)
kept_roll <- roll("4d6h3")
kept_roll
#> <roll> 4d6h3
#> Dice:  1, 4, 1, 2
#> Kept:  4, 2, 1
#> Total: 7

kept_roll$dice
#> [1] 1 4 1 2
kept_roll$kept
#> [1] 4 2 1
kept_roll$total
#> [1] 7
```

## Add several terms together

A notation can be a sum of several terms joined by `+` or `-`, so you
can add different dice and constants in one call. Each term is the
grammar above (its own dice, optional keep selector, optional modifier),
a `-` before a term subtracts its whole contribution, and a bare integer
is a constant term. Keep selection applies within a term only; there is
no keep across the whole expression.

``` r

set.seed(1)
mixed <- roll("1d20+1d6+3")
mixed
#> <roll> 1d20+1d6+3
#> Dice:  4
#> Dice:  1
#> Total: 8
```

The printout shows one `Dice:` line per dice term and a single grand
`Total:`. The per-term detail lives in `terms`.

``` r

mixed$total
#> [1] 8
mixed$terms[[1]]$subtotal
#> [1] 4
mixed$terms[[2]]$subtotal
#> [1] 4
```

A `-` before a term subtracts it, and a keep selector still applies
within its own term, as in `2d20h+2d20l` (advantage plus disadvantage)
or `2d20h-1d6`.

``` r

set.seed(1)
roll("2d20h+2d20l")
#> <roll> 2d20h+2d20l
#> Dice:  4, 7
#> Kept:  7
#> Dice:  1, 2
#> Kept:  1
#> Total: 8
```

## Summarise many rolls

[`roll_distribution()`](https://felixmil.github.io/rollr2/reference/roll_distribution.md)
rolls the whole notation `n` times and summarises the distribution of
totals. Its print method shows the possible total range, a count per
observed outcome, and a text histogram.

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

The returned `roll_distribution` object stores the observed totals in
`counts`, a named integer vector whose names are the outcome totals
(ascending, with zero-count outcomes dropped), plus the theoretical
`range` of possible totals.

``` r

d <- roll_distribution("2d6", n = 1000)
d$counts
#>   2   3   4   5   6   7   8   9  10  11  12 
#>  22  60  81 102 130 170 135 120  95  56  29
d$range
#> [1]  2 12
```

## Notation grammar

The parser accepts the following forms. The leading `d` is
case-insensitive and surrounding whitespace is tolerated.

| Form            | Meaning                                         | Example  |
|-----------------|-------------------------------------------------|----------|
| `NdX`           | Roll `N` dice with `X` sides                    | `3d6`    |
| `dX`            | Count omitted, defaults to one die              | `d20`    |
| `NdX+M`         | Add a modifier `M` to the total                 | `2d20+2` |
| `NdX-M`         | Subtract a modifier `M` from the total          | `1d8-1`  |
| `NdXhK`         | Keep the highest `K` dice                       | `4d6h3`  |
| `NdXlK`         | Keep the lowest `K` dice                        | `3d6l2`  |
| `NdXh` / `NdXl` | Keep count omitted, defaults to keeping one die | `2d20h`  |

The keep selector follows the die size and comes before the modifier, so
a full notation reads count, die size, optional keep selector, optional
modifier, for example `4d6h3+1`.

### Summing several terms

Several terms may be joined with `+` or `-` into one notation, and a
bare integer is a constant term.

| Form          | Meaning                              | Example      |
|---------------|--------------------------------------|--------------|
| `TERM + TERM` | Add each term’s contribution         | `1d20+1d6`   |
| `TERM - TERM` | Subtract a term’s whole contribution | `2d20h-1d6`  |
| `... + K`     | A bare integer is a constant term    | `1d20+1d6+3` |

At least one dice term is required (a pure number like `3` is not valid
notation), and each keep selector applies within its own term only.

A bare `+M`/`-M` immediately after a dice term binds as that term’s
modifier when the term has no modifier yet, exactly as in the
single-term case: `1d6+3` is one dice term with modifier `+3`, and
`2d6+2+1d4` is a modified dice term (`2d6+2`) plus a second dice term. A
further signed integer, once the term already has a modifier, becomes a
standalone constant term: `1d6+3+1` is a dice term with modifier `+3`
plus a constant `+1`.

### Defaults

- A missing die count means one die (`d6` is the same as `1d6`).
- A missing modifier means no adjustment (`M = 0`).
- A missing keep count means keep one die (`2d20h` keeps the single
  highest die).

### Enforced limits

The parser rejects notation outside these bounds with a clear error:

- The die count must be a positive integer.
- The die size must be an integer of at least 2.
- The keep count must be between 1 and the die count (keeping zero dice,
  or more dice than were rolled, is rejected).

Non-integer counts, die sizes, and keep counts (such as `2.5d6` or
`2d6h1.5`) do not parse.
