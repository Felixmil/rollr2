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

set.seed(42)
r <- roll("2d20+2")
r
#> <roll> 2d20+2
#> Dice:  17, 5
#> Total: 24
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
#> [1] 17  5
r$kept
#> [1] 17  5
r$total
#> [1] 24
```

When the notation carries a keep selector, `kept` is a subset of `dice`
and the printout gains a `Kept:` line. Here `4d6h3` rolls four six-sided
dice and keeps the highest three.

``` r

set.seed(19)
kept_roll <- roll("4d6h3")
kept_roll
#> <roll> 4d6h3
#> Dice:  5, 2, 6, 3
#> Kept:  6, 5, 3
#> Total: 14

kept_roll$dice
#> [1] 5 2 6 3
kept_roll$kept
#> [1] 6 5 3
kept_roll$total
#> [1] 14
```

## Add several terms together

A notation can be a sum of several terms joined by `+` or `-`, so you
can add different dice and constants in one call. Each term is the
grammar above (its own dice, optional keep selector, optional modifier),
a `-` before a term subtracts its whole contribution, and a bare integer
is a constant term. Keep selection applies within a term only; there is
no keep across the whole expression.

``` r

set.seed(42)
mixed <- roll("1d20+1d6+3")
mixed
#> <roll> 1d20+1d6+3
#> Dice:  17
#> Dice:  5
#> Total: 25
```

The printout shows one `Dice:` line per dice term and a single grand
`Total:`. The per-term detail lives in `terms`.

``` r

mixed$total
#> [1] 25
mixed$terms[[1]]$subtotal
#> [1] 17
mixed$terms[[2]]$subtotal
#> [1] 8
```

A `-` before a term subtracts it, and a keep selector still applies
within its own term, as in `2d20h+2d20l` (advantage plus disadvantage)
or `2d20h-1d6`.

``` r

set.seed(42)
roll("2d20h+2d20l")
#> <roll> 2d20h+2d20l
#> Dice:  17, 5
#> Kept:  17
#> Dice:  1, 10
#> Kept:  1
#> Total: 18
```

## Summarise many rolls

[`roll_distribution()`](https://felixmil.github.io/rollr2/reference/roll_distribution.md)
rolls the whole notation `n` times and summarises the distribution of
totals. Its print method shows the possible total range, a count per
observed outcome, and a text histogram.

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

The returned `roll_distribution` object stores the observed totals in
`counts`, a named integer vector whose names are the outcome totals
(ascending, with zero-count outcomes dropped), plus the theoretical
`range` of possible totals.

``` r

