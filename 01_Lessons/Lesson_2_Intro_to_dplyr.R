################################################################################
# Day 2: Introduction to dplyr - Data Manipulation for Cancer Bioinformatics
# Cancer Bioinformatics Workshop
################################################################################

# Welcome back! Last time we learned base R: variables, vectors, and data frames.
# Today we learn dplyr, which is the tool we will use for almost everything
# else in this class.

# Base R can do everything dplyr does. But dplyr does it with less typing,
# fewer typos, and code you can actually read six months from now.
# That last part matters more than you think.

# Remember: anything after a # is a comment. R ignores it.
# Run a single line with Ctrl+Enter (Cmd+Enter on Mac).


################################################################################
# SECTION 1: Refresher from Day 1
################################################################################

# Let's warm up. Nothing here is new.

# Create a variable named Students that adds the number of male and female
# students in class.
Students <- 14 + 16
Students   # notice this shows up in your Environment tab, top right


#--- Built-in datasets ---
# R ships with practice datasets already loaded. You don't have to import them,
# they're just there. The most famous one is called iris (flower measurements).

View(iris)   # opens it in a tab next to your script
head(iris)   # first 6 rows, printed to the Console
str(iris)    # structure: 150 observations of 5 variables
View(starwars)
min(starwars$height)
# Remember from Day 1: observations = rows, variables = columns.

# How many different species are in the dataset?
# table() counts how many times each value appears in a column.
table(iris$Species)

# Note the $ again. It means "the Species column inside the iris data frame."

# Create a new dataset called Setosa that contains only the setosa species.
Setosa <- iris[iris$Species == "setosa", ]

# Read that line slowly, because it's the whole reason dplyr exists:
#   iris[                        -- from the iris data frame
#        iris$Species == "setosa"  -- keep rows where this is TRUE
#        ,                       -- the comma separates rows from columns
#         ]                      -- blank after the comma = keep ALL columns

# Try it yourself: create a dataset called Big_Petals containing only flowers
# with a Petal.Length greater than 5.
big_petals <- iris[iris$Petal.Length > 5,]
print(big_petals)
View(big_petals)

################################################################################
# SECTION 2: Installing and Loading dplyr
################################################################################

# Remember the rule from Day 1: install ONCE, load EVERY session.

# install.packages("dplyr")   # you only run this one time, ever, per computer

library(dplyr)                # you run this every time you open R

# Buying the book (install) vs. taking it off the shelf and opening it (library).

# When you run library(dplyr), R prints a warning about "masking" filter()
# and lag(). That is normal. It's telling you base R already had a filter()
# function, and dplyr's version is now the one in charge. That's what we want.

# dplyr is part of the "tidyverse", a family of modern R packages that are all
# designed to work together. dplyr gives us "verbs" -- each one does exactly
# one job:
#   filter()     - keep rows that match a condition
#   select()     - keep or drop columns
#   arrange()    - sort rows
#   mutate()     - create new columns
#   summarise()  - collapse many rows into summary numbers
#   group_by()   - do all of the above separately for each group
#   count()      - quick frequency table

# That's basically the whole package. Seven verbs. We will use them constantly,
# so ASK QUESTIONS today rather than being lost on Day 5.


################################################################################
# SECTION 3: Importing Real Data
################################################################################

# Now for a real dataset: brca_metabric_clinical_data
# This is clinical data from the METABRIC study -- roughly 2,000 real breast
# cancer patients, downloaded from cBioPortal.

#--- Option 1: point and click ---
# Environment tab (top right) -> Import Dataset -> From Text (base)
# Navigate to the file, click Import. Watch the Console: RStudio writes the
# read.csv() code FOR you and runs it. Copy that line into your script.

#--- Option 2: write the code (this is what we want to build toward) ---
# If the file is sitting in your working directory (the project folder we made
# on the Desktop on Day 1), this is all you need:

# brca_metabric_clinical_data <- 
read.csv("brca_metabric_clinical_data.csv")

# Why do we prefer the code version? Because clicking isn't saved. If you close
# R and reopen tomorrow, your data is gone and you have to remember which
# buttons you pressed. A line of code in your script always works.

#--- Always look at your data before you touch it ---
str(brca_metabric_clinical_data)          # what columns exist? what type is each?
dim(brca_metabric_clinical_data)          # rows, columns
colnames(brca_metabric_clinical_data)     # exact column names -- READ THESE

# Those column names matter enormously. Notice R replaced every space and
# special character with a period when it imported:
#   "Age at Diagnosis"          became  Age.at.Diagnosis
#   "Overall Survival (Months)" became  Overall.Survival..Months.
#   "Patient's Vital Status"    became  Patient.s.Vital.Status
# If you type a column name from memory and get an "object not found" error,
# 90% of the time it's a period you got wrong. Scroll up to colnames().

