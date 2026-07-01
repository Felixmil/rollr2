# print.roll_distribution renders counts and a histogram

    Code
      print(roll_distribution("2d6", n = 100))
    Output
      <roll_distribution> 2d6
      Rolls: 100  Possible total range: 2 to 12
      
       2 | #####  2
       3 | ##############  6
       4 | ############################ 12
       5 | #########  4
       6 | ######################################## 17
       7 | ######################################## 17
       8 | ########################## 11
       9 | ############################### 13
      10 | #####################  9
      11 | ################  7
      12 | #####  2
      

# a non-positive-integer repetition count is rejected

    Code
      roll_distribution("2d6", n = 0)
    Condition
      Error in `validate_reps()`:
      ! `n` must be a single positive integer.
      i Received numeric of length 1 (value 0).

---

    Code
      roll_distribution("2d6", n = -5)
    Condition
      Error in `validate_reps()`:
      ! `n` must be a single positive integer.
      i Received numeric of length 1 (value -5).

---

    Code
      roll_distribution("2d6", n = 2.5)
    Condition
      Error in `validate_reps()`:
      ! `n` must be a single positive integer.
      i Received numeric of length 1 (value 2.5).

---

    Code
      roll_distribution("2d6", n = c(1, 2))
    Condition
      Error in `validate_reps()`:
      ! `n` must be a single positive integer.
      i Received numeric of length 2.

---

    Code
      roll_distribution("2d6", n = "many")
    Condition
      Error in `validate_reps()`:
      ! `n` must be a single positive integer.
      i Received character of length 1.

# roll_distribution surfaces parse errors

    Code
      roll_distribution("bad", n = 10)
    Condition
      Error in `parse_notation()`:
      ! `notation` is not valid dice notation.
      i Received "bad".
      i Expected a form like "2d20+2", "4d6", "1d8-1", or "d20".

