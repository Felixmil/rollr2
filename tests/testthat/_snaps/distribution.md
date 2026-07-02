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

# print.roll_distribution renders a multi-term notation

    Code
      print(roll_distribution("1d20+1d6", n = 100))
    Output
      <roll_distribution> 1d20+1d6
      Rolls: 100  Possible total range: 2 to 26
      
       2 | ########## 2
       3 | ########## 2
       4 | ########## 2
       5 | ########## 2
       6 | ############################## 6
       7 | #################### 4
       8 | ################################### 7
       9 | #################### 4
      10 | ############### 3
      11 | ############################## 6
      12 | #################### 4
      13 | ############### 3
      14 | ############### 3
      15 | ######################### 5
      16 | #################### 4
      17 | ############################## 6
      18 | ######################################## 8
      19 | ################################### 7
      20 | ############################## 6
      21 | ############### 3
      22 | ######################### 5
      23 | ############### 3
      24 | ############### 3
      25 | ##### 1
      26 | ##### 1
      

