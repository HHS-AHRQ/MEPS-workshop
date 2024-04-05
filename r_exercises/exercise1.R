# -----------------------------------------------------------------------------
# This program generates the following estimates on national health care for 
# the U.S. civilian non-institutionalized population, 2021:
#  - Overall expenses (National totals)
#  - Percentage of persons with an expense
#  - Mean expense per person
#  - Mean/median expense per person with an expense:
#    - Mean expense per person with an expense
#    - Mean expense per person with an expense, by age group
#    - Median expense per person with an expense, by age group
#
# Input file:
#  - C:/MEPS/h233.dta (2021 Full-year file - Stata format)
#
# -----------------------------------------------------------------------------

# Install/load packages and set global options --------------------------------

# Can skip this part if already installed
  install.packages("survey")   # for survey analysis
  install.packages("foreign")  # for loading SAS transport (.ssp) files
  install.packages("haven")    # for loading Stata (.dta) files
  install.packages("dplyr")    # for data manipulation
  install.packages("devtools") # for loading "MEPS" package from GitHub
 
  devtools::install_github("e-mitchell/meps_r_pkg/MEPS") # easier file import
  
  
# Load libraries (run this part each time you re-start R)
  library(survey)
  library(foreign)
  library(haven)
  library(dplyr)
  library(MEPS)


# Set survey option for lonely PSUs
  options(survey.lonely.psu='adjust')
  
  # Additional option for adjusting variance for lonely PSUs within a domain
  #  - More info at https://r-survey.r-forge.r-project.org/survey/html/surveyoptions.html
  #  - Not running in these exercises, so SEs will match SAS, Stata
  #
  # options(survey.adjust.domain.lonely = TRUE) 
  

# Load datasets ---------------------------------------------------------------
 
# Option 1 - load data files using read_MEPS from the MEPS package
  fyc21 = read_MEPS(year = 2021, type = "FYC") # 2021 FYC

# Option 2 - load Stata data files using read_dta from the haven package 
#  >> Replace "C:/MEPS" below with the directory you saved the files to.
  
  fyc21_opt2 = read_dta("C:/MEPS/h233.dta")

  
# View data
  head(fyc21) 
  head(fyc21_opt2)
  

# Keep only needed variables --------------------------------------------------
# - codebook: 
#  https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_codebook.jsp?PUFId=H233 
  

# Using tidyverse syntax. The '%>%' is a pipe operator, which inverts
# the order of the function call. For example, mean(x) becomes x %>% mean
  
  fyc21_sub = fyc21 %>%
    select(
      AGELAST, TOTEXP21,
      DUPERSID, VARSTR, VARPSU, PERWT21F) # needed for survey design
  
  head(fyc21_sub)
  
  
# Add variables for persons with any expense and persons under 65 -------------

  fyc21x = fyc21_sub %>%
    mutate(
      has_exp = (TOTEXP21 > 0),                     # persons with any expense
      age_cat = ifelse(AGELAST < 65, "<65", "65+")  # persons under age 65
    )
  
  head(fyc21x)


# QC check on new variables
  
  fyc21x %>% 
    count(has_exp, age_cat)
  
  fyc21x %>%
    group_by(has_exp) %>%
    summarise(
      min = min(TOTEXP21), 
      max = max(TOTEXP21))
  
  fyc21x %>%
    group_by(age_cat) %>%
    summarise(
      min = min(AGELAST), 
      max = max(AGELAST))


# Define the survey design ----------------------------------------------------
    
  mepsdsgn = svydesign(
    id = ~VARPSU,
    strata = ~VARSTR,
    weights = ~PERWT21F,
    data = fyc21x,
    nest = TRUE)

  
# Calculate estimates ---------------------------------------------------------
#  - Overall expenses (National totals)
#  - Percentage of persons with an expense
#  - Mean expense per person
#  - Mean/median expense per person with an expense:
#    - Mean expense per person with an expense
#    - Mean expense per person with an expense, by age group
#    - Median expense per person with an expense, by age group

  
  options(digits = 10)
  
  
# Overall expenses (National totals)
  svytotal(~TOTEXP21, design = mepsdsgn) 

# Percentage of persons with an expense
  svymean(~has_exp, design = mepsdsgn)

# Mean expense per person
  svymean(~TOTEXP21, design = mepsdsgn) 
  
  
# Mean/median expense per person with an expense --------------------
# Subset design object to people with expense:
  has_exp_dsgn <- subset(mepsdsgn, has_exp)
  
# Mean expense per person with an expense
  svymean(~TOTEXP21, design = has_exp_dsgn)

# Mean expense per person with an expense, by age category
  svyby(~TOTEXP21, by = ~age_cat, FUN = svymean, design = has_exp_dsgn)


# Median expense per person with an expense, by age category
  svyby(~TOTEXP21, by  = ~age_cat, FUN = svyquantile, design = has_exp_dsgn,
    quantiles = c(0.5))