# One more thing to burn into your brain right now:
# In this dataset, Tumor.Size is recorded in MILLIMETERS, not centimeters.
# We will come back to this and it will bite someone.


################################################################################
# SECTION 4: FILTER() - Keeping Rows
################################################################################

# filter() keeps only the rows where your condition is TRUE.
# Ask yourself: "Which patients meet this criteria?"

# The pattern is always:  filter(data, condition)

#--- Example 1: Patients older than 60 ---
elderly_patients <- filter(brca_metabric_clinical_data, Age.at.Diagnosis > 60)
print(eldery_patients)

   # how many patients did we keep?
dim(elderly_patients)

# Compare that number to nrow(brca_metabric_clinical_data). Does the size of
# the result make sense? Get in the habit of asking that EVERY time you filter.

#--- Example 2: HER2 positive patients ---
HER2_positive <- filter(brca_metabric_clinical_data, HER2.Status == "Positive")
View(HER2_positive)
# Two things about the quotes here:
#   - "Positive" is text, so it needs quotes. 60 is a number, so it doesn't.
#   - R is case sensitive. "Positive" and "positive" are different values.
#     If you get 0 rows back, check your capitalization first.
# Not sure what the options are? Ask the data:
table(HER2_positive$HER2.Status)

#--- Example 3: Multiple conditions with AND ---
# A comma and the & symbol both mean AND. Use whichever reads better to you.

eldery_chimo <- filter(brca_metabric_clinical_data, Age.at.Diagnosis >= 60 & Chemotherapy == "YES")
View(eledery_chimo)


# Note >= means "greater than or equal to". Day 1 material, still true.

#--- Example 4: Multiple conditions with OR (|) ---
# With AND, every condition must be true. With OR, only one has to be.
# Create a dataset with patients who are stage 4 OR have a tumor larger than 6 cm:
advanced <- filter(brca_metabric_clinical_data, Tumor.Stage == 4 | Tumor.Size > 6)
View(advanced)




# Is this right? Look closely at tumor size.
# ...
# It is NOT right. Tumor.Size is in millimeters. We just asked for every tumor
# bigger than 6 mm, which is nearly all of them. 6 cm = 60 mm:
advanced <- filter(brca_metabric_clinical_data, Tumor.Stage == 4 | Tumor.Size > 60)
View(advanced)
# This is the most dangerous kind of error in bioinformatics. The code ran.
# There was no error message. The answer was just wrong. R will happily give
# you a confident, well-formatted, completely meaningless result.
# YOU are the one who has to know what the units are.

#--- Example 5: %in% for multiple values ---
# Pam50 is a molecular subtype classification. Say we want two of the subtypes.
# You COULD write it with OR:
#   filter(data, Pam50...Claudin.low.subtype == "LumA" | Pam50...Claudin.low.subtype == "LumB")
# But %in% asks "is this value anywhere in my list?" and is much cleaner:
Pam <- filter(brca_metabric_clinical_data, Pam50...Claudin.low.subtype == "LumA" | Pam50...Claudin.low.subtype == "LumB")
table(Pam$Pam50...Claudin.low.subtype)

Pam <- filter(brca_metabric_clinical_data, Pam50...Claudin.low.subtype %in% c("LumA","LumB"))
# Always check with table() afterward. If a subtype you expected shows 0,
# you probably misspelled it.
table()
#--- Example 6: Negation with ! (NOT) ---
# Patients who are NOT stage 1. Two ways:
   # "not equal to"
  # "not (stage is 1)"
not_stage1 <- filter(brca_metabric_clinical_data, Tumor.Stage != 1)
not_stage1 <- filter(brca_metabric_clinical_data, !Tumor.Stage == 1)

# CAREFUL: a single = is not the same as ==.
#   =   assigns a value  (like <-)
#   ==  asks a question: "are these equal?"
# Writing !Tumor.Stage = 1 is an error. Filtering is asking questions,
# so you always want ==.

#--- Example 7: Combining many conditions ---
# High-risk patients: stage 3 or 4, large tumor, and died of the disease
high_risk <- filter(brca_metabric_clinical_data, 
                    Tumor.Stage >= 3, 
                    Tumor.Size >= 50, 
                    Patient.s.Vital.Status == "Died of Disease")
table(high_risk$Tumor.Stage)

#--- COMPARISON: base R vs dplyr ---
# Base R (technically fine, physically painful):
base_r_result <- brca_metabric_clinical_data[
  brca_metabric_clinical_data$Age.at.Diagnosis > 60 &
  brca_metabric_clinical_data$Tumor.Stage == 4, ]