d <- roll_distribution("2d6", n = 1000)
d$counts
#>   2   3   4   5   6   7   8   9  10  11  12 
#>  21  49  68 115 160 161 148 102  97  55  24
d$range
#> [1]  2 12
```

## Notation grammar

The parser accepts the following forms. The leading `d` is
case-insensitive and surrounding whitespace is tolerated.

| Form | Meaning | Example |
|----|----|----|
| `NdX` | Roll `N` dice with `X` sides | `3d6` |
| `dX` | Count omitted, defaults to one die | `d20` |
| `NdX+M` | Add a modifier `M` to the total | `2d20+2` |
| `NdX-M` | Subtract a modifier `M` from the total | `1d8-1` |
| `NdXhK` | Keep the highest `K` dice | `4d6h3` |
| `NdXlK` | Keep the lowest `K` dice | `3d6l2` |
| `NdXh` / `NdXl` | Keep count omitted, defaults to keeping one die | `2d20h` |
| `NdXdlK` | Drop the lowest `K` dice (inverse of keep) | `4d6dl1` |
| `NdXdhK` | Drop the highest `K` dice | `4d6dh1` |
| `NdXdK` / `NdXdl` / `NdXdh` | Shorthand `d` drops the lowest; a missing count drops one die | `4d6d1` |
| `NdXrT` | Reroll once any die showing `<= T`, keeping the new value | `2d6r2` |
| `NdXrrT` | Reroll a die showing `<= T` until it lands above `T` | `1d20rr1` |

The keep selector follows the die size and comes before the modifier, so
a full notation reads count, die size, optional keep selector, optional
modifier, for example `4d6h3+1`.

A drop selector occupies the same slot as the keep selector and is its
inverse spelling: dropping `K` of `N` dice keeps `N - K`, so `4d6dl1`
(drop the lowest of four d6, the conventional D&D ability-score roll) is
exactly `4d6h3`, and `4d6dh1` (drop the highest) is `4d6l3`. The
shorthand `4d6d1` drops the lowest, and a missing count (`4d6dl`) drops
one die. A term carries at most one selector, so keep and drop cannot be
combined.

### Rerolling low dice

Some systems reroll dice that land at or below a threshold. The reroll
marker follows the die size (before any keep selector or modifier) and
comes in two forms, both with a required threshold `T`. Under `rT`
(reroll once) any die showing a value `<= T` is rerolled exactly once
and the new value is kept unconditionally, even if it is also `<= T`.
This is the motivating case for D&D 5e Great Weapon Fighting, where a
damage die showing a 1 or 2 is rerolled once: `2d6r2`. Under `rrT`
(reroll until above) a die showing `<= T` is rerolled repeatedly until
it lands strictly above `T`, so `1d20rr1` yields a value uniform over
`2..20` and never a natural 1. The reroll marker composes with the keep
selector and the modifier (`4d6r1h3`, `2d6r1+2`).

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

### Success-counting pools

A trailing comparator against an integer target turns the whole notation
into a success-counting pool. Instead of summing faces, the pool counts
how many dice satisfy the comparator, so its outcome is a success count
in `0` to `N` rather than a total. This is how dice-pool systems (World
of Darkness, Shadowrun, and similar) resolve a roll.

| Form     | Meaning                          | Example   |
|----------|----------------------------------|-----------|
| `NdX>=T` | Count dice showing at least `T`  | `5d10>=8` |
| `NdX>T`  | Count dice showing more than `T` | `5d10>8`  |
| `NdX<=T` | Count dice showing at most `T`   | `5d10<=3` |
| `NdX<T`  | Count dice showing less than `T` | `5d10<3`  |

For example, `5d10>=8` rolls five ten-sided dice and counts how many
show 8, 9, or 10, and `6d6>=5` counts how many of six six-sided dice
show 5 or 6. Each die is an independent success with a fixed
probability, so the count follows a binomial distribution over `0` to
`N`, which `roll(compare = TRUE)` and the plot methods show exactly.

A success-counting notation stands alone: it is a single bare dice term
with a comparator, and it does not take a keep selector, an explode
marker, a modifier, or a `+`/`-` join with other terms or constants. The
four comparators above are the whole set.

### Defaults

- A missing die count means one die (`d6` is the same as `1d6`).
- A missing modifier means no adjustment (`M = 0`).
- A missing keep count means keep one die (`2d20h` keeps the single
  highest die).
- A missing drop count means drop one die (`4d6dl` drops the single
  lowest die), and the shorthand `d` drops the lowest (`4d6d1` is
  `4d6dl1`).

### Enforced limits

The parser rejects notation outside these bounds with a clear error:

- The die count must be a positive integer.
- The die size must be an integer of at least 2.
- The keep count must be between 1 and the die count (keeping zero dice,
  or more dice than were rolled, is rejected).
- The drop count must be between 1 and one less than the die count
  (dropping zero dice, or dropping every die so nothing is left to sum,
  is rejected).
- The reroll threshold `T` must be between 1 and the die size minus 1
  (`1 <= T <= X - 1`); a threshold of 0 never fires and a threshold at
  or above the die size is rejected, so `2d6r0` and `2d6r6` do not
  parse.

Non-integer counts, die sizes, and keep or drop counts (such as `2.5d6`,
`2d6h1.5`, or `4d6dl1.5`) do not parse.
