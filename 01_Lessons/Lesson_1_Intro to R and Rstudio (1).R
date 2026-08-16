################################################################################
# Day 1: Introduction to R and Basic Programming
# Cancer Bioinformatics Workshop
################################################################################

# Welcome to R! This script will guide you through the basics of R programming.
# In R, anything after a # symbol is a comment and won't be executed.

################################################################################
# SECTION 1: Getting Started with R
################################################################################
#--The RStudio Interface ---
# Console  = where code runs. Bottom Left Box. Gives a history of the code we have ran. Can run code but DOES NOT SAVE!


# Try it yourself: Calculate 15 multiplied by 8
15*8

# Script   = where you write and save code (.R file) Top Left box. This is where we will be spending most of our time!
 #now if we need this code it will be saved here!

# Environment = Top Right box. lists variables you've created. Also import. More on this very soon. 

# Plots / Help / Files = for viewing outputs and documentation. Bottom right box. Also important

# You can run a single line with Ctrl+Enter (Cmd+Enter on Mac)
43-3+7*12 #R follows order of operations!

#In this class, I will try very hard to highlight and show you exactly what code I am running. 



#Some RStudio quality of Life changes. 
#At the very top you see a menu bar. Let's do some aesthetic changes. 
#Navigate to the Tools Window and select Global Options.

#Under Workspace, deselect the Restore .Rdata into workspace at startup & choose never on the dropdonw next to  Save workspace to .Rdata on exit
#This will help us from having things de-clutter our Environment. 

#Navigate to the Code option (right below General). Under the editing tab, select Use native pipe operator. From here switch over to the Display tab. Select rainbow parentheses. 
#This will be VERY helpful as we get more advanced. Here is a quick example of what it looks like. 
((((()))))

#Under Appearance, you can see ways to change the color, text size and editor theme of Rstudio
#I personally hate the default settings so I change mine to be Merbivore. Use the apply button to see the changes on your computer. 
#Choose whatever you like, YOU WILL BE USING THIS ALOT. I WILL JUDGE YOU IF YOU USE THE DEFAULT. 

#To save all of these changes, use the Apply and then the OK button. It will not save unless you select Ok. 


#Working Directory 
#When we work, create, and save things in R, they go to what is called our working directory. 
#For this class, I will ask you to go to the Desktop of your computer and create a folder called Cancer_Bioinformatics_with_R

#Once we all have made this folder, lets go up to the Tools tab again and under Global options change our default directory to this folder. 
#This will ensure that all of our stuff is saved in this folder. THIS IS VERY IMPORTANT. 

#We will change our working directories later, but for now this is going to ensure your work is not saved randomly in your computer. 

#Create an R project. Now that we have our settings fixed. Let's go ahead and create a Project. 
#This project will do a few things: it will let us save our code in a nice clean format, and will help organize how our files are saved later on.
#We might create several projects and code files in this class, but for now lets create a new R Project called Cancer Bioinformatics and Data Analysis with R. 
#To do this, go to File -> New Project -> Existing Directory and choose the Directory you just made (the folder on your Desktop)

#Ok now that we have this going, lets go ahead and load the Lesson 1 R file. 
#Go to File -> Open File, and select the Lesson_1_Intro to R and Rstudio R file (in your downloads probably)

#I will go around and make sure we are all here and good to go before we move on. 

################################################################################
# SECTION 2: Variables and Assignment
################################################################################

# Variables store values that we can use later
# We use <- to assign values to variables (almost like an equal sign)
#to type <- use the shortcut Alt+ - (PC) or Option+ - (Mac)
age <- 16
age*2
 #notice this in the Environment tab on the right. 

#if we just type this variable out, we can see the output below in our Console. 


# We can do operations with variables



#notice that this did not save. Why?

# Variables can be reassigned
age_old <- age + 55
 #an alternative way to see the variable. 
age <- 33
#we can also save equations as variables if we wish
print(age_old)
age1 <- 16
age2 <- 3
age_combined <- age1 + age2
# Variable names should be descriptive, especially when you have so many. 
 # in centimeters
tumor_size <- 3.2
turmor_size_mm <- tumor_size * 10
# Try it yourself: Create a variable called "genes_analyzed" with value 100
genes_analyzed <- 100

#Create a second variable called "genes_downregulated" with value of 34
genes_downregulated <- 34
#Now create a variable that identifies how many upregulated genes we have. 
genes_upregulated <- genes_analyzed - genes_downregulated

################################################################################
# SECTION 3: Data Types
################################################################################

