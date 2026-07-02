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

# compare defaults to FALSE and leaves the object and print unchanged

    Code
      print(result)
    Output
      <roll> 2d20+2
      Dice:  10, 19
      Total: 31

# a non-logical compare flag is rejected

    Code
      roll("2d6", compare = "yes")
    Condition
      Error in `validate_compare()`:
      ! `compare` must be a single non-missing logical.
      i Received character of length 1.

---

    Code
      roll("2d6", compare = NA)
    Condition
      Error in `validate_compare()`:
      ! `compare` must be a single non-missing logical.
      i Received logical of length 1.

---

    Code
      roll("2d6", compare = c(TRUE, FALSE))
    Condition
      Error in `validate_compare()`:
      ! `compare` must be a single non-missing logical.
      i Received logical of length 2.

# print.roll with compare shows the distribution and the marked total

    Code
      print(roll("2d6", compare = TRUE))
    Output
      <roll> 2d6
      Dice:  6, 3
      Total: 9
      
      Distribution for 2d6: this roll beats 72% of outcomes
       2 | #######  7
       3 | ############# 13
       4 | #################### 20
       5 | ########################### 27
       6 | ################################# 33
       7 | ######################################## 40
       8 | ################################# 33
       9 | ########################### 27 <- this roll
      10 | #################### 20
      11 | ############# 13
      12 | #######  7
      

# compare follows a keep-highest selector's range and shape

    Code
      print(roll("4d6h3", compare = TRUE))
    Output
      <roll> 4d6h3
      Dice:  3, 5, 6, 3
      Kept:  6, 5, 3
      Total: 14
      
      Distribution for 4d6h3: this roll beats 65% of outcomes
       3 | #  1
       4 | #  1
       5 | ##  2
       6 | #####  5
       7 | #########  9
       8 | ############## 14
       9 | ##################### 21
      10 | ############################ 28
      11 | ################################## 34
      12 | ####################################### 39
      13 | ######################################## 40
      14 | ##################################### 37 <- this roll
      15 | ############################## 30
      16 | ###################### 22
      17 | ############# 13
      18 | #####  5
      

# compare against a skewed keep-highest distribution is probability-weighted

    Code
      print(roll("2d20h", compare = TRUE))
    Output
      <roll> 2d20h
      Dice:  2, 11
      Kept:  11
      Total: 11
      
      Distribution for 2d20h: this roll beats 25% of outcomes
       1 | #  1
       2 | ###  3
       3 | #####  5
       4 | #######  7
       5 | #########  9
       6 | ########### 11
       7 | ############# 13
       8 | ############### 15
       9 | ################# 17
      10 | ################### 19
      11 | ###################### 22 <- this roll
      12 | ######################## 24
      13 | ########################## 26
      14 | ############################ 28
      15 | ############################## 30
      16 | ################################ 32
      17 | ################################## 34
      18 | #################################### 36
      19 | ###################################### 38
      20 | ######################################## 40
      

# compare follows a shifted range under a negative modifier

    Code
      print(roll("1d4-10", compare = TRUE))
    Output
      <roll> 1d4-10
      Dice:  4
      Total: -6
      
      Distribution for 1d4-10: this roll beats 75% of outcomes
      -9 | ######################################## 40
      -8 | ######################################## 40
      -7 | ######################################## 40
      -6 | ######################################## 40 <- this roll
      

# rolling the minimum total reports a 0% standing

    Code
      print(roll("1d4-10", compare = TRUE))
    Output
      <roll> 1d4-10
      Dice:  1
      Total: -9
      
      Distribution for 1d4-10: this roll beats 0% of outcomes
      -9 | ######################################## 40 <- this roll
      -8 | ######################################## 40
      -7 | ######################################## 40
      -6 | ######################################## 40
      

