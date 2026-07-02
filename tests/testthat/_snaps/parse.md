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

# parse_notation reads a success comparator and its integer target (AC-1)

    Code
      parse_notation("5d10>=8")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 5
      
      $terms[[1]]$x
      [1] 10
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$compare_op
      [1] ">="
      
      $terms[[1]]$compare_target
      [1] 8
      
      
      

---

    Code
      parse_notation("6d6>=5")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 6
      
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
      
      $terms[[1]]$compare_op
      [1] ">="
      
      $terms[[1]]$compare_target
      [1] 5
      
      
      

---

    Code
      parse_notation("5d10>8")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 5
      
      $terms[[1]]$x
      [1] 10
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$compare_op
      [1] ">"
      
      $terms[[1]]$compare_target
      [1] 8
      
      
      

---

    Code
      parse_notation("5d10<=3")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 5
      
      $terms[[1]]$x
      [1] 10
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$compare_op
      [1] "<="
      
      $terms[[1]]$compare_target
      [1] 3
      
      
      

---

    Code
      parse_notation("5d10<3")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 5
      
      $terms[[1]]$x
      [1] 10
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$compare_op
      [1] "<"
      
      $terms[[1]]$compare_target
      [1] 3
      
      
      

# a success comparator accepts the count-omitted and case variants (AC-1)

    Code
      parse_notation("d10>=8")
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
      [1] 10
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$compare_op
      [1] ">="
      
      $terms[[1]]$compare_target
      [1] 8
      
      
      

---

    Code
      parse_notation("5D10>=8")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 5
      
      $terms[[1]]$x
      [1] 10
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$compare_op
      [1] ">="
      
      $terms[[1]]$compare_target
      [1] 8
      
      
      

---

    Code
      parse_notation("5d10 >= 8")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 5
      
      $terms[[1]]$x
      [1] 10
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$compare_op
      [1] ">="
      
      $terms[[1]]$compare_target
      [1] 8
      
      
      

# a degenerate but well-formed success target parses without error (AC-10)

    Code
      parse_notation("5d10>=1")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 5
      
      $terms[[1]]$x
      [1] 10
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$compare_op
      [1] ">="
      
      $terms[[1]]$compare_target
      [1] 1
      
      
      

---

    Code
      parse_notation("5d10>=11")
    Output
      $terms
      $terms[[1]]
      $terms[[1]]$kind
      [1] "dice"
      
      $terms[[1]]$sign
      [1] 1
      
      $terms[[1]]$n
      [1] 5
      
      $terms[[1]]$x
      [1] 10
      
      $terms[[1]]$m
      [1] 0
      
      $terms[[1]]$keep
      [1] NA
      
      $terms[[1]]$keep_n
      [1] NA
      
      $terms[[1]]$explode
      [1] "none"
      
      $terms[[1]]$compare_op
      [1] ">="
      
      $terms[[1]]$compare_target
      [1] 11
      
      
      

# a comparator combined with a keep selector is rejected (AC-2)

    Code
      parse_notation("5d10h3>=8")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10h3>=8".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

---

    Code
      parse_notation("5d10>=8h3")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10>=8h3".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

# a comparator combined with an explode marker is rejected (AC-2)

    Code
      parse_notation("5d10!>=8")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10!>=8".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

---

    Code
      parse_notation("5d10>=8!")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10>=8!".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

# a comparator combined with a modifier is rejected (AC-2)

    Code
      parse_notation("5d10>=8+2")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10>=8+2".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

---

    Code
      parse_notation("5d10+2>=8")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10+2>=8".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

# a comparator inside a multi-term notation is rejected (AC-2)

    Code
      parse_notation("5d10>=8+1d6")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10>=8+1d6".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

---

    Code
      parse_notation("5d10>=8-1d4")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10>=8-1d4".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

---

    Code
      parse_notation("2+5d10>=8")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "2+5d10>=8".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

# a malformed comparator or target is rejected (AC-2)

    Code
      parse_notation("5d10>=")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10>=".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

---

    Code
      parse_notation("5d10>=8.5")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10>=8.5".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

---

    Code
      parse_notation("5d10>>8")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10>>8".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

---

    Code
      parse_notation("5d10=>8")
    Condition
      Error in `parse_notation()`:
      ! A success pool must be a single dice term with a comparator, like "5d10>=8".
      i Received "5d10=>8".
      i A comparator (>=, >, <=, <) against an integer target cannot combine with a keep selector, explode marker, modifier, or another term.

---

    Code
      parse_notation("5d10==8")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "5d10==8".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

# a success pool reuses the count and die-size validation (AC-2)

    Code
      parse_notation("0d10>=5")
    Condition
      Error in `parse_notation()`:
      ! Number of dice must be a positive integer.
      i Received 0 in "0d10>=5".

---

    Code
      parse_notation("5d1>=1")
    Condition
      Error in `parse_notation()`:
      ! Die size must be an integer of at least 2.
      i Received 1 in "5d1>=1".