# dplyr:
dplyr_result <- filter(brca_metabric_clinical_data,
  Age.at.Diagnosis > 60,
  Tumor.Stage == 4)

# Identical results. One of them you can read.

# Try it yourself: create a dataset called young_ER_positive containing patients
# diagnosed under age 45 whose ER.Status is "Positive". How many are there?



################################################################################
# SECTION 5: SELECT() - Choosing Columns
################################################################################

# filter() works on ROWS. select() works on COLUMNS.
# Think: "I only want to look at these variables."

# This dataset has 30+ columns. You rarely need them all, and a narrower
# table is far easier to eyeball for mistakes.

#--- Example 1: Select a few columns by name ---

# Look at the Environment tab. Same number of observations, way fewer variables.
# select() never removes rows. Only filter() does that.

#--- Example 2: Select a RANGE of columns with : ---
patient_info 
patient_info <- select(brca_metabric_clinical_data, Study.ID : Type.of.Brest.Surgery)
View(patient_info)
# The colon means "from this column through that column, in the order they
# appear in the data frame." Same colon we used for 1:10 on Day 1.

#--- Example 3: DROP columns with the minus sign ---
clean_data <- select(brca_metabric_clinical_data, -Study.ID, -Cohort)

# Everything except those two. Handy when you want to lose 2 columns
# instead of naming the other 28.

#--- Example 4: Select by name pattern ---
HER2_data <- select(brca_metabric_clinical_data, Patient.ID, contains("HER2"))
# contains("HER2") grabs every column with HER2 anywhere in its name.

#--- Example 5: The other helper functions ---
#   starts_with("Tumor")  -- Tumor.Size, Tumor.Stage, Tumor.Other...
#   ends_with("Status")   -- ER.Status, HER2.Status, PR.Status...
#   contains("Survival")  -- anything with Survival in it
#   where(is.numeric)     -- every column that holds numbers

# Try each one and look at what comes back:
select(brca_metabric_clinical_data, starts_with("Tumor")) |> head()
select(brca_metabric_clinical_data, ends_with("Status")) |> head()



#--- Example 6: Select AND rename at once. REALLY HELPFUL ---
recorded <- select(brca_metabric_clinical_data,
                   Patient.ID, Cancer, Type, Tumor.Stage, everything())
View(recorded)
colnames(recorded)

#--- Example 6.5: Rename columns---
renamed <- select(brca_metabric_clinical_data,
                  ID = Patient.ID,
                  Age = Age.at.Diagnosis,
                  Type = Cancer.Type,
                  Stage = Tumor.Stage,
                  everything())

# The syntax is new_name = old_name. New name on the LEFT.
# This is one of the few places in R where a single = is correct.
# Overall.Survival..Months. is a terrible name to type forty times.
# Rename it once and move on with your life.

#--- Example 7: Select only numeric columns ---
numeric_data <- select(brca_metabric_clinical_data, where(is.numeric))
head(numeric_data)

# Useful later when a statistical function refuses to accept text columns.

# Try it yourself: build a dataset called survival_info with Patient.ID plus
# every column containing the word "Survival". Rename Patient.ID to ID.



################################################################################
# SECTION 6: THE PIPE OPERATOR |>
################################################################################

# This is the single most important idea in the whole lesson.

# So far each verb did one job. Real analysis needs several in a row.
# You have two bad options and one good one.

#--- BAD OPTION: nesting ---
result1 <- head(select(filter(brca_metabric_clinical_data, Age.at.Diagnosis > 60),
  Patient.ID, Age.at.Diagnosis, Cancer.Type), 10)

# To read that, you start in the MIDDLE and work outward. The first thing that
# happens (filter) is buried in the center. The last thing (head) is on the
# outside. Now count the closing parentheses. This is how people quit R.

#--- BAD OPTION: intermediate objects ---
step1 <- filter(brca_metabric_clinical_data, Age.at.Diagnosis > 60)
step2 <- select(step1, Patient.ID, Age.at.Diagnosis, Cancer.Type)
step3 <- head(step2, 10)

# It works, but now your Environment is full of step1, step2, step3 junk,
# and if you change step1 you must re-run everything below it in order.

#--- GOOD OPTION: the pipe ---
result2 <- brca_metabric_clinical_data |>
  filter(Age.at.Diagnosis > 60) |>
  select(Patient.ID, Age.at.Diagnosis, Cancer.Type) |>
  head(10) 

# Read |> out loud as "and then":
#   Take the METABRIC data, AND THEN
#   keep patients older than 60, AND THEN
#   keep these three columns, AND THEN
#   show me the first 10.

# Top to bottom, in the order it actually happens. No nesting, no junk objects.

# How it works: the pipe takes whatever is on the left and hands it to the
# function on the right as its FIRST argument. That's why the data frame name
# disappears from inside filter() -- the pipe already delivered it.

