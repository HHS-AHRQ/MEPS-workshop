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

  


# Set survey option for lonely PSUs
 
  
  
  
  # Additional option for adjusting variance for lonely PSUs within a domain
  #  - More info at https://r-survey.r-forge.r-project.org/survey/html/surveyoptions.html
  #  - Not running in these exercises, so SEs will match SAS, Stata
  #
  # options(survey.adjust.domain.lonely = TRUE) 
  

  
  
# Load datasets ---------------------------------------------------------------
 
# Option 1 - load data files using read_MEPS from the MEPS package

 
  
  
# Option 2 - load Stata data files using read_dta from the haven package 
#  >> Replace "C:/MEPS" below with the directory you saved the files to.
  
  
  
  
# View data

  
  
    

# Keep only needed variables --------------------------------------------------
# - codebook: 
#  https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_codebook.jsp?PUFId=H233 
  

# Using tidyverse syntax. The '%>%' is a pipe operator, which inverts
# the order of the function call. For example, mean(x) becomes x %>% mean
  
 
  
  
  
  
  
# Add variables for persons with any expense and persons under 65 -------------


  
  
  


# QC check on new variables
  

  


# Define the survey design ----------------------------------------------------
    
 
  
  
  
  
# Calculate estimates ---------------------------------------------------------
#  - Overall expenses (National totals)
#  - Percentage of persons with an expense
#  - Mean expense per person
#  - Mean/median expense per person with an expense:
#    - Mean expense per person with an expense
#    - Mean expense per person with an expense, by age group
#    - Median expense per person with an expense, by age group

  
  
# Overall expenses (National totals)

  
  
# Percentage of persons with an expense

  
  
# Mean expense per person

  
    
  
# Mean/median expense per person with an expense --------------------
# Subset design object to people with expense:
 
  
  
   
# Mean expense per person with an expense

  
  
  
# Mean expense per person with an expense, by age category
 
  
  

# Median expense per person with an expense, by age category
 
  
  
  
  