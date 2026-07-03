# parse_notation extracts components from a full NdX+M form

    Code
      parse_notation("2d20+2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 2
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# parse_notation defaults a missing modifier to zero

    Code
      parse_notation("4d6")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# parse_notation handles a negative modifier

    Code
      parse_notation("1d8-1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 8
      
      $terms[[1]]$m
      [1] -1
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# parse_notation defaults a missing count to one

    Code
      parse_notation("d20")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# parse_notation is case-insensitive and whitespace-tolerant

    Code
      parse_notation("2D20 + 2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 2
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation(" 2d20 + 2 ")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 2
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# parse_notation reads keep-highest and keep-lowest selectors

    Code
      parse_notation("2d20h")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 1
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("2d20l")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "l"
      
      $terms[[1]]$keep_n
      [1] 1
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("4d6h3")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("3d6l2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 3
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "l"
      
      $terms[[1]]$keep_n
      [1] 2
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# a count-omitted die with a selector keeps the single die

    Code
      parse_notation("d20h")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 1
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# selectors are case-insensitive and compose with a modifier

    Code
      parse_notation("2D20H")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 1
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("4d6h3 + 2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 2
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# a keep count equal to the die count is valid and keeps all

    Code
      parse_notation("3d6h3")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 3
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# an invalid keep count is rejected

    Code
      parse_notation("2d20h0")
    Condition
      Error in `parse_notation()`:
      ! Keep count must be at least 1.
      i Received keep count 0 in "2d20h0".

---

    Code
      parse_notation("2d6h5")
    Condition
      Error in `parse_notation()`:
      ! Keep count cannot exceed the number of dice.
      i Received keep count 5 for 2 dice in "2d6h5".

# a malformed selector is rejected as invalid notation

    Code
      parse_notation("2d6h-1")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6h-1".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6h1.5")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6h1.5".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# parse_notation reads the explode-once and explode-indefinitely markers (AC-1)

    Code
      parse_notation("2d6!")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "once"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("2d6!!")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "indef"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("d6!")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "once"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# the explode marker composes with a keep selector and a modifier (AC-1)

    Code
      parse_notation("4d6!h3")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "once"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("4d6!!l2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "l"
      
      $terms[[1]]$keep_n
      [1] 2
      
      $terms[[1]]$explode
      [1] "indef"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("2d6!+1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 1
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "once"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("2d6!!-2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] -2
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "indef"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# the explode marker parses inside a multi-term notation (AC-1)

    Code
      parse_notation("1d20+2d6!")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 2
      
      $terms[[2]]$x
      [1] 6
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "once"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("2d6!!+1d4")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "indef"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 4
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

# a marker after the selector or modifier is rejected (AC-2)

    Code
      parse_notation("2d6h!")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6h!".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6h3!")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6h3!".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6+1!")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6+1!".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# a stray count after the marker or an over-long marker is rejected (AC-2)

    Code
      parse_notation("2d6!3")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6!3".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6!!!")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6!!!".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# a malformed selector after a valid marker is rejected as its non-explode form does (AC-2)

    Code
      parse_notation("2d6!h-1")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6!h-1".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6!h1.5")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6!h1.5".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# parse_notation reads the drop-lowest, drop-highest, and shorthand forms (AC-1)

    Code
      parse_notation("4d6dl1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("4d6dh1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "l"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("4d6d1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("4d6dl")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("4d6dh")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "l"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

# the drop selector composes with an explode marker and a multi-term notation (AC-1)

    Code
      parse_notation("4d6!dl1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "once"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("4d6dl1+1d8")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 8
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

# a drop count outside 1 <= K <= N - 1 is rejected as a keep error (AC-3)

    Code
      parse_notation("4d6dl0")
    Condition
      Error in `parse_notation()`:
      ! Drop count must be at least 1.
      i Received drop count 0 in "4d6dl0".

---

    Code
      parse_notation("4d6dl4")
    Condition
      Error in `parse_notation()`:
      ! Drop count cannot leave fewer than one die.
      i Received drop count 4 for 4 dice in "4d6dl4".

---

    Code
      parse_notation("4d6dl5")
    Condition
      Error in `parse_notation()`:
      ! Drop count cannot leave fewer than one die.
      i Received drop count 5 for 4 dice in "4d6dl5".

---

    Code
      parse_notation("1d6dl1")
    Condition
      Error in `parse_notation()`:
      ! Drop count cannot leave fewer than one die.
      i Received drop count 1 for 1 dice in "1d6dl1".

# a multi-term drop-count error names the offending term (AC-3)

    Code
      parse_notation("4d6dl4+1d4")
    Condition
      Error in `parse_notation()`:
      ! Drop count cannot leave fewer than one die.
      i Received drop count 4 for 4 dice in term "4d6dl4" of "4d6dl4+1d4".

# a term mixing keep and drop is rejected as invalid notation (AC-3)

    Code
      parse_notation("4d6h3dl1")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "4d6h3dl1".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("4d6dl1h2")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "4d6dl1h2".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# a malformed drop selector is rejected as invalid notation (AC-3)

    Code
      parse_notation("4d6dl-1")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "4d6dl-1".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("4d6dl1.5")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "4d6dl1.5".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# parse_notation reads the reroll-once and reroll-until markers (AC-1)

    Code
      parse_notation("2d6r1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "once"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

---

    Code
      parse_notation("1d20rr1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "until"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

---

    Code
      parse_notation("d20r1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "once"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

---

    Code
      parse_notation("d20rr1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "until"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

# the reroll marker letter is case-insensitive (AC-1)

    Code
      parse_notation("2D6R1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "once"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

---

    Code
      parse_notation("1d20RR1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "until"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

# the reroll marker composes with a keep selector and a modifier (AC-1)

    Code
      parse_notation("4d6r1h3")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "once"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

---

    Code
      parse_notation("4d6rr1l2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "l"
      
      $terms[[1]]$keep_n
      [1] 2
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "until"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

---

    Code
      parse_notation("2d6r1+2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 2
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "once"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

---

    Code
      parse_notation("2d6rr1-1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] -1
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "until"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

---

    Code
      parse_notation("4d6r1h3+2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 4
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 2
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 3
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "once"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      

# the reroll marker parses inside a multi-term notation (AC-1)

    Code
      parse_notation("1d20+2d6r1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 2
      
      $terms[[2]]$x
      [1] 6
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "once"
      
      $terms[[2]]$reroll_t
      [1] 1
      
      
      

---

    Code
      parse_notation("2d6rr1+1d4")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "until"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 4
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("2d6r1-1d4")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "once"
      
      $terms[[1]]$reroll_t
      [1] 1
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] -1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 4
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

# a missing reroll threshold is rejected as invalid notation (AC-2)

    Code
      parse_notation("2d6r")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6r".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6rr")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6rr".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# a malformed reroll marker is rejected as invalid notation (AC-2)

    Code
      parse_notation("2d6rrr1")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6rrr1".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6r1.5")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6r1.5".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# an out-of-range reroll threshold names the threshold and die size (AC-2)

    Code
      parse_notation("2d6r0")
    Condition
      Error in `parse_notation()`:
      ! Reroll threshold must be between 1 and the die size minus 1.
      i Received threshold 0 for a 6-sided die in "2d6r0".

---

    Code
      parse_notation("2d6r6")
    Condition
      Error in `parse_notation()`:
      ! Reroll threshold must be between 1 and the die size minus 1.
      i Received threshold 6 for a 6-sided die in "2d6r6".

---

    Code
      parse_notation("2d6rr6")
    Condition
      Error in `parse_notation()`:
      ! Reroll threshold must be between 1 and the die size minus 1.
      i Received threshold 6 for a 6-sided die in "2d6rr6".

---

    Code
      parse_notation("1d20rr20")
    Condition
      Error in `parse_notation()`:
      ! Reroll threshold must be between 1 and the die size minus 1.
      i Received threshold 20 for a 20-sided die in "1d20rr20".

---

    Code
      parse_notation("2d6r6+1d4")
    Condition
      Error in `parse_notation()`:
      ! Reroll threshold must be between 1 and the die size minus 1.
      i Received threshold 6 for a 6-sided die in term "2d6r6" of "2d6r6+1d4".

# a term carrying both a reroll and an explode marker is rejected (AC-2)

    Code
      parse_notation("2d6!r1")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6!r1".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6r1!")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6r1!".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6rr1!!")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6rr1!!".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6!!rr1")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6!!rr1".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# a reroll marker after the selector or modifier is rejected (AC-2)

    Code
      parse_notation("2d6h1r1")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6h1r1".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2d6+1r1")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2d6+1r1".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# a valid threshold reports the keep-count error, not the reroll error (AC-2)

    Code
      parse_notation("4d6r1h5")
    Condition
      Error in `parse_notation()`:
      ! Keep count cannot exceed the number of dice.
      i Received keep count 5 for 4 dice in "4d6r1h5".

# unparseable notation is rejected

    Code
      parse_notation("abc")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "abc".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2x20")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2x20".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("2.5d6")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "2.5d6".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# non-string or non-length-1 input is rejected

    Code
      parse_notation(character(0))
    Condition
      Error in `parse_notation()`:
      ! `notation` must be a single non-missing string.
      i Received character of length 0.

---

    Code
      parse_notation(c("2d6", "1d8"))
    Condition
      Error in `parse_notation()`:
      ! `notation` must be a single non-missing string.
      i Received character of length 2.

---

    Code
      parse_notation(206)
    Condition
      Error in `parse_notation()`:
      ! `notation` must be a single non-missing string.
      i Received numeric of length 1.

---

    Code
      parse_notation(NA_character_)
    Condition
      Error in `parse_notation()`:
      ! `notation` must be a single non-missing string.
      i Received character of length 1.

# a die count below one is rejected

    Code
      parse_notation("0d6")
    Condition
      Error in `parse_notation()`:
      ! Number of dice must be a positive integer.
      i Received 0 in "0d6".

# a degenerate or invalid die size is rejected

    Code
      parse_notation("1d1")
    Condition
      Error in `parse_notation()`:
      ! Die size must be an integer of at least 2.
      i Received 1 in "1d1".

---

    Code
      parse_notation("d0")
    Condition
      Error in `parse_notation()`:
      ! Die size must be an integer of at least 2.
      i Received 0 in "d0".

# parse_notation reads a sum of dice terms plus a constant (AC-1)

    Code
      parse_notation("2d20h+1d6+1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 1
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 6
      
      $terms[[2]]$m
      [1] 1
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("2d20h+2d20l")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 1
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 2
      
      $terms[[2]]$x
      [1] 20
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] "l"
      
      $terms[[2]]$keep_n
      [1] 1
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("1d20+1d6+1d4+3")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 6
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      $terms[[3]]
      $terms[[3]]$kind
      [1] "dice"
      
      $terms[[3]]$sign
      [1] 1
      
      $terms[[3]]$n
      [1] 1
      
      $terms[[3]]$x
      [1] 4
      
      $terms[[3]]$m
      [1] 3
      
      $terms[[3]]$keep
      [1] NA
      
      $terms[[3]]$keep_n
      [1] NA
      
      $terms[[3]]$explode
      [1] "none"
      
      $terms[[3]]$reroll
      [1] "none"
      
      $terms[[3]]$reroll_t
      [1] NA
      
      
      

# a leading `+M`/`-M` binds as the term modifier under the locked rule

    Code
      parse_notation("2d20+2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 2
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("1d6+3")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 3
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("2d6+2+1d4")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 2
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 4
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

---

    Code
      parse_notation("1d6+3+1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 3
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "const"
      
      $terms[[2]]$value
      [1] 1
      
      
      

# a negated dice term captures a -1 sign

    Code
      parse_notation("2d20h-1d6")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 2
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] "h"
      
      $terms[[1]]$keep_n
      [1] 1
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] -1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 6
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

# a leading bare constant is accepted since terms commute

    Code
      parse_notation("3+1d20")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "const"
      
      $terms[[1]]$value
      [1] 3
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 20
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

# whitespace-separated terms and signs parse

    Code
      parse_notation("1d20 + 1d6 - 2")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 20
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 6
      
      $terms[[2]]$m
      [1] -2
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

# a repeated identical term is not merged at the object level

    Code
      parse_notation("1d6+1d6")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 1
      
      $terms[[1]]$x
      [1] 6
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$reroll
      [1] "none"
      
      $terms[[1]]$reroll_t
      [1] NA
      
      
      $terms[[2]]
      $terms[[2]]$kind
      [1] "dice"
      
      $terms[[2]]$sign
      [1] 1
      
      $terms[[2]]$n
      [1] 1
      
      $terms[[2]]$x
      [1] 6
      
      $terms[[2]]$m
      [1] 0
      
      $terms[[2]]$keep
      [1] NA
      
      $terms[[2]]$keep_n
      [1] NA
      
      $terms[[2]]$explode
      [1] "none"
      
      $terms[[2]]$reroll
      [1] "none"
      
      $terms[[2]]$reroll_t
      [1] NA
      
      
      

# a per-term validation error names the offending term

    Code
      parse_notation("2d6h5+1d4")
    Condition
      Error in `parse_notation()`:
      ! Keep count cannot exceed the number of dice.
      i Received keep count 5 for 2 dice in term "2d6h5" of "2d6h5+1d4".

---

    Code
      parse_notation("0d6+1d4")
    Condition
      Error in `parse_notation()`:
      ! Number of dice must be a positive integer.
      i Received 0 in term "0d6" of "0d6+1d4".

# malformed joins and pure-constant notation are rejected

    Code
      parse_notation("1d6++1d6")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "1d6++1d6".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("1d6+")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "1d6+".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("+")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "+".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("3")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "3".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("1+2")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "1+2".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

---

    Code
      parse_notation("1d6 1d6")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "1d6 1d6".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

