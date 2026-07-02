# Changelog

## rollr2 0.0.0.9000

- [`plot.roll()`](https://felixmil.github.io/rollr2/reference/roll.md)
  returns a themed ggplot of the notation’s exact outcome distribution
  with the rolled total’s bar highlighted and its percentile standing in
  the subtitle; it always shows the theoretical distribution and ignores
  the `compare` flag.
- [`plot.roll_distribution()`](https://felixmil.github.io/rollr2/reference/roll_distribution.md)
  returns a themed ggplot bar chart of the sampled totals across the
  notation’s range.
- [`roll()`](https://felixmil.github.io/rollr2/reference/roll.md) rolls
  a dice-notation string once, returning the individual die results and
  the total (sum of dice plus modifier).
- [`roll()`](https://felixmil.github.io/rollr2/reference/roll.md) gains
  a `compare` argument that, when `TRUE`, prints the notation’s full
  outcome distribution as a text histogram with the rolled total’s bar
  marked and a header stating what percent of outcomes the roll beats;
  the standing is computed exactly (never sampled), so it is the same
  for a given notation and total across sessions. Defaults to `FALSE`,
  leaving existing output unchanged.
- [`roll_distribution()`](https://felixmil.github.io/rollr2/reference/roll_distribution.md)
  rolls a dice-notation string many times and summarises the
  distribution of totals, printing counts per outcome and a text
  histogram at the console.
- Both functions accept notation of the form `NdX`, `NdX+M`, `NdX-M`,
  and the count-omitted `dX` variants (case-insensitive `d`,
  whitespace-tolerant), plus an optional keep selector `h`/`l` after the
  die size that keeps only the highest or lowest `K` dice (e.g. `2d20h`,
  `4d6h3`, `3d6l2`, defaulting to `K = 1`); they reject invalid
  notation, non-positive or non-integer die counts, die sizes below 2,
  keep counts of zero or exceeding the die count, and
  non-positive-integer repetition counts with clear errors.
