# -----------------------------------------------------------------------------
# DESCRIPTION:  THIS PROGRAM ILLUSTRATES HOW TO POOL MEPS LONGITUDINAL DATA
#  FILES FROM DIFFERENT PANELS
#
# THE EXAMPLE USED IS PANELS 17-19 POPULATION AGE 26-30 WHO ARE UNINSURED BUT
#  HAVE HIGH INCOME IN THE FIRST YEAR
#
# DATA FROM PANELS 17, 18, AND 19 ARE POOLED.
#
# INPUT FILES:  (1) C:/MEPS/H183.ssp (PANEL 19 LONGITUDINAL FILE)
# 	            (2) C:/MEPS/h193.ssp (PANEL 20 LONGITUDINAL FILE)
# 	            (3) C:/MEPS/H202.ssp (PANEL 21 LONGITUDINAL FILE)
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

varlist = c("DUPERSID", "INSCOVY1", "INSCOVY2",
            "LONGWT",   "VARSTR",   "VARPSU",
            "POVCATY1", "AGEY1X",   "PANEL")

  # Option 1: use 'MEPS' package
  h183 = read_MEPS(file = "h183") %>% select(all_of(varlist)) # Panel 19 (2014-2015)
  h193 = read_MEPS(file = "h193") %>% select(all_of(varlist)) # Panel 20 (2015-2016)
  h202 = read_MEPS(file = "h202") %>% select(all_of(varlist)) # Panel 21 (2016-2017)
  
  # Option 2: use 'read.xport'
  # h183 = read.xport("C:/MEPS/DATA/h183.ssp") %>% select(all_of(varlist)) # Panel 19
  # h193 = read.xport("C:/MEPS/DATA/h193.ssp") %>% select(all_of(varlist)) # Panel 20
  # h202 = read.xport("C:/MEPS/DATA/h202.ssp") %>% select(all_of(varlist)) # Panel 21
  


# Stack longitudinal files ----------------------------------------------------
#  - Define pooled weight variable and subpop of interest
#  - Subpop = ages 26-30, uninsured, high income
#
# POVCATY1:
# -1 Inapplicable
#  1 Poor/negative
#  2 Near poor
#  3 Low income
#  4 Middle income
#  5 High income
#
# INSCOVY1:
# -1 Inapplicable
#  1 Any private
#  2 Public only
#  3 Uninsured

pool = bind_rows(h183, h193, h202) %>%
  mutate(poolwt = LONGWT / 3,
         subpop = (26 <= AGEY1X & AGEY1X <= 30 & POVCATY1 == 5 & INSCOVY1 == 3))

head(pool)

pool %>% 
  filter(subpop) %>% 
  count(INSCOVY2)


# Define the survey design ----------------------------------------------------

mepsdsgn = svydesign(
  id = ~VARPSU,
  strata = ~VARSTR,
  weights = ~poolwt,
  data = pool,
  nest = TRUE)

# Calculate survey estimates --------------------------------------------------
# Insurance status in the second year, for persons ages 26-30, uninsured and 
#  high income in the first year 
#
# INSCOVY2: 
#  -1 Inapplicable
#   1 Any Private
#   2 Public Only
#   3 Uninsured

svymean(~as.factor(INSCOVY2), design = subset(mepsdsgn, subpop))

