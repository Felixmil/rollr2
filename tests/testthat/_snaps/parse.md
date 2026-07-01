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