#   brca_metabric_clinical_data |> filter(Age.at.Diagnosis > 60)
# is exactly the same as
#   filter(brca_metabric_clinical_data, Age.at.Diagnosis > 60)

# Keyboard shortcut: Ctrl+Shift+M (Cmd+Shift+M on Mac).
# On Day 1 we ticked "Use native pipe operator" in Global Options, so this
# gives you |>. That's the modern one built into R itself.

# You will also see %>% in older code and on Stack Overflow. It comes from a
# package called magrittr that dplyr loads for you. For everything we do in
# this class the two behave identically. I use |>. Don't panic when you see %>%.

#--- A fuller example ---
# Find elderly stage 4 patients and pull out their treatment and survival:
elderly_stage <- brca_metabric_clinical_data |> 
    filter(Age.at.Diagnosis >60) |> 
    filter(Tumor.Stage == 4) |> 
    select(Patient.ID, Age.at.Diagnosis, Chemotherapy, Patient.s.Vital.Status)

# Two separate filter() calls, or one filter() with a comma? Identical results.
# Split them when the conditions are unrelated ideas; combine them when they're
# one idea. This is style, not correctness.


# DEBUGGING TIP, and this is the good one:
# When a pipe misbehaves, highlight it one line at a time. Run just the first
# line. Then the first two. Then three. The step where the row count goes
# wrong is your bug. Don't stare at all six lines at once.

# Try it yourself: using one pipe, find patients with Tumor.Size > 40 who had
# Radio.Therapy == "YES", keep Patient.ID, Tumor.Size, and Tumor.Stage, and
# show the first 5 rows.



################################################################################
# SECTION 7: ARRANGE() - Sorting Rows
################################################################################

# arrange() sorts. It never adds or removes rows -- it just reorders them.

# Sort patients by age, youngest first:
by_age <- arrange(brca_metabric_clinical_data, Age.at.Diagnosis)

# Smallest to largest is the default. For text columns it's alphabetical.
old_age <- arrange(brca_metabric_clinical_data,-Age.at.Diagnosis)

#--- Largest to smallest ---
          # minus sign
          # or desc()

# desc() reads better and, unlike the minus sign, works on text columns too.

#--- Sort by more than one column ---
brca_metabric_clinical_data |> 
  arrange(Tumor.Stage, desc(Age.at.Diagnosis)) |> 
  select(Patient.ID, Tumor.Stage, Age.at.Diagnosis) |> 
  head(10)
# Sort by stage first. WITHIN each stage, sort by age, oldest first.

# Order matters here -- the first column is the primary sort.

#--- Combining verbs ---
# Filter for patients 40 and under with tumors larger than 6 cm (60 mm!),
# arranged youngest to oldest:
young_patients_big_tumor <- brca_metabric_clinical_data |>
  filter(Age.at.Diagnosis <= 40) |>
  filter(Tumor.Size > 60) |>
  arrange(Age.at.Diagnosis)

# Same thing, conditions combined:
young_patients_big_tumor_2 <- brca_metabric_clinical_data |>
  filter(Age.at.Diagnosis <= 40,
    Tumor.Size > 60) |>
  arrange(Age.at.Diagnosis)

nrow(young_patients_big_tumor)
nrow(young_patients_big_tumor_2)   # should match

# Notice where NA values end up when you sort. R puts them LAST no matter which
# direction you sort. That's deliberate, and we're about to talk about why NA
# deserves your respect.


################################################################################
# SECTION 8: MUTATE() - Creating and Modifying Columns
################################################################################

# mutate() adds new columns. Think: "calculate a new variable from what I have."
# On Day 1 we did this with gene_data$log_expression <- log2(...). Same idea,
# cleaner syntax, and it works inside a pipe.

#--- Example 1: One new column ---
patients_with_age_group <- brca_metabric_clinical_data |> 
  mutate(Age_group = ifelse(Age.at.Diagnosis < 50, "Younger", "Older"))
table(patients_with_age_group$Age_group)
# ifelse() takes three things: a question, the answer if TRUE, the answer if
# FALSE. Same function we used on Day 1 for "High"/"Low" expression.

#--- Example 2: Several new columns at once ---
enhanced_data <- brca_metabric_clinical_data |> 
  mutate (
    Tumor.Size_cm = Tumor.Size/10,
    Age_category = case_when(
    Age.at.Diagnosis < 40 ~ "Young",
    Age.at.Diagnosis >= 40 & Age.at.Diagnosis < 60 ~ "Middle Aged",
    Age.at.Diagnosis >= 60 ~ "Elderly"),
    tumor_category = case_when (
      Tumor.Size_cm < 2 ~ "Small",
      Tumor.Size_cm >= 2 & Tumor.Size_cm < 5 ~ "Medium",
      Tumor.Size_cm >= 5 ~ "Large"
      )
  )
