**********************************************************************************
*
*PROGRAM:     C:\MEPS\STATA\PROG\EXERCISE1.do
*
*DESCRIPTION: THIS PROGRAM GENERATES THE FOLLOWING ESTIMATES ON NATIONAL HEALTH CARE, 2017: 
*
*	           (1) OVERALL EXPENSES 
*	           (2) PERCENTAGE OF PERSONS WITH AN EXPENSE
*	           (3) MEAN EXPENSE PER PERSON WITH AN EXPENSE
*
*
*INPUT FILE:  C:\MEPS\STATA\DATA\h201.ssp (2017 FULL-YEAR FILE)
*
*********************************************************************************

clear
set more off
capture log close
cd c:\meps\

log using Ex1.log, replace

/* read in data from 2017 consolidated data file (hc-201) */
import sasxport "C:\MEPS\h201.ssp"
keep totexp17 age17x age42x age31x varstr varpsu perwt17f
    
/* define expenditure variables  */
gen total=totexp17

/* create flag (1/0) variables for persons with an expense  */
gen any_expense=(total>0)

/* create a summary variable from end of year, 42, and 31 variables*/
gen age=age17x if age17x>=0
replace age=age42x if age42x>=0 & missing(age)
replace age=age31x if age31x>=0 & missing(age)

gen agecat=1 if age>=0 & age<=64
replace agecat=2 if age>64
label define agecat 1 "<65" 2 "65+"
label values agecat agecat

/* qc check on new variables*/
tab1  any_expense
summarize total if total>0

list age age17x age42x age31x in 1/20, table

tab agecat
summarize age if age>64

/* identify the survey design characteristics */
svyset varpsu [pweight= perwt17f], strata(varstr) vce(linearized) singleunit(missing)

// overall expenses
svy: mean total
svy: total total
           
// percentage of persons with an expense
svy: mean any_expense		   
		   
// mean expense per person with an expense
svy, subpop(if any_expense==1): mean total

// mean expense per person with an expense, by age category
svy, subpop(if any_expense==1): mean total, over(agecat)

exit, clear