# R has several basic data types:

# Numeric (numbers with decimals)
expression_level <- 8.5
class (expression_level)

 #assumes a decimal of .0
expression_level <- 8.5
class (expression_level)
# Integer (whole numbers)
  # The L makes it an integer
expression_level <- 8L
class (expression_level)
#pretty rare for us to see this one

# Character (text/strings)
gene_name <- "TP53"
class(gene_name)
# Logical (TRUE or FALSE)
is_mutated <- TRUE
class(is_mutated)
# Logical operations
5 > 3  # Greater than
10 < 8  # Less than
7 == 7  # Equal to
4 != 5  # Not equal to
4<=3    # <= less than or equal to >= greater than or equal to

#All of this will be incredibly important when working with big data. Some functions only work with a specific type of data. 

################################################################################
# SECTION 4: Vectors
################################################################################

# Vectors are collections of values of the same type
# They are fundamental to R programming

# Creating vectors with c() [combine function]
gene_names <- c("TP53","BRCA","EGFR","NYC","KRAS")
print(gene_names)
expression_values <- c(12.5, 8.3,15.7,6.2,9.8)
print(expression_values)
mutation_status <- c(TRUE,FALSE,TRUE,FALSE,TRUE)
# Accessing elements in a vector (indexing starts at 1 in R!)
# First gene
gene_names[1]
# Third gene
gene_names[3]
# Multiple elements
gene_names[c(1,3,5)]
# Vector operations
# Multiply all values
expression_values*2
# Add to all values
sum(expression_values)
# Calculate mean
mean(expression_values)
# Find maximum
max(expression_values)
# Find minimum
min(expression_values)
# Number of elements
mean(expression_values[1,3,5])
# Creating sequences
patients_id <- 1:10
# Numbers from 1 to 10

# Sequence from 25 to 70 by 5
seq(25, 70, by = 5)

# Try it yourself: Create a vector of 5 tumor sizes (any numbers you choose)
tumor_size <- c(3,4.5,2,4.4,9.6)

################################################################################
# SECTION 5: Working with Vectors
################################################################################

# We can subset vectors based on conditions
high_expression <- expression_values >10
expression_values [high_expression]

# Use the logical vector to filter
gene_names [high_expression]

# Combining conditions


# Named vectors
# Access by name

################################################################################
# SECTION 6: Data Frames
################################################################################

# Data frames are like tables - they have rows and columns
# They are the most common way to work with data in R

# Creating a data frame
gene_data <- data.frame(
  gene = c("TP53","BRCA","EGFR","NYC","KRAS"),
  expression = c(12.5, 8.3,15.7,6.2,9.8),
  mutated = c(TRUE,FALSE,TRUE,FALSE,TRUE),
  chromosomes = c("17", "17", "7", "8", "12")
) 

print(gene_data)

#puts it in your console. 
#to view it next to your script. both of these can be a problem with big datasets. 

#Take a look at the data table on the right. Notice how it says 5 observations of 4 variables
#In R, an observation is equal to the # of rows and variables is equal to the # of columns. 
View(gene_data)

# Viewing data frame structure

str(gene_data)
# Structure (notice the dollar signs here)
str(gene_data)

# Summary statistics
head(gene_data)
# First few rows

# Number of rows
nrow(gene_data) #observations
# Number of columns
ncol(gene_data) #variables
# Dimensions (rows, columns)
dim(gene_data)
 #column names
colnames(gene_data)
# Accessing columns
gene_data$gene
# Using $ *preferred method for me
# Using column name
gene_data[, "expression"]
# Using column index
gene_data[, 2]
# Accessing rows
gene_data[2,]
# First row
gene_data[, 1]
# Third row
gene_data[, 3]
#think of this as data[row number, column number] if one is left blank it will assume all

# Accessing specific cells
# Row 2, Column 
gene_data [2,3]
# Row 1, "gene" column
gene_data [,"gene"]


# Filtering data frames
high_expression <- gene_data [gene_data$expression > 10,]
print(high_expression)

#why do we have to specify the dataset twice?


#If you want to grab specific columns you can specify that as well




# Try it yourself: Filter for genes on chromosome 17
high_expression <- gene_data [gene_data$chromosomes == 17,]
print(high_expression)

#We can also filter for multiple things at once: 


# AND (&) - both conditions must be TRUE

# Returns: TP53 and EGFR (high expression AND mutated)

# OR (|) - at least one condition must be TRUE

# Returns: TP53, BRCA1 (chr 17), and EGFR (expression > 15)