table(enhanced_data$age_category)
table(enhanced_data$tumor_category)

# THREE things worth pausing on here:

# 1. case_when() is ifelse() for more than two outcomes. Read the ~ as "then":
#      condition ~ "value"     means    "if this is true, then use this value"
#    R checks conditions TOP TO BOTTOM and stops at the first match. So order
#    matters. Anything that matches nothing becomes NA.

# 2. Look at tumor_category -- it uses Tumor.Size_cm, which we created two
#    lines earlier IN THE SAME mutate(). That's allowed. mutate() works top to
#    bottom and each new column is immediately available to the next one.
#    Try reversing those two and watch it break.

# 3. Nothing happened to brca_metabric_clinical_data. mutate() does not modify
#    the original -- it returns a NEW data frame, which we saved as
#    enhanced_data. This is different from Day 1, where gene_data$new <- ...
#    permanently changed gene_data. dplyr's way is safer: your raw data stays
#    raw, and you can always start over.

#--- Example 3: Overwriting an existing column ---
data_in_cm <- brca_metabric_clinical_data |>
  mutate(Tumor.Size = Tumor.Size / 10) |>
  rename(Tumor.Size_cm = Tumor.Size)

head(select(data_in_cm, Patient.ID, Tumor.Size_cm))

# If the name in mutate() already exists, R replaces that column instead of
# adding one. Powerful and dangerous -- run this line twice and your tumors
# are 100x too small.
# rename() just changes a name, no calculation. Same new = old syntax as select().
# Renaming after a unit conversion isn't optional bookkeeping. It's the whole
# reason the next person doesn't repeat the 6 mm mistake.

# Try it yourself: create a column called survival_years from
# Overall.Survival..Months., and a column called long_survivor that says
# "Yes" if survival is over 10 years and "No" otherwise.



################################################################################
# SECTION 9: SUMMARISE() - Collapsing Data into Statistics
################################################################################

# Every verb so far returned a table roughly the shape you started with.
# summarise() is different: it crushes thousands of rows down to ONE row of
# summary numbers.

# (summarize() with a z works identically. dplyr accepts both spellings.)

#--- Example 1: A first attempt ---
overall_summary <- brca_metabric_clinical_data |>
  summarise(
    total_patients = n(),                    # n() counts rows
    avg_age = mean(Age.at.Diagnosis),
    median_age = median(Age.at.Diagnosis),
    min_age = min(Age.at.Diagnosis),
    max_age = max(Age.at.Diagnosis),
    sd_age = sd(Age.at.Diagnosis),
    avg_tumor_size = mean(Tumor.Size),
    avg_survival = mean(Overall.Survival..Months.)
  )

print(overall_summary)

# What is wrong here?
# ...
# Some of those came back as NA. Not an error. Just NA.

#--- Meet NA ---
# NA means "missing". Not zero, not blank -- unknown. Real clinical data is
# full of it. Someone's tumor was never measured; a patient was lost to
# follow-up.

# R's rule: if ANY value is unknown, the answer is unknown.
mean(c(1, 2, 3, NA))    # NA
# That's R being careful, not broken. It refuses to guess.

# To say "ignore the missing ones and average the rest", add na.rm = TRUE
# ("NA remove"):
mean(c(1, 2, 3, NA), na.rm = TRUE)   # 2

#--- Example 2: The fix, plus honesty about what we removed ---
overall_summary <- brca_metabric_clinical_data |>
  summarise(
    total_patients   = n(),
    missing_age      = sum(is.na(Age.at.Diagnosis)),
    avg_age          = mean(Age.at.Diagnosis, na.rm = TRUE),
    median_age       = median(Age.at.Diagnosis, na.rm = TRUE),
    min_age          = min(Age.at.Diagnosis, na.rm = TRUE),
    max_age          = max(Age.at.Diagnosis, na.rm = TRUE),
    sd_age           = sd(Age.at.Diagnosis, na.rm = TRUE),
    avg_tumor_size   = mean(Tumor.Size, na.rm = TRUE),
    missing_tumor    = sum(is.na(Tumor.Size)),
    avg_survival     = mean(Overall.Survival..Months., na.rm = TRUE),
    missing_survival = sum(is.na(Overall.Survival..Months.))
  )

print(overall_summary)

# How that missingness count works:
#   is.na(column)  -> TRUE/FALSE for every row
#   sum(TRUE/FALSE)-> counts the TRUEs, because R treats TRUE as 1
# So sum(is.na(x)) is "how many are missing".

