# -----------------------------------------------------------------------------
# This program generates National Totals and Per-person Averages for Narcotic
# analgesics and Narcotic analgesic combos for the U.S. civilian 
# non-institutionalized population, including:
#  - Number of purchases (fills)  
#  - Total expenditures          
#  - Out-of-pocket payments       
#  - Third-party payments        
#
# Input files:
#  - C:/MEPS/h224.dta  (2020 Full-year file)
#  - C:/MEPS/h220a.dta (2020 Prescribed medicines file)
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
  # fyc20 = read_dta("C:/MEPS/h224.dta")   # 2020 FYC
  # rx20  = read_dta("C:/MEPS/h220astata.dta")  # 2020 RX
  

# Keep only needed variables --------------------------------------------------
  
 
  
  
     

# Identify Narcotic analgesics or Narcotic analgesic combos -------------------
#  Use therapeutic classification codes (TC1S1_1)
#
# DUPERSID: PERSON ID (DUID + PID)
# RXRECIDX: UNIQUE RX/PRESCRIBED MEDICINE IDENTIFIER
# LINKIDX:  ID FOR LINKAGE TO COND/OTH EVENT FILES
# TC1S1_1:  MULTUM THERAPEUT SUB-SUB-CLASS FOR TC1S1
#
# RXXP20X:  SUM OF PAYMENTS RXSF20X-RXOU20X(IMPUTED)
# RXSF20X:  AMOUNT PAID, SELF OR FAMILY (IMPUTED)


  
  
  
  

# Sum data to person-level ----------------------------------------------------

 
  
  
  
  
  
  
  
  
# Merge the person-level expenditures to the FY PUF to get complete PSUs, Strata
 
  
  
  
  
  

# Define the survey design ----------------------------------------------------
  
 
  
  
  
  

# Calculate estimates ---------------------------------------------------------
#  National totals and Per-person Averages for:
#   - Number of purchases (fills)  -- n_purchase
#   - Total expenditures           -- tot
#   - Out-of-pocket payments       -- oop
#   - Third-party payments         -- third_payer
  
  
# National totals 

  
   
  
# Average per person

  
  

  