# -----------------------------------------------------------------------------
# This program illustrates how to pool MEPS data files from different years. It
# highlights one example of a discontinuity that may be encountered when 
# working with data from before and after the 2018 CAPI re-design. 
#
# It also demonstrates use of the Pooled Variance file (h36u19) to pool data 
# years before and after 2019.
# 
#
# The program pools 2017, 2018, and 2019 data and calculates:
#  - Percentage of people with Joint Pain / Arthritis (JTPAIN**, ARTHDX)
#  - Average expenditures per person, by Joint Pain status (TOTEXP, TOTSLF)
#
# Notes:
#  - Variables with year-specific names must be renamed before combining files
#    (e.g. 'TOTEXP18' and 'TOTEXP18' renamed to 'totexp')
#
#  - When pooling data years before and after 2002 or 2019, the Pooled Variance 
#    file (h36u19) must be used for correct variance estimation 
#
# 
# Input files: 
#  - C:/MEPS/h216.dta (2019 Full-year file)
#  - C:/MEPS/h209.dta (2018 Full-year file)
#  - C:/MEPS/h201.dta (2017 Full-year file)
#  - C:/MEPS/h36u19.dta (Pooled Variance Linkage file)
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


# Read in data ----------------------------------------------------------------
 
  
  
  
  
  # # Alternative:
  # fyc19 = read_dta("C:/MEPS/h216.dta") # 2019 FYC
  # fyc18 = read_dta("C:/MEPS/h209.dta") # 2018 FYC
  # fyc17 = read_dta("C:/MEPS/h201.dta") # 2017 FYC
  
  # >> Note: File name for linkage file will change every year!!
  # linkage = read_dta("C:/MEPS/h36u19.dta") # Pooled Linkage file
  
  

# View data -------------------------------------------------------------------
# JTPAIN** and ARTHDX values
#  -15 = Cannot be computed (2018 and later)
#   -9 = Not ascertained (pre-2018)
#   -8 = Don't know
#   -7 = Refused
#   -1 = Inapplicable
#    1 = Yes
#    2 = No

  
  
# Starting in 2018, most people that report Arthritis (ARTHDX = '1 Yes') have 
#  JTPAIN31_M18 = '-1 Inapplicable' (due to new skip pattern)

  
  
  

# Create variables ------------------------------------------------------------
#  - any_jtpain = "1 YES" if JTPAIN** = 1 OR ARTHDX = 1
#  - any_jtpain = "Missing" if JTPAIN < 0 AND ARTHDX < 0 


  
  

# QC variables:

  
  
  


# Rename year-specific variables prior to combining ---------------------------

  
  
  
  
  

# Stack data and define pooled weight variable and subpop of interest ---------
#  - Subpop: AGELAST >= 18 AND any_jtpain not missing

  
  
  

# Merge the Pooled Linkage Variance file (since pooling 2019 data) ---
#  Notes: 
#   - DUPERSIDs are recycled, so must join by DUPERSID AND PANEL
#   - File name will change every year!! (e.g. 'h36u20' once 2020 data is added)

  
  
  
# QC:

  
  


# Define the survey design ----------------------------------------------------
#  - Use PSU9619 and STRA9619 variables, since pooling before and after 2019

  
  


# Calculate survey estimates ---------------------------------------------------
#  - Percentage of people with Joint Pain / Arthritis (any_jtpain)
#  - Average expenditures per person, by Joint Pain status (totexp, totslf)

  
# Percent with any joint pain (any_jtpain)

  

# Avg. expenditures per person

  

