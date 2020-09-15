**********************************************************************************
*
*PROGRAM:     C:\work\MEPS_workshop\Ex1.do
*
*DESCRIPTION: THIS PROGRAM GENERATES THE FOLLOWING ESTIMATES ON NATIONAL HEALTH CARE, 2018: 
*
*	           (1) OVERALL EXPENSES 
*	           (2) PERCENTAGE OF PERSONS WITH AN EXPENSE
*	           (3) MEAN EXPENSE PER PERSON WITH AN EXPENSE OVERALL AND BY AGE
*
*
*INPUT FILE:  C:\work\MEPS_workshop\H209.dta (2018 FULL-YEAR FILE)
*
*********************************************************************************

clear
set more off
capture log close
log using C:\MEPS\statapgms\Ex1.log, replace

cd C:\MEPS\DATA

/* read in data from 2018 consolidated data file (hc-209) */
use DUPERSID TOTEXP18 AGE18X AGE53X AGE42X AGE31X VARSTR VARPSU PERWT18F RACETHX using h209, clear
rename *, lower
    
/* define expenditure variables  */
gen total=totexp18

/* create flag (1/0) variables for persons with an expense  */
gen any_expenditure=(total>0)

/* create a summary variable from end of year, 42, and 31 variables*/
gen age=age18x if age18x>=0
replace age=age53x if age53x>=0 & missing(age)
replace age=age42x if age42x>=0 & missing(age)
replace age=age31x if age31x>=0 & missing(age)

gen agecat=1 if age>=0 & age<=64
replace agecat=2 if age>64

/* qc check on new variables*/
list total any_expenditure age agecat age18x age42x age31x in 1/20, table

tab1 any_expenditure agecat, m
 
summarize total, d
summarize total if any_expenditure==1, d

/* identify the survey design characteristics */
svyset varpsu [pw = perwt18f], strata(varstr) vce(linearized) singleunit(missing)
// overall expenses
svy: mean total
svy: total total
           
// percentage of persons with an expense
svy: mean any_expenditure		   
		   
// mean expense per person with an expense
svy, subpop(any_expenditure): mean total

// mean expense per person with an expense, by age category
svy, subpop(any_expenditure): mean total, over(agecat)
svy: mean total if any_expenditure==1, over(agecat)

svy, subpop(any_expenditure): mean total, over(racethx)

