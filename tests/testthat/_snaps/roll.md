# print.roll renders notation, dice, and total

    Code
      print(roll("2d20+2"))
    Output
      <roll> 2d20+2
      Dice:  10, 19
      Total: 31

# roll surfaces parse errors

    Code
      roll("nonsense")
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "nonsense".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

