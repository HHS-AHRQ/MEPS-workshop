# -----------------------------------------------------------------------------
# This program includes a regression example for persons receiving a flu shot
# in the last 12 months for the U.S. civilian non-institutionalized population, 
# including:
#  - Percentage of people with a flu shot
#  - Logistic regression: to identify demographic factors associated with
#    receiving a flu shot
#
# Input file: 
#  - C:/MEPS/h209.dta (2018 Full-year file)
#
# -----------------------------------------------------------------------------

# Install and load packages ---------------------------------------------------
# 
# Can skip this part if already installed
# install.packages("survey")   # for survey analysis
# install.packages("foreign")  # for loading SAS transport (.ssp) files
# install.packages("haven")    # for loading Stata (.dta) files
# install.packages("dplyr")    # for data manipulation
# install.packages("devtools") # for loading "MEPS" package from GitHub
# 
# devtools::install_github("e-mitchell/meps_r_pkg/MEPS") # easier file import


# Run this part each time you re-start R
  library(survey)
  library(foreign)
  library(haven)
  library(dplyr)
  library(MEPS)


# Set options to deal with lonely psu
  options(survey.lonely.psu='adjust');


# Read in data from FYC file --------------------------------------------------

 
  
  # # Alternative:
  # fyc18 = read_dta("C:/MEPS/h209.dta") # 2018 FYC

  # View data
 
  
  
  
# Keep only needed variables --------------------------------------------------
 
  
   
  
# Create variables ------------------------------------------------------------
#  - Convert ADFLST42 from 1/2 to 0/1 (for logistic regression)
#  - Create 'subpop' to exclude people with Missing 'ADFLST42'
  
 
 
  
  
  # QC new variable

   
  
# Check variables in regression -----------------------------------------------
  

  
  # SEX: 
  #   1 = MALE
  #   2 = FEMALE
  
  
  
  # RACETHX: 
  #   1 = HISPANIC
  #   2 = NON-HISPANIC WHITE
  #   3 = NON-HISPANIC BLACK
  #   4 = NON-HISPANIC ASIAN
  #   5 = NON-HISPANIC OTHER/MULTIPLE
  
  
  

  # INSCOV:
  #   1 = ANY PRIVATE
  #   2 = PUBLIC ONLY
  #   3 = UNINSURED
  
  
  
  # AGELAST: 0-85

  
# Define the survey design ----------------------------------------------------
  
  
  

  
  # QC sub-design
 
  
  
  
# Calculate survey estimates ---------------------------------------------------
#  - Percentage of people with a flu shot
#  - Logistic regression: to identify demographic factors associated with
#    receiving a flu shot  

  
# Percentage of people with a flu shot
 
  
  
  
# Logistic regression
# - specify 'family = quasibinomial' to get rid of warning messages
  
  
  
  
  
  