# Do not just sprinkle na.rm = TRUE everywhere and look away. na.rm = TRUE
# silently changes WHO you're averaging. If 300 patients are missing tumor
# size, your "average tumor size" is the average of the other 1,600 -- and if
# the missing ones were missing for a reason (too sick to measure?), your
# number is biased. Always report the count alongside the average.

#--- Example 3: Survival statistics ---
survival_summary <- brca_metabric_clinical_data |>
  summarise(
    missing_survival = sum(is.na(Overall.Survival..Months.)),
    median_survival = median(Overall.Survival..Months., na.rm = TRUE),
    mean_survival = mean(Overall.Survival..Months., na.rm = TRUE),
    min_survival = min(Overall.Survival..Months., na.rm = TRUE),
    max_survival = max(Overall.Survival..Months., na.rm = TRUE))

print(survival_summary)

# What's strange here?
# ...
# The mean is being computed across everyone -- including patients who are
# still alive. Their "survival months" isn't how long they lived. It's how long
# we watched them before the study ended. Averaging those together answers a
# question nobody asked. (This is called censoring, and there's an entire
# branch of statistics devoted to handling it properly. Later in this course.)

#--- Example 4: Restrict to patients who died ---
real_survival <- brca_metabric_clinical_data |>
  filter(Overall.Survival.Status == "1:DECEASED") |>
  summarise(
    n_patients = n(),
    missing_survival = sum(is.na(Overall.Survival..Months.)),
    median_survival = median(Overall.Survival..Months., na.rm = TRUE),
    mean_survival = mean(Overall.Survival..Months., na.rm = TRUE),
    min_survival = min(Overall.Survival..Months., na.rm = TRUE),
    max_survival = max(Overall.Survival..Months., na.rm = TRUE))

print(real_survival)

# Note the value: "1:DECEASED", not "DECEASED". That's exactly how cBioPortal
# stores it. Check with table() before you filter -- guessing costs you time:
table(brca_metabric_clinical_data$Overall.Survival.Status)

# filter() and then summarise() is a pattern you'll use for the rest of your
# life: narrow to the right patients, THEN calculate.


################################################################################
# SECTION 10: GROUP_BY() - Doing It Separately for Every Group
################################################################################

# Here's the payoff. group_by() invisibly splits your data into groups, and
# every verb downstream runs separately within each group.

# This is called "split-apply-combine":
#   SPLIT   the data into groups
#   APPLY   the same calculation to each group
#   COMBINE the answers into one tidy table
# One summary line per group. No copy-paste.

#--- Example 1: Summary statistics by cancer subtype ---
by_cancer <- brca_metabric_clinical_data |> 
  group_by (Cancer.Type.Detailed) |> 
  summarise (
    n_patients = n(),
    avg_age = mean(Age.at.Diagnosis, na.rm = TRUE),
    avg_tumor_size = mean(Tumor.Size, na.rm = TRUE)
  )
print(by_cancer_type)
# Run that WITHOUT the group_by() line and compare. One row versus one row per
# subtype. That one line is doing all the work.
# Look for a group with a tiny n_patients. An "average" of 3 people is a
# rumour, not a statistic.

#--- Example 2: Group by two variables ---
by_time_stage <- brca_metabric_clinical_data |> 
  group_by(Cancer.Type.Detailed, Tumor.Stage) |> 
  summarise(count = n(), .group = "drop") |> 
  arrange(Cancer.Type.Detailed, Tumor.Stage)
print(by_time_stage)

# Now you get one row per COMBINATION -- every subtype crossed with every stage.

# About .groups = "drop":
# If you group by two things and summarise, dplyr removes the last grouping
# level but keeps the first, and prints a chatty message about it. Your data
# is still secretly grouped, and the NEXT verb will behave strangely.
# .groups = "drop" says "we're done grouping, clean it all up." Just use it.




################################################################################
# SECTION 11: COUNT() - Fast Frequency Tables
################################################################################

# You will do group_by() + summarise(n = n()) roughly a thousand times, so
# dplyr made a shortcut.

# The long way:
brca_metabric_clinical_data |>
  group_by(Cancer.Type.Detailed) |>
  summarise(n = n())

# The short way -- identical output:
brca_metabric_clinical_data |> 
  count(Cancer.Type.Detailed)

#--- Example 1: Sort by frequency ---
  # most common first
cancer_counts <- brca_metabric_clinical_data |> 
  count(Cancer.Type.Detailed, Tumor.Stage, sort = TRUE)
print(cancer_counts)


#--- Example 2: Count by two variables (cross-tabulation) ---


#--- Example 3: Counts with percentages ---
cancer_percent <- brca_metabric_clinical_data |> 
  count(Cancer.Type.Detailed) |> 
  mutate(percent = round (n/sum(n)*100,1)) |> 
  arrange(desc(n))

