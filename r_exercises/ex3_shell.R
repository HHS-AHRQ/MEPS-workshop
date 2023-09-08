# -----------------------------------------------------------------------------
# This program shows how to link the MEPS-HC Medical Conditions file 
# to the Office-based medical visits file for data year 2020 to estimate:
#
#
# Overall:
#   - Total number of people w office-based visit for COVID
#   - Total number of office visits for COVID
#   - Total expenditures for office visits for COVID 
#
# By Age groups:
#   - Percent of people with office visit for COVID
#   - Avg per-person expenditures for office visits for COVID
#
#
# Input files:
#   - h220g.dta        (2020 Office-based medical visits file)
#   - h222.dta         (2020 Conditions file)
#   - h220if1.dta      (2020 CLNK: Condition-Event Link file)
#   - h224.dta         (2020 Full-Year Consolidated file)
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
  options(survey.adjust.domain.lonely = TRUE)


# Load datasets ---------------------------------------------------------------
  
#  OB   = Office-based medical visits file (record = medical visit)
#  COND = Medical conditions file (record = medical condition)
#  CLNK = Conditions-event link file (crosswalk between conditions and 
#             events, including PMED events)
#  FYC  = Full-year-consolidated file (record = MEPS sample person)

  
# Option 1 - load data files using read_MEPS from the MEPS package
 

  
  
  


# Option 2 - load Stata data files using read_dta from the haven package 

# ob20   <- read_dta("C:/MEPS/h220g.dta") 
# cond20 <- read_dta("C:/MEPS/h222.dta")
# clnk20 <- read_dta("C:/MEPS/h220if1.dta")
# fyc20  <- read_dta("C:/MEPS/h224.dta")


# Keep only needed variables ------------------------------------------------

#  Browse variables using MEPS-HC data tools variable explorer: 
#  -> http://datatools.ahrq.gov/meps-hc#varExp


  
  
  
  
  
  


# Prepare data for estimation -------------------------------------------------

# Subset condition records to COVID (any CCSR = "INF012") 

  
  
  
  
  

# >> Note that same person can have 'duplicate' conditions. This can happen 
#    when the full ICD10s are different but the collapsed 3-digit ICD10CDX is 
#    the same

  
# >> Example:
covid %>% filter(DUPERSID == '2326578104')

  
  

# view ICD10-CCSR combinations for COVID

  
  
  
  

# Merge COVID conditions with OB event file, using CLNK as crosswalk
#  >> multiple = "all" option new in dplyr 1.1


  
  
  
  
# QC: check that EVENTYPE = 1 for all rows

  
  
  
# Check events for example person:
covid_merged %>% filter(DUPERSID == '2326578104')



# Check if any duplicate EVNTIDX
# - if so, would need to de-duplicate so we don't count the same event twice





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




# Percent of ppl with office visit for COVID

  
# Avg per-person exp. for office visits for COVID


    

# By Age Groups:

# - Percent of ppl with office visit for COVID, by age group
 

# - Avg per-person exp. for office visits for COVID, by age group


    

    
# BONUS: A note on Telehealth --------------------------------------------------
#  - telehealth questions were added to the survey in Fall of 2020           
#  - TELEHEALTHFLAG = -15 for events reported before telehealth questions    
#  - Recommendation: imputation or sensitivity analysis                      




