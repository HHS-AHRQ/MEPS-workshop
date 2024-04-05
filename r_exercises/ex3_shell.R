# -----------------------------------------------------------------------------
# This program shows how to link the MEPS-HC Medical Conditions file 
# to the Office-based medical visits file for data year 2021 to estimate:
#
#
# Overall:
#   - Total number of people w office-based visit for cancer
#   - Total number of office visits for cancer
#   - Total expenditures for office visits for cancer 
#
# By Age groups:
#   - Percent of people with office visit for cancer
#   - Avg per-person expenditures for office visits for cancer
#
#
# Input files:
#   - h229g.dta        (2021 Office-based medical visits file)
#   - h231.dta         (2021 Conditions file)
#   - h229if1.dta      (2021 CLNK: Condition-Event Link file)
#   - h233.dta         (2021 Full-Year Consolidated file)
# 
# Resources:
#   - CCSR codes: 
#   https://github.com/HHS-AHRQ/MEPS/blob/master/Quick_Reference_Guides/meps_ccsr_conditions.csv
# 
#   - MEPS-HC Public Use Files: 
#   https://meps.ahrq.gov/mepsweb/data_stats/download_data_files.jsp
# 
#   - MEPS-HC online data tools: 
#   https://datatools.ahrq.gov/meps-hc
#
# -----------------------------------------------------------------------------


# Install/load packages and set global options --------------------------------

# Can skip this part if already installed
# install.packages("survey")   # for survey analysis
# install.packages("foreign")  # for loading SAS transport (.ssp) files
# install.packages("haven")    # for loading Stata (.dta) files
# install.packages("dplyr")    # for data manipulation
# install.packages("tidyr")    # for data manipulation
# install.packages("devtools") # for loading "MEPS" package from GitHub
# 
# devtools::install_github("e-mitchell/meps_r_pkg/MEPS") # easier file import


# Load libraries (run this part each time you re-start R)
  library(survey)
  library(foreign)
  library(haven)
  library(dplyr)
  library(tidyr)
  library(MEPS)


# Set survey option for lonely PSUs
  options(survey.lonely.psu='adjust')

  # Additional option for adjusting variance for lonely PSUs within a domain
  #  - More info at https://r-survey.r-forge.r-project.org/survey/html/surveyoptions.html
  #  - Not running in these exercises, so SEs will match SAS, Stata
  #
  # options(survey.adjust.domain.lonely = TRUE) 
  

# Load datasets ---------------------------------------------------------------
  
#  OB   = Office-based medical visits file (record = medical visit)
#  COND = Medical conditions file (record = medical condition)
#  CLNK = Conditions-event link file (crosswalk between conditions and 
#             events, including PMED events)
#  FYC  = Full-year-consolidated file (record = MEPS sample person)

  
# Option 1 - load data files using read_MEPS from the MEPS package
 

  
  
  
  
  
  
# Option 2 - load Stata data files using read_dta from the haven package 

# ob21   <- read_dta("C:/MEPS/h229g.dta") 
# cond21 <- read_dta("C:/MEPS/h231.dta")
# clnk21 <- read_dta("C:/MEPS/h229if1.dta")
# fyc21  <- read_dta("C:/MEPS/h233.dta")

  
  

# Keep only needed variables ------------------------------------------------

#  Browse variables using MEPS-HC data tools variable explorer: 
#  -> http://datatools.ahrq.gov/meps-hc#varExp


  
  
  
  
  
  
  

# Prepare data for estimation -------------------------------------------------

# Subset condition records to CANCER (any CCSR = "NEO...") 
#  + FAC006 (Encounters for antineoplastic therapies)
#  - NEO073 (Benign neoplasms)


  
  
  
  

# view ICD10-CCSR combinations for cancer

  
  
  
  

# >> Note that same person can multiple cancers, and can even have multiple
#    conditions with the same ICD10CDX and CCSR values

  
# >> Example:
     cancer %>% filter(DUPERSID == '2320589102')



# Merge cancer conditions with OB event file, using CLNK as crosswalk
#  >> use multiple = "all" option for many-to-many merge


  
  
  
  

# QC: check that EVENTYPE = 1 for all rows

  
  
  
  

# >> Check events for example person:
     cancer_merged %>% filter(DUPERSID == '2320589102')


     

# De-duplicate on EVNTIDX so we don't count the same event twice

     
     
     
# >> Example of same event (EVNTIDX) for treating multiple cancer
     cancer_merged %>% filter(DUPERSID == '2326533101')




# >> Check example person:
     cancer_unique %>% filter(DUPERSID == '2326533101')



# Aggregate to person-level --------------------------------------------------

     
     
     
# Add indicator variable

     
     

# Merge onto FYC file ---------------------------------------------------------
#  >> Need to capture all Strata (VARSTR) and PSUs (VARPSU) for all MEPS sample 
#     persons for correct variance estimation


     
     

# QC: should have same number of rows as FYC file
 
     
     
      
# QC: age groups created correctly

     
     
     
  
# Check number of people with office visit, by age

     
     

# Define the survey design ----------------------------------------------------


     
     
     
     

# Calculate estimates ---------------------------------------------------------


# Overall:

     
     


# Percent of ppl with office visit for cancer
 
     
     
# Avg per-person exp. for office visits for cancer
 
     
     
    

# By Age Groups:

# - Percent of ppl with office visit for cancer, by age group
  
     
# - Avg per-person exp. for office visits for cancer, by age group
  
     
    

    




