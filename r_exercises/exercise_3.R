# -----------------------------------------------------------------------------
# DESCRIPTION:  THIS PROGRAM ILLUSTRATES HOW TO POOL MEPS DATA FILES FROM
#  DIFFERENT YEARS THE EXAMPLE USED IS POPULATION AGE 26-30 WHO ARE UNINSURED
#  BUT HAVE HIGH INCOME DATA FROM 2017 AND 2018 ARE POOLED.
#
# VARIABLES WITH YEAR-SPECIFIC NAMES MUST BE RENAMED BEFORE COMBINING FILES:
#
# IN THIS PROGRAM THE INSURANCE COVERAGE VARIABLES 'INSCOV17' AND 'INSCOV18'
#  ARE RENAMED TO 'INSCOV'.
#
# SEE HC-036 (1996-2017 POOLED ESTIMATION FILE) FOR
#  INSTRUCTIONS ON POOLING AND CONSIDERATIONS FOR VARIANCE
#  ESTIMATION FOR PRE-2002 DATA.
#
# INPUT FILES: (1) C:/MEPS/H209.ssp (2018 FULL-YEAR FILE)
# 	           (2) C:/MEPS/H201.ssp (2017 FULL-YEAR FILE)
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

# Option 1: use 'MEPS' package
h209 = read_MEPS(year = 2018, type = "FYC") # 2018 FYC
h201 = read_MEPS(year = 2017, type = "FYC") # 2017 FYC

# Option 2: Use R programming statements
# 
# FYC 2018 file (h209):
#  meps_path = "C:/MEPS/DATA/h209.dat"
#  source("https://meps.ahrq.gov/mepsweb/data_stats/download_data/pufs/h209/h209ru.txt")
#
# FYC 2017 file (h201):
#  h201 = read.xport("C:/MEPS/DATA/h201.ssp")



# View data
head(h209)
head(h201)



# Rename year-specific variables prior to combining ---------------------------
h209x = h209 %>%
  rename(
    inscov = INSCOV18,
    perwt  = PERWT18F,
    povcat = POVCAT18,
    totslf = TOTSLF18) %>%
  select(DUPERSID, VARSTR, VARPSU, AGELAST, inscov, perwt, povcat, totslf)

h201x = h201 %>%
  rename(
    inscov = INSCOV17,
    perwt  = PERWT17F,
    povcat = POVCAT17,
    totslf = TOTSLF17) %>%
  select(DUPERSID, VARSTR, VARPSU, AGELAST, inscov, perwt, povcat, totslf)

# Stack data and define pooled weight variable and subpop of interest ---------
#  subpop = age 26-30, uninsured, high income
#
# POVCAT:
# -1 Inapplicable
#  1 Poor/negative
#  2 Near poor
#  3 Low income
#  4 Middle income
#  5 High income
#
# INSCOV:
# -1 Inapplicable
#  1 Any private
#  2 Public only
#  3 Uninsured

pool = bind_rows(h209x, h201x) %>%
  mutate(
    poolwt = perwt / 2, # divide perwt by number of years (2)
    subpop = (26 <= AGELAST & AGELAST <= 30 & povcat == 5 & inscov == 3))

# QC subpop

pool %>%
  filter(subpop) %>%
  group_by(AGELAST, povcat, inscov) %>%
  summarise(n())


# Define the survey design ----------------------------------------------------

mepsdsgn = svydesign(
  id = ~VARPSU,
  strata = ~VARSTR,
  weights = ~poolwt,
  data = pool,
  nest = TRUE)

# Calcuate survey estimates ---------------------------------------------------
#
# Average out-of-pocket expenditure for:
#  - persons 26-30, 
#  - who are uninsured the whole year (inscov = 3)
#  - and in a high income bracket (povcat = 5)
#  - averaged over 2017 and 2018

svymean(~totslf, design = subset(mepsdsgn, subpop))

