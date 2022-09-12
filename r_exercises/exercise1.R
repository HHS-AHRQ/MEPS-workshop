# -----------------------------------------------------------------------------
# This program generates the following estimates on national health care for 
# the U.S. civilian non-institutionalized population, 2020:
#  - Overall expenses (National totals)
#  - Percentage of persons with an expense
#  - Mean expense per person
#  - Mean/median expense per person with an expense:
#    - Mean expense per person with an expense
#    - Mean expense per person with an expense, by age group
#    - Median expense per person with an expense, by age group
#
# Input file:
#  - C:/MEPS/h224.dta (2020 Full-year file - Stata format)
#
# -----------------------------------------------------------------------------

# Install and load packages ---------------------------------------------------

# Can skip this part if already installed
  install.packages("survey")   # for survey analysis
  install.packages("foreign")  # for loading SAS transport (.ssp) files
  install.packages("haven")    # for loading Stata (.dta) files
  install.packages("dplyr")    # for data manipulation
  install.packages("devtools") # for loading "MEPS" package from GitHub
 
  devtools::install_github("e-mitchell/meps_r_pkg/MEPS") # easier file import
  
  
# Run this part each time you re-start R
  library(survey)
  library(foreign)
  library(haven)
  library(dplyr)
  library(MEPS)


# Set options to deal with lonely psu
  options(survey.lonely.psu='adjust');


# Read in data from FYC file --------------------------------------------------
 
# Option 1: use 'MEPS' package
  fyc20 = read_MEPS(year = 2020, type = "FYC") # 2020 FYC

# Option 2: Use Stata format (recommended for Data Year 2020 and later)
  fyc20_opt2 = read_dta("C:/MEPS/h224.dta")

# View data
  head(fyc20) 
  head(fyc20_opt2)
  

# Keep only needed variables --------------------------------------------------
# - codebook: https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_codebook.jsp?PUFId=h224

# Using tidyverse syntax. The '%>%' is a pipe operator, which inverts
# the order of the function call. For example, mean(x) becomes x %>% mean
  
  fyc20_sub = fyc20 %>%
    select(
      AGELAST, TOTEXP20,
      DUPERSID, VARSTR, VARPSU, PERWT20F) # needed for survey design
  
  head(fyc20_sub)
  
  
# Add variables for persons with any expense and persons under 65 -------------

  fyc20x = fyc20_sub %>%
    mutate(
      has_exp = (TOTEXP20 > 0),                     # persons with any expense
      age_cat = ifelse(AGELAST < 65, "<65", "65+")  # persons under age 65
    )
  
  head(fyc20x)


# QC check on new variables
  
  fyc20x %>% 
    count(has_exp, age_cat)
  
  fyc20x %>%
    group_by(has_exp) %>%
    summarise(
      min = min(TOTEXP20), 
      max = max(TOTEXP20))
  
  fyc20x %>%
    group_by(age_cat) %>%
    summarise(
      min = min(AGELAST), 
      max = max(AGELAST))


# Define the survey design ----------------------------------------------------
    
  mepsdsgn = svydesign(
    id = ~VARPSU,
    strata = ~VARSTR,
    weights = ~PERWT20F,
    data = fyc20x,
    nest = TRUE)

  
# Calculate estimates ---------------------------------------------------------
#  - Overall expenses (National totals)
#  - Percentage of persons with an expense
#  - Mean expense per person
#  - Mean/median expense per person with an expense:
#    - Mean expense per person with an expense
#    - Mean expense per person with an expense, by age group
#    - Median expense per person with an expense, by age group

# Overall expenses (National totals)
  svytotal(~TOTEXP20, design = mepsdsgn) 

# Percentage of persons with an expense
  svymean(~has_exp, design = mepsdsgn)

# Mean expense per person
  svymean(~TOTEXP20, design = mepsdsgn) 
  
  
# Mean/median expense per person with an expense --------------------
# Subset design object to people with expense:
  has_exp_dsgn <- subset(mepsdsgn, has_exp)
  
# Mean expense per person with an expense
  svymean(~TOTEXP20, design = has_exp_dsgn)

# Mean expense per person with an expense, by age category
  svyby(~TOTEXP20, by = ~age_cat, FUN = svymean, design = has_exp_dsgn)


# Median expense per person with an expense, by age category
  svyby(~TOTEXP20, by  = ~age_cat, FUN = svyquantile, design = has_exp_dsgn,
    quantiles = c(0.5))
