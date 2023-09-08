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
 
ob20   = read_MEPS(year = 2020, type = "OB")
cond20 = read_MEPS(year = 2020, type = "COND")
clnk20 = read_MEPS(year = 2020, type = "CLNK")
fyc20  = read_MEPS(year = 2020, type = "FYC")


# Option 2 - load Stata data files using read_dta from the haven package 

# ob20   <- read_dta("C:/MEPS/h220g.dta") 
# cond20 <- read_dta("C:/MEPS/h222.dta")
# clnk20 <- read_dta("C:/MEPS/h220if1.dta")
# fyc20  <- read_dta("C:/MEPS/h224.dta")


# Keep only needed variables ------------------------------------------------

#  Browse variables using MEPS-HC data tools variable explorer: 
#  -> http://datatools.ahrq.gov/meps-hc#varExp

ob20x   = ob20 %>% 
  select(PANEL, DUPERSID, EVNTIDX, EVENTRN, OBDATEYR, OBDATEMM, 
         TELEHEALTHFLAG, OBXP20X)

cond20x = cond20 %>% 
  select(PANEL, DUPERSID, CONDIDX, ICD10CDX, CCSR1X:CCSR3X)

fyc20x  = fyc20 %>% 
  select(PANEL, DUPERSID, AGELAST, PERWT20F, VARSTR, VARPSU)



# Prepare data for estimation -------------------------------------------------

# Subset condition records to COVID (any CCSR = "INF012") 

covid <- cond20x %>% 
  filter(CCSR1X == "INF012" | CCSR2X == "INF012" | CCSR3X == "INF012")


# >> Note that same person can have 'duplicate' conditions. This can happen 
#    when the full ICD10s are different but the collapsed 3-digit ICD10CDX is 
#    the same

# >> Example:
covid %>% filter(DUPERSID == '2326578104')


# view ICD10-CCSR combinations for COVID
covid %>% 
  count(ICD10CDX, CCSR1X, CCSR2X, CCSR3X) %>% 
  print(n = 100)



# Merge COVID conditions with OB event file, using CLNK as crosswalk
#  >> multiple = "all" option new in dplyr 1.1

covid_merged <- covid %>%
  inner_join(clnk20, by = c("PANEL", "DUPERSID", "CONDIDX"), multiple = "all") %>% 
  inner_join(ob20x, by = c("PANEL", "DUPERSID", "EVNTIDX"), multiple = "all") %>% 
  mutate(ob_visit = 1)


# QC: check that EVENTYPE = 1 for all rows
clnk20 %>% count(EVENTYPE)
covid_merged %>% count(EVENTYPE)


# Check events for example person:
covid_merged %>% filter(DUPERSID == '2326578104')



# Check if any duplicate EVNTIDX
# - if so, would need to de-duplicate so we don't count the same event twice
covid_merged %>% pull(EVNTIDX) %>% duplicated %>% sum



# Aggregate to person-level --------------------------------------------------
pers = covid_merged %>% 
  group_by(DUPERSID) %>% 
  summarize(
    pers_XP      = sum(OBXP20X),   # total person exp. for COVID office visits
    pers_nvisits = sum(ob_visit))  # total number of COVID office visits
  
# Add indicator variable
pers = pers %>% 
  mutate(any_OB = 1)



# Merge onto FYC file ---------------------------------------------------------
#  >> Need to capture all Strata (VARSTR) and PSUs (VARPSU) for all MEPS sample 
#     persons for correct variance estimation

fyc_covid <- fyc20x %>% 
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
  nrow(fyc20x) == nrow(fyc_covid)
  
# QC: age groups created correctly
  fyc_covid %>% 
    group_by(agegrps) %>% 
    summarize(
      min_age = min(AGELAST),
      max_age = max(AGELAST))
    
  
# Check number of people with office visit, by age
  fyc_covid %>% 
    count(any_OB, agegrps)
  
  

# Define the survey design ----------------------------------------------------

meps_dsgn <- svydesign(
  id = ~VARPSU,
  strata = ~VARSTR,
  weights = ~PERWT20F,
  data = fyc_covid,
  nest = TRUE) 

covid_dsgn = subset(meps_dsgn, any_OB == 1)


# Calculate estimates ---------------------------------------------------------


# Overall:

svytotal(~ any_OB +       # Total people w/ office visit for COVID 
           pers_nvisits + # Total number of office visits for COVID 
           pers_XP,       # Total expenditures for office visits for COVID
           design = covid_dsgn)


# Percent of ppl with office visit for COVID
  svymean( ~any_OB,  design = meps_dsgn)  
  
# Avg per-person exp. for office visits for COVID
  svymean( ~pers_XP, design = covid_dsgn) 

    

# By Age Groups:

# - Percent of ppl with office visit for COVID, by age group
    svyby(~any_OB, by = ~agegrps, FUN = svymean, design = meps_dsgn)

# - Avg per-person exp. for office visits for COVID, by age group
    svyby( ~pers_XP, by = ~agegrps, FUN = svymean, design = covid_dsgn) 

    

    
# BONUS: A note on Telehealth --------------------------------------------------
#  - telehealth questions were added to the survey in Fall of 2020           
#  - TELEHEALTHFLAG = -15 for events reported before telehealth questions    
#  - Recommendation: imputation or sensitivity analysis                      

covid_merged %>% 
  count(OBDATEMM, TELEHEALTHFLAG) %>% 
  pivot_wider(names_from = TELEHEALTHFLAG, values_from = n)






