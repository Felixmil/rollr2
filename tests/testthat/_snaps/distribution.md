# print.roll_distribution renders counts and a histogram

    Code
      print(roll_distribution("2d6", n = 100))
    Output
      <roll_distribution> 2d6
      Rolls: 100  Possible total range: 2 to 12
      
       2 | ###########  4
       3 | #######################  8
       4 | ##########################  9
       5 | ############################# 10
       6 | ######################################## 14
       7 | ##################################### 13
       8 | ######################################## 14
       9 | ######################################## 14
      10 | #######################  8
      11 | ##############  5
      12 | ###  1
      

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

# print.roll_distribution renders a multi-term notation

    Code
      print(roll_distribution("1d20+1d6", n = 100))
    Output
      <roll_distribution> 1d20+1d6
      Rolls: 100  Possible total range: 2 to 26
      
       2 | #### 1
       3 | ######### 2
       4 | ######### 2
       5 | ######################################## 9
       6 | ########################### 6
       7 | ################## 4
       8 | ###################### 5
       9 | ############# 3
      10 | #################################### 8
      11 | ############################### 7
      12 | ########################### 6
      13 | ######### 2
      14 | ################## 4
      15 | ############# 3
      16 | ############# 3
      17 | ################## 4
      18 | ############# 3
      19 | ############################### 7
      20 | ################## 4
      21 | ################## 4
      22 | ################## 4
      23 | ###################### 5
      24 | ######### 2
      25 | #### 1
      26 | #### 1
      

