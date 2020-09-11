# -----------------------------------------------------------------------------
# DESCRIPTION: THIS PROGRAM GENERATES THE FOLLOWING ESTIMATES ON
#               NATIONAL HEALTH CARE, 2018:
#
#             (1) OVERALL EXPENSES
# 	          (2) PERCENTAGE OF PERSONS WITH AN EXPENSE
# 	          (3) MEAN EXPENSE PER PERSON WITH AN EXPENSE
#
# INPUT FILE:  C:/MEPS/H209.dat (2018 FULL-YEAR FILE)
#
# This program is available at:
# https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/r_exercises
#
# -----------------------------------------------------------------------------

# Install and load packages ---------------------------------------------------

  # Can skip this part if already installed
  install.packages("survey")
  install.packages("foreign")
  install.packages("dplyr")
  install.packages("devtools")
  
  # Run this part each time you re-start R
  library(survey)
  library(foreign)
  library(dplyr)
  library(devtools)
  
  # This package facilitates file import
  install_github("e-mitchell/meps_r_pkg/MEPS") 
  library(MEPS)

# Set options to deal with lonely psu
  options(survey.lonely.psu='adjust');


# Read in data from FYC file --------------------------------------------------
#  !! IMPORTANT -- must use ASCII (.dat) file for 2018 data !!
  
  # Option 1: use 'MEPS' package
  h209  = read_MEPS(year = 2018, type = "FYC") # 2018 FYC
  
  # Option 2: Use R programming statements
  #
  # meps_path = "C:/MEPS/DATA/h209.dat"
  # source("https://meps.ahrq.gov/mepsweb/data_stats/download_data/pufs/h209/h209ru.txt")
  
  
  # View data
  head(h209) 
  
  
# Add variables for persons with any expense and persons under 65 -------------

  # Using tidyverse syntax here. The '%>%' is a pipe operator, which inverts
  # the order of the function call. For example, f(x) becomes x %>% f
  
  h209 = h209 %>%
    mutate(
      has_exp = (TOTEXP18 > 0), # persons with any expense
      age_cat = ifelse(AGELAST < 65, "<65", "65+")  # persons under age 65
    )

# QC check on new variables

  h209 %>%
    group_by(has_exp) %>%
    summarise(min = min(TOTEXP18), max = max(TOTEXP18))

  h209 %>%
    group_by(age_cat) %>%
    summarise(min = min(AGELAST), max = max(AGELAST))


# Define the survey design ----------------------------------------------------

  mepsdsgn = svydesign(
    id = ~VARPSU,
    strata = ~VARSTR,
    weights = ~PERWT18F,
    data = h209,
    nest = TRUE)

# Calculate expenditures ------------------------------------------------------
  
# Overall expenses
svymean(~TOTEXP18, design = mepsdsgn)
svytotal(~TOTEXP18, design = mepsdsgn)

# Percentage of persons with an expense
svymean(~has_exp, design = mepsdsgn)

# Mean expense per person with an expense
svymean(~TOTEXP18, design = subset(mepsdsgn, has_exp))

# Mean expense per person with an expense, by age category
svyby(~TOTEXP18, by = ~age_cat, FUN = svymean, design = subset(mepsdsgn, has_exp))