# count() names its output column n, so mutate() can immediately use it.
# round(x, 1) means one decimal place.

#--- Example 4: Treatment frequencies ---


# count() is also your best data-cleaning tool. Run it on any text column
# before you trust it. It will show you the "YES" that's actually "Yes",
# the empty string pretending to be a category, and the NAs.



################################################################################
# SECTION 12: A Few More Useful Verbs
################################################################################

#--- distinct() - unique values ---
brca_metabric_clinical_data |>
  distinct(Cancer.Type.Detailed)

# Every unique combination of two columns:
unique_combinations <- brca_metabric_clinical_data |>
  distinct(Cancer.Type.Detailed, Tumor.Stage) |>
  arrange(Cancer.Type.Detailed, Tumor.Stage)

print(unique_combinations)

# distinct() tells you what values EXIST. count() tells you how many of each.

#--- slice() - grab rows by position ---
first_five <- brca_metabric_clinical_data |>
  slice(1:5) |>
  select(Patient.ID, Age.at.Diagnosis, Cancer.Type.Detailed)

print(first_five)

#--- slice_max() / slice_min() - top or bottom N by a variable ---
oldest_five <- brca_metabric_clinical_data |>
  slice_max(Age.at.Diagnosis, n = 5) |>
  select(Patient.ID, Age.at.Diagnosis, Cancer.Type.Detailed, Tumor.Stage)

print(oldest_five)

youngest_five <- brca_metabric_clinical_data |>
  slice_min(Age.at.Diagnosis, n = 5) |>
  select(Patient.ID, Age.at.Diagnosis, Cancer.Type.Detailed)

print(youngest_five)

# Nicer than arrange() + head(), and it plays properly with group_by():
# "the oldest patient in EACH subtype" is one line.

#--- slice_sample() - random rows ---
random_ten <- brca_metabric_clinical_data |>
  slice_sample(n = 10) |>
  select(Patient.ID, Cancer.Type.Detailed, Age.at.Diagnosis)

print(random_ten)

# Great for sanity-checking. head() only ever shows you the top of the file,
# which is often sorted and therefore unrepresentative.
# Different rows every run. Use set.seed(42) first if you need it repeatable.

#--- rename() - rename without selecting ---
renamed_data <- brca_metabric_clinical_data |>
  rename(
    ID = Patient.ID,
    Age = Age.at.Diagnosis,
    Type = Cancer.Type.Detailed,
    Size_mm = Tumor.Size)

colnames(renamed_data)

# select() with new names KEEPS ONLY those columns. rename() keeps everything.
# That's the whole difference. It matters.

#--- relocate() - move columns without dropping any ---
reordered <- brca_metabric_clinical_data |>
  relocate(Cancer.Type.Detailed, Tumor.Stage, .before = Age.at.Diagnosis)

colnames(reordered)

# .before or .after. Purely cosmetic, but cosmetics help when you're squinting
# at 30 columns.


################################################################################
# SECTION 13: Putting It All Together
################################################################################

# Real analyses stack these verbs. Read each pipe top to bottom and say
# "and then" out loud.

#--- Analysis 1: Build a risk profile ---


# New thing: TRUE ~ "Medium" at the end of case_when(). TRUE always matches,
# so it's the catch-all for everything that fell through. Without it, unmatched
# rows become NA. Get in the habit of always writing a TRUE line.

# How many in each priority category?


#--- Analysis 2: Does stage affect survival? ---


# The clever bit is percent_deceased. Overall.Survival.Status == "1:DECEASED"
# makes a TRUE/FALSE vector. R counts TRUE as 1 and FALSE as 0, so the MEAN of
# those is the proportion that are TRUE. Times 100 = a percentage.
# mean() of a TRUE/FALSE test = "what fraction meet this condition?"
# You'll use this constantly.

# Also note filter(!is.na(Tumor.Stage)) at the top -- drop patients with no
# recorded stage so we don't get a mystery NA group in our results.

# Does the pattern go the direction you'd expect? Is it a clean trend?

#--- Analysis 3: Which subtypes are diagnosed latest? ---


# filter(n >= 20) AFTER summarise() is a great habit: throw out groups too
# small to say anything about. Notice you can filter on a column you just
# created -- by that point in the pipe, n is a real column like any other.

#--- Analysis 4: Chemotherapy and survival ---


# Look at that table and think hard before you say anything out loud.
# If the chemotherapy group did worse, does chemo hurt people?
# No. Look at avg_tumor_size_cm and avg_age. Sicker patients GET chemo.
# The treatment groups were never comparable to begin with.
# This is confounding, and it's the single most common way to be wrong with
# a correct calculation. dplyr will compute anything you ask. It has no
# opinion about whether the comparison means anything. That's your job.

#--- Analysis 5: A full patient profile table ---


