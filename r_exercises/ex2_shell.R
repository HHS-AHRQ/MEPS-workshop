# -----------------------------------------------------------------------------
# This program illustrates how to pool MEPS data files from different years. 
# It  demonstrates use of the Pooled Variance file (h36u19) to pool data years 
# before and after 2019.
# 
#
# The program pools 2018, 2019, and 2020 data and calculates:
#  - Percentage of people with Bladder Cancer (CABLADDR)
#  - Average expenditures per person with Bladder Cancer (TOTEXP, TOTSLF)
#
# Notes:
#  - Variables with year-specific names must be renamed before combining files
#    (e.g. 'TOTEXP19' and 'TOTEXP20' renamed to 'totexp')
#
#  - When pooling data years before and after 2002 or 2019, the Pooled Variance 
#    file (h36u20) must be used for correct variance estimation 
#
# 
# Input files: 
#  - C:/MEPS/h224.dta (2020 Full-year file)
#  - C:/MEPS/h216.dta (2019 Full-year file)
#  - C:/MEPS/h209.dta (2018 Full-year file)
#  - C:/MEPS/h36u20.dta (Pooled Variance Linkage file)
#
# -----------------------------------------------------------------------------

# Install/load packages and set global options --------------------------------

# Can skip this part if already installed
# install.packages("survey")   # for survey analysis
# install.packages("foreign")  # for loading SAS transport (.ssp) files
# install.packages("haven")    # for loading Stata (.dta) files
# install.packages("dplyr")    # for data manipulation
# install.packages("devtools") # for loading "MEPS" package from GitHub
# 
# devtools::install_github("e-mitchell/meps_r_pkg/MEPS") # easier file import


# Load libraries (run this part each time you re-start R)
  library(survey)
  library(foreign)
  library(haven)
  library(dplyr)
  library(MEPS)

# Set survey option for lonely PSUs
  options(survey.lonely.psu='adjust')
  options(survey.adjust.domain.lonely = TRUE)
  

# Load datasets ---------------------------------------------------------------

# Option 1 - load data files using read_MEPS from the MEPS package

  
  
  
  
   
  
  
# Option 2 - load Stata data files using read_dta from the haven package 
#  >> Replace "C:/MEPS" below with the directory you saved the files to.
  
  # fyc20 = read_dta("C:/MEPS/h224.dta") # 2020 FYC
  # fyc19 = read_dta("C:/MEPS/h216.dta") # 2019 FYC
  # fyc18 = read_dta("C:/MEPS/h209.dta") # 2018 FYC

  # >> Note: File name for linkage file will change every year!!
  # linkage = read_dta("C:/MEPS/h36u20.dta") # Pooled Linkage file

  
  
# View data -------------------------------------------------------------------

# From the documentation: 
#  - Questions about cancer were asked only of persons aged 18 or older. 
#  - CANCERDX asks whether person ever diagnosed with cancer 
#  - If YES, then asked what type (CABLADDR, CABLOOD, CABREAST...)

  
  
  
  


# Create variables ------------------------------------------------------------
#  - bladder_cancer = "1 Yes" if CABLADDR = 1
#  - bladder_cancer = "2 No" if CABLADDR = 2 or CANCERDX = 2


  
  
  


# QC variables:

  
  
  
  
   
  
# Rename year-specific variables prior to combining --------------------------- 
  
  
  
  
  
  
  
  
  
  


# Stack data and define pooled weight variable ---------------------------------
#  - for poolwt, divide perwt by number of years (3):


  
  
  
  

# Merge the Pooled Linkage Variance file (since pooling before and after 2019 data)
#  Notes: 
#   - DUPERSIDs are recycled, so must join by DUPERSID AND PANEL
#   - File name will change every year!! (e.g. 'h36u21' once 2021 data is added)

  
  
  
# QC:

  
  
  


# Define the survey design ----------------------------------------------------
#  - Use PSU9620 and STRA9620 variables, since pooling before and after 2019


  
  
  
  
  
  
  

# Calculate survey estimates ---------------------------------------------------
#  - Percentage of adults with Bladder Cancer
#  - Average expenditures per person, by Joint Pain status (totexp, totslf)

# Percent with bladder cancer

  
  
  
# Avg. expenditures per person

  
  
  
  
  
  
  
  
