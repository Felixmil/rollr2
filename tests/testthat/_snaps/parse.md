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