# NOT (!) - negates a condition
# Not mutated
# Same thing, cleaner

# Combining multiple operators

# Returns: Genes with expression between 8-13 OR on chromosome 7

# Using %in% for multiple values

# Returns: Genes on chromosome 17 or 12



# & = AND (both must be true)
# |#= OR (only one can be true)
# ! = NOT (opposite)
# %in% = matches any value in a vector

################################################################################
# SECTION 7: Adding and Modifying Data
################################################################################

# Adding a new column

#We can create a new column name with functions that will give us a new column in our data table

#notice how we PERMANENTLY CHANGED our data table here!

# Creating a new column based on conditions


# Adding new rows


################################################################################
# SECTION 8: Basic Functions
################################################################################

# R has many built-in functions

# Statistical functions

# Standard deviation 
# Variance
#same as standard deviation

# Counting
sum(gene_data$mutated)
table(gene_data$mutated)
table(gene_data$expression)

# Count TRUE values
mean(gene_data$expression)
median(gene_data$expression)
sd(gene_data$expression)
var(gene_data$expression)
range(geen_data$expression)
# Frequency table


# Sorting
sort(gene_data$expression)
order(gene_data$expression) #the orignial place
# Sort values
# Get indices for sorting

# Sort entire data frame by expression


################################################################################
# SECTION 9: Reading and Writing Data
################################################################################

# Writing data to CSV
write.csv(gene_data, "gene_data.csv")

# Reading data from CSV
read.csv(gene_data, "gene_data.csv")
# gene_data_loaded <- read.csv("gene_data.csv")

#Another way to read files is to use the Import Dataset function under the 
#Environment tab. 




################################################################################
# SECTION 10: Simple Plotting (Preview)
################################################################################

# R has built-in plotting functions
# We'll learn much more about visualization later!

# Simple scatter plot


# Bar plot


# Histogram


################################################################################
# SECTION 12: Packages
################################################################################
# Base R can do a lot, but most of R's power comes from packages.
# A package is a bundle of functions someone else wrote and shared.
# There are thousands of them on CRAN, R's official package repository.

# Installing a package: you only do this ONCE per computer.
# Note the quotes around the package name.
install.packages("dplyr")

# Loading a package: you do this EVERY time you start a new R session.
# No quotes needed here.
library(dplyr)

# Why both? install.packages() downloads the package to your hard drive.
# library() tells R "I want to use this in my current session."
# Think of it like buying a book (install) vs. taking it off the shelf
# and opening it (library).

# A common beginner error:
#   Error in library(dplyr) : there is no package called 'dplyr'
# This means you never installed it. Run install.packages("dplyr") first.

# Best practice: put your library() calls at the TOP of your script.
# Do NOT put install.packages() in your script -- if you share it, you'd be
# re-installing packages on someone else's machine every time they run it.

# So what did we just get? Start with the package's own help page:
help(package = "dplyr")

# That lists every function the package provides. One of them is filter(),
# which keeps rows of a dataset that meet a condition. Pull up its help page:
?filter

# Help pages all follow the same structure. Scroll through and find:
#   Description  -- what the function does, in a sentence or two
#   Usage        -- the function's arguments and their default values
#   Arguments    -- what each argument expects
#   Value        -- what the function gives back
#   Examples     -- runnable code at the very bottom (this is usually
#                   the fastest way to understand a function)

# Try running the examples from the bottom of ?filter, or let R do it:
example(filter)

# Now use it yourself on the built-in mtcars dataset:
filter(mtcars, cyl == 4)

# One wrinkle: base R also has a filter() function, so loading dplyr
# "masks" it. R warns you about this when you run library(dplyr).
# The :: operator says exactly which package you mean:
?dplyr::filter
dplyr::filter(mtcars, cyl == 4)

# A few packages you'll likely run into:
#   dplyr     -- data manipulation
#   ggplot2   -- plotting
#   tidyr     -- reshaping data
#   readr     -- reading in CSVs and other flat files




################################################################################
# SECTION 13: Getting Help
################################################################################
# R has extensive documentation

# Get help on a function
?mean
help(median)

# Search for functions
??regression

# Examples of how to use a function
example(mean)

# You can also use the Help tab to search for functions that has information.
# These can be challenging to read at first but are worth learning.
data()
# Packages often include "vignettes" -- longer tutorial-style guides
# written by the package authors. These are usually friendlier than
# individual help pages.
browseVignettes("dplyr")

### FREE PRACTICE
