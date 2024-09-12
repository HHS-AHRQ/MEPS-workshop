# -----------------------------------------------------------------------------
# This program illustrates how to pool MEPS data files from different years. 
#
# The program pools 2019, 2020, and 2021 data and calculates:
#  - Percentage of people with Bladder Cancer (CABLADDR)
#  - Average expenditures per person with Bladder Cancer (TOTEXP, TOTSLF)
#
# Notes:
#  - Variables with year-specific names must be renamed before combining files
#    (e.g. 'TOTEXP21' and 'TOTEXP20' renamed to 'totexp')
# 
# Input files:
#  - C:/MEPS/h233.dta (2021 Full-year file)
#  - C:/MEPS/h224.dta (2020 Full-year file)
#  - C:/MEPS/h216.dta (2019 Full-year file)
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

  # Additional option for adjusting variance for lonely PSUs within a domain
  #  - More info at https://r-survey.r-forge.r-project.org/survey/html/surveyoptions.html
  #  - Not running in these exercises, so SEs will match SAS, Stata
  #
  # options(survey.adjust.domain.lonely = TRUE) 
  
  
# Load datasets ---------------------------------------------------------------

# Option 1 - load data files using read_MEPS from the MEPS package

  
  
  
  
    

# Option 2 - load Stata data files using read_dta from the haven package 
#  >> Replace "C:/MEPS" below with the directory you saved the files to.
  
  # fyc21 = read_dta("C:/MEPS/h233.dta") # 2021 FYC
  # fyc20 = read_dta("C:/MEPS/h224.dta") # 2020 FYC
  # fyc19 = read_dta("C:/MEPS/h216.dta") # 2019 FYC
  

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


  
  
  
  
  

# Define the survey design ----------------------------------------------------

  
  
  
  



# Calculate survey estimates ---------------------------------------------------
#  - Percentage of adults with Bladder Cancer
#  - Average expenditures per person, by cancer status (totexp, totslf)

  
  
# Percent with bladder cancer

  
  
  
# Avg. expenditures per person

  
  
  
