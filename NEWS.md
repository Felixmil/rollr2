# rollr2 0.0.0.9000

* `roll()` rolls a dice-notation string once, returning the individual die results and the total (sum of dice plus modifier).
* `roll_distribution()` rolls a dice-notation string many times and summarises the distribution of totals, printing counts per outcome and a text histogram at the console.
* Both functions accept notation of the form `NdX`, `NdX+M`, `NdX-M`, and the count-omitted `dX` variants (case-insensitive `d`, whitespace-tolerant), plus an optional keep selector `h`/`l` after the die size that keeps only the highest or lowest `K` dice (e.g. `2d20h`, `4d6h3`, `3d6l2`, defaulting to `K = 1`); they reject invalid notation, non-positive or non-integer die counts, die sizes below 2, keep counts of zero or exceeding the die count, and non-positive-integer repetition counts with clear errors.
