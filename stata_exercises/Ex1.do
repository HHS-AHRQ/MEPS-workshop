********************************************************************************
*
*PROGRAM:     C:\work\MEPS_workshop\Ex1.do
*
*DESCRIPTION: THIS PROGRAM GENERATES THE FOLLOWING ESTIMATES ON NATIONAL HEALTH CARE, 2017: 
*
*	           (1) OVERALL EXPENSES 
*	           (2) PERCENTAGE OF PERSONS WITH AN EXPENSE
*	           (3) MEAN EXPENSE PER PERSON WITH AN EXPENSE OVERALL AND BY AGE
*
*
*INPUT FILE:  C:\work\MEPS_workshop\H201.dta (2017 FULL-YEAR FILE)
*
********************************************************************************

clear
set more off
capture log close
log using C:\work\MEPS_workshop\Ex1.log, replace
cd C:\work\MEPS_workshop

/* read in data from 2017 consolidated data file (hc-201) */
*import sasxport8 h201.ssp
import sasxport5 h201.ssp

keep totexp17 age17x age42x age31x varstr varpsu perwt17f
    
/* define expenditure variables  */
gen total=totexp17

/* create flag (1/0) variables for persons with an expense  */
gen any_expenditure=(total>0)

/* create a summary variable from end of year, 42, and 31 variables*/
gen age=age17x if age17x>=0
replace age=age42x if age42x>=0 & missing(age)
replace age=age31x if age31x>=0 & missing(age)

gen agecat=1 if age>=0 & age<=64
replace agecat=2 if age>64

/* qc check on new variables*/
list total any_expenditure age agecat age17x age42x age31x in 1/20, table

tab1 any_expenditure agecat, m
 
summarize total, d
summarize total if any_expenditure==1, d

/* identify the survey design characteristics */
svyset [pweight= perwt17f], strata( varstr) psu(varpsu) vce(linearized) singleunit(missing)

// overall expenses
svy: mean total
svy: total total
           
// percentage of persons with an expense
svy: mean any_expenditure		   
		   
// mean expense per person with an expense
svy, subpop(any_expenditure): mean total

// mean expense per person with an expense, by age category
svy, subpop(any_expenditure): mean total, over(agecat)

// mean expense per person with an expense, by age category using BRR for variance estimates
svy, subpop(any_expenditure): mean total, over(agecat)
