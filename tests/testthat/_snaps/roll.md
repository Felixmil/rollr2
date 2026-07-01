# print.roll renders notation, dice, and total

    Code
      print(roll("2d20+2"))
    Output
      <roll> 2d20+2
      Dice:  10, 19
      Total: 31

# print.roll shows the kept dice when a selector is present

    Code
      print(roll("4d6h3"))
    Output
      <roll> 4d6h3
      Dice:  2, 3, 4, 2
      Kept:  4, 3, 2
      Total: 9

# roll surfaces parse errors

    Code
      roll("nonsense")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "nonsense".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

