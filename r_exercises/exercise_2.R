# -----------------------------------------------------------------------------
# PURPOSE: THIS PROGRAM GENERATES SELECTED ESTIMATES FOR A 2018 VERSION OF
#          Purchases and Expenses for Narcotic analgesics or Narcotic analgesic combos
#
#  - TOTAL EXPENSE FOR Narcotic analgesics or Narcotic analgesic combos
#
#  - TOTAL NUMBER OF PURCHASES OF Narcotic analgesics or Narcotic analgesic combos
#
#  - AVERAGE TOTAL, OUT OF POCKET, AND THIRD PARTY PAYER EXPENSE FOR Narcotic
#        analgesics or Narcotic analgesic combos PER PERSON WITH A
#        Narcotic analgesics or Narcotic analgesic combos MEDICINE PURCHASE
#
#   INPUT FILES:  (1) C:/MEPS/H209.ssp  (2018 FULL-YEAR CONSOLIDATED PUF)
#                 (2) C:/MEPS/H206A.ssp (2018 PRESCRIBED MEDICINES PUF)
#
# This program is available at:
# https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/r_exercises
#
# -----------------------------------------------------------------------------

# Install and load packages ---------------------------------------------------

  # Can skip this part if already installed
  install.packages("survey")
  install.packages("foreign")
  install.packages("dplyr")
  install.packages("devtools")
  
  # Run this part each time you re-start R
  library(survey)
  library(foreign)
  library(dplyr)
  library(devtools)
  
  # This package facilitates file import
  install_github("e-mitchell/meps_r_pkg/MEPS") 
  library(MEPS)

# Set options to deal with lonely psu
options(survey.lonely.psu='adjust');


# Read in data from FYC file --------------------------------------------------
#  !! IMPORTANT -- must use ASCII (.dat) file for 2018 data !!

h209  = read_MEPS(year = 2018, type = "FYC") # 2018 FYC
h206a = read_MEPS(year = 2018, type = "RX")  # 2018 RX


# Identify Narcotic analgesics or Narcotic analgesic combos -------------------
#  Use therapeutic classification codes (TC1S1_1)
#
# DUPERSID: PERSON ID (DUID + PID)
# RXRECIDX: UNIQUE RX/PRESCRIBED MEDICINE IDENTIFIER
# LINKIDX:  ID FOR LINKAGE TO COND/OTH EVENT FILES
# TC1S1_1:  MULTUM THERAPEUT SUB-SUB-CLASS FOR TC1S1
#
# RXXP18X:  SUM OF PAYMENTS RXSF18X-RXOU18X(IMPUTED)
# RXSF18X:  AMOUNT PAID, SELF OR FAMILY (IMPUTED)

narc = h206a %>%
  filter(TC1S1_1 %in% c(60, 191)) %>%
  select(DUPERSID, RXRECIDX, LINKIDX, TC1S1_1, RXXP18X, RXSF18X)

head(narc)
table(narc$TC1S1_1)


# Sum data to person-level ----------------------------------------------------

narc_pers = narc %>%
  group_by(DUPERSID) %>%
  summarise(
    tot = sum(RXXP18X),
    oop = sum(RXSF18X),
    n_purchase = n()) %>%
  mutate(
    third_payer = tot - oop,
    any_narc = 1)

head(narc_pers)


# Merge the person-level expenditures to the FY PUF to get complete PSUs, Strata

fyc = h209 %>% select(DUPERSID, VARSTR, VARPSU, PERWT18F)

narc_fyc = full_join(narc_pers, fyc, by = "DUPERSID")

head(narc_fyc)


# Define the survey design ----------------------------------------------------

mepsdsgn = svydesign(
  id = ~VARPSU,
  strata = ~VARSTR,
  weights = ~PERWT18F,
  data = narc_fyc,
  nest = TRUE)

# Calculate estimates on expenditures and use ---------------------------------
# n_purchase  = Number of fills per person, 
# tot         = Expenditures per person
# oop         = Out-of-pocket payments per person
# third_payer = Third-payer payments per person

# Average per person
svymean(~n_purchase + tot + oop + third_payer,
        design = subset(mepsdsgn, any_narc == 1))

# Totals for 2018
svytotal(~n_purchase + tot + oop + third_payer,
        design = subset(mepsdsgn, any_narc == 1))