# Notice how case_when() gets shorter here. Because R stops at the first match,
# once "Age < 50" has been checked, the next line only needs "Age < 65" -- the
# under-50s are already gone. You don't need >= 50 & < 65.
# Order is doing the work for you.


################################################################################
# SECTION 14: Getting Help
################################################################################

# Same as Day 1, plus a few dplyr-specific ones.

?filter          # dplyr's help page (base R's filter is masked)
?dplyr::filter   # :: says exactly which package you mean
?case_when
?across

# Scroll to the bottom of any help page. The Examples are runnable, and they're
# usually the fastest way to understand a function.
example(filter)

# Longer tutorial-style guides written by the package authors:
browseVignettes("dplyr")
vignette("dplyr")     # the introductory one

# The dplyr cheat sheet is genuinely excellent. Print it, keep it next to you:
# Help -> Cheat Sheets -> Data Transformation with dplyr


################################################################################
# CONGRATULATIONS
################################################################################

# The seven verbs:
#   filter()    - keep rows matching a condition
#   select()    - keep or drop columns
#   arrange()   - sort rows
#   mutate()    - create or modify columns
#   summarise() - collapse rows into statistics
#   group_by()  - do all of the above per group
#   count()     - quick frequency table
#   |>          - chain them together, read as "and then"

# The things that will actually bite you:
#   - NA is contagious. Use na.rm = TRUE, but report what you removed.
#   - == asks, = assigns. Filtering asks questions.
#   - Tumor.Size is in millimeters. Know your units.
#   - ungroup() when you're done grouping.
#   - Check nrow() after every filter. Does the answer's size make sense?
#   - R will always give you an answer. It won't tell you if it's meaningless.

# Next steps:
#   - Visualization with ggplot2 (also tidyverse -- the pipe carries over)
#   - Joins: combining clinical data with mutation data
#   - Pivots: reshaping wide data to long and back

################################################################################
# Day 2 Review: dplyr Practice Problems
# Cancer Bioinformatics Workshop
################################################################################

# These use the SAME dataset from the lesson: brca_metabric_clinical_data.
# Make sure it's loaded in your Environment before you start.

# Each question tells you WHAT we want to know, not which function to use.
# Figuring out which verb (or verbs) you need is half the job. Some questions
# take one verb. Some take several chained together with |>.

# Answers are at the bottom. Try each one first -- a wrong answer you debugged
# teaches you more than a right answer you copied.

library(dplyr)

# Quick reminder before you start -- look at your data:
#   colnames(brca_metabric_clinical_data)
# and remember two things that will bite you:
#   - Tumor.Size is in MILLIMETERS
#   - lots of columns have NA values in them

################################################################################
# QUESTIONS
################################################################################

# --- Q1 ---
# We only care about patients diagnosed after age 70. Pull out just those
# patients. How many are there?
age_over70 <- filter(brca_metabric_clinical_data, Age.at.Diagnosis > 70)
View(age_over70)

# --- Q2 ---
# Build a smaller table containing only four things about each patient:
# their ID, their age at diagnosis, their cancer type, and their tumor stage.


# --- Q3 ---
# We want the patients who are both stage 3 or higher AND had chemotherapy.
# How many patients meet both conditions?
stage3_chemo <- filter(brca_metabric_clinical_data, 
                       Tumor.Stage >= 3,
                       Chemotherapy == "YES")
View(stage3_chemo)
# --- Q4 ---
# The Overall.Survival..Months. column name is painful to type. Produce a
# table with just patient ID and survival months, but with survival months
# relabeled to something shorter, like Survival.
table(
  brca_metabric_clinical_data$Study.ID,
  brca_metabric_clinical_data$Overall.Survival.Status
)

# --- Q5 ---
# Tumor size is recorded in millimeters, which nobody thinks in. Add a new
# column to the data that expresses each tumor's size in centimeters instead.


# --- Q6 ---
# We want to sort patients into age brackets. Add a column that labels each
# patient "Under 40", "40-59", or "60+" based on their age at diagnosis.


# --- Q7 ---
# For each cancer type (use Cancer.Type.Detailed), we want to know how many
# patients there are and what their average age at diagnosis is.


# --- Q8 ---
# How complete is the tumor size data? In a single summary, tell us the total
# number of patients, the average tumor size, and how many patients are
# missing a tumor size value.


# --- Q9 ---
# For each tumor stage, what is the median survival (in months)? Ignore
# patients whose stage is missing.


# --- Q10 ---
# The real one. Among patients who DIED of their disease, and broken down by
# cancer type (Cancer.Type.Detailed), we want the median survival months and
# the average tumor size. Only show cancer types that have at least 20 such
# patients, and put the type with the shortest median survival at the top.

