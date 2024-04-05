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
 
ob21   = read_MEPS(year = 2021, type = "OB")
cond21 = read_MEPS(year = 2021, type = "COND")
clnk21 = read_MEPS(year = 2021, type = "CLNK")
fyc21  = read_MEPS(year = 2021, type = "FYC")


# Option 2 - load Stata data files using read_dta from the haven package 

# ob21   <- read_dta("C:/MEPS/h229g.dta") 
# cond21 <- read_dta("C:/MEPS/h231.dta")
# clnk21 <- read_dta("C:/MEPS/h229if1.dta")
# fyc21  <- read_dta("C:/MEPS/h233.dta")


# Keep only needed variables ------------------------------------------------

#  Browse variables using MEPS-HC data tools variable explorer: 
#  -> http://datatools.ahrq.gov/meps-hc#varExp

ob21x   = ob21 %>% 
  select(PANEL, DUPERSID, EVNTIDX, EVENTRN, OBDATEYR, OBDATEMM, OBXP21X)

cond21x = cond21 %>% 
  select(PANEL, DUPERSID, CONDIDX, ICD10CDX, CCSR1X:CCSR3X)

fyc21x  = fyc21 %>% 
  select(PANEL, DUPERSID, AGELAST, PERWT21F, VARSTR, VARPSU)



# Prepare data for estimation -------------------------------------------------

# Subset condition records to CANCER (any CCSR = "NEO...") 
#  + FAC006 (Encounters for antineoplastic therapies)
#  - NEO073 (Benign neoplasms)


view_conditions = cond21 %>% 
  count(CCSR1X, CCSR2X, CCSR3X)

View(view_conditions)


cancer <- cond21x %>% 
  filter(
    grepl("NEO", CCSR1X) |
      grepl("NEO", CCSR2X) |
      grepl("NEO", CCSR3X) |
      
      CCSR1X == "FAC006" |
      CCSR2X == "FAC006" |
      CCSR3X == "FAC006" ) %>% 
  
  filter(! (CCSR1X == "NEO073" |
              CCSR2X == "NEO073" |
              CCSR3X == "NEO073" ) )


# view ICD10-CCSR combinations for cancer
cancer %>% 
  count(ICD10CDX, CCSR1X, CCSR2X, CCSR3X)


# >> Note that same person can multiple cancers, and can even have multiple
#    conditions with the same ICD10CDX and CCSR values

# >> Example:
     cancer %>% filter(DUPERSID == '2320589102')



# Merge cancer conditions with OB event file, using CLNK as crosswalk
#  >> use multiple = "all" option for many-to-many merge

cancer_merged <- cancer %>%
  inner_join(clnk21, by = c("PANEL", "DUPERSID", "CONDIDX"), multiple = "all") %>% 
  inner_join(ob21x, by = c("PANEL", "DUPERSID", "EVNTIDX"), multiple = "all") %>% 
  mutate(ob_visit = 1)


# QC: check that EVENTYPE = 1 for all rows
clnk21 %>% count(EVENTYPE)
cancer_merged %>% count(EVENTYPE)


# >> Check events for example person:
     cancer_merged %>% filter(DUPERSID == '2320589102')



# De-duplicate on EVNTIDX so we don't count the same event twice

     
# >> Example of same event (EVNTIDX) for treating multiple cancer
     cancer_merged %>% filter(DUPERSID == '2326533101')


cancer_unique = cancer_merged %>% 
  distinct(PANEL, DUPERSID, EVNTIDX, OBXP21X, ob_visit)


# >> Check example person:
     cancer_unique %>% filter(DUPERSID == '2326533101')



# Aggregate to person-level --------------------------------------------------
pers = cancer_unique %>% 
  group_by(DUPERSID) %>% 
  summarize(
    pers_XP      = sum(OBXP21X),   # total person exp. for cancer office visits
    pers_nvisits = sum(ob_visit))  # total number of cancer office visits
  
# Add indicator variable
pers = pers %>% 
  mutate(any_OB = 1)



# Merge onto FYC file ---------------------------------------------------------
#  >> Need to capture all Strata (VARSTR) and PSUs (VARPSU) for all MEPS sample 
#     persons for correct variance estimation

fyc_cancer <- fyc21x %>% 
  full_join(pers, by = "DUPERSID")  %>% 
  
  # replace NA with 0
  replace_na(list(pers_nvisits = 0, any_OB = 0)) %>% 
  
  # create age groups
  mutate(agegrps = case_when(
    AGELAST < 18 ~ "<18",
    AGELAST < 65 ~ "18-64",
    AGELAST >= 65 ~ "65+",
    TRUE ~ "ERROR"
  ))


# QC: should have same number of rows as FYC file
  nrow(fyc21x) == nrow(fyc_cancer)
  
# QC: age groups created correctly
  fyc_cancer %>% 
    group_by(agegrps) %>% 
    summarize(
      min_age = min(AGELAST),
      max_age = max(AGELAST))
    
  
# Check number of people with office visit, by age
  fyc_cancer %>% 
    count(any_OB, agegrps)
  
  

# Define the survey design ----------------------------------------------------

meps_dsgn <- svydesign(
  id = ~VARPSU,
  strata = ~VARSTR,
  weights = ~PERWT21F,
  data = fyc_cancer,
  nest = TRUE) 

cancer_dsgn = subset(meps_dsgn, any_OB == 1)


# Calculate estimates ---------------------------------------------------------


# Overall:

svytotal(~ any_OB +       # Total people w/ office visit for cancer 
           pers_nvisits + # Total number of office visits for cancer 
           pers_XP,       # Total expenditures for office visits for cancer
           design = cancer_dsgn)


# Percent of ppl with office visit for cancer
  svymean( ~any_OB,  design = meps_dsgn)  
  
# Avg per-person exp. for office visits for cancer
  svymean( ~pers_XP, design = cancer_dsgn) 

    

# By Age Groups:

# - Percent of ppl with office visit for cancer, by age group
    svyby(~any_OB, by = ~agegrps, FUN = svymean, design = meps_dsgn)

# - Avg per-person exp. for office visits for cancer, by age group
    svyby( ~pers_XP, by = ~agegrps, FUN = svymean, design = cancer_dsgn) 

    

    




