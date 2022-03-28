*****************************************************************************************************************************************
* Exercise 1: 
* This program generates the following estimates on national health care for the U.S. civilian non-institutionalized population, 2019:
*  - Overall expenses (National totals)
*  - Percentage of persons with an expense
*  - Mean expense per person
*  - Mean/median expense per person with an expense:
*    - Mean expense per person with an expense
*    - Mean expense per person with an expense, by age group
*    - Median expense per person with an expense, by age group
*
* Input file:
*  - C:/MEPS/h216.dta (2019 Full-year file)
*
* This program is available at:
* https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/stata_exercises
*****************************************************************************************************************************************
clear
set more off
capture log close
cd C:\MEPS
log using Ex1.log, replace 

use h216, clear

/* define expenditure variables  */
gen totalx=totexp19

/* create flag (1/0) variables for persons with an expense  */
gen any_expenditure=(totalx>0)

/* create age categorical variable */
gen agecat=1 if agelast>=0 & agelast<=64
replace agecat=2 if agelast>64
label define agecat 1 "<65" 2 "65+"
label values agecat agecat

/* qc check on new variables*/
list totalx any_expenditure agecat agelast in 1/20, table

tab1 any_expenditure agecat, m
 
summarize total, d
summarize total if any_expenditure==1, d

/* specify the survey design parameters */
svyset varpsu [pw = perwt19f], strata(varstr) vce(linearized) singleunit(missing)

// Total overall health are expenditures 
svy: total totalx
di %15.0f r(table)[1,1]
estimates table, b(%15.0f) se(%11.0f)

// Percentage of persons with an expense
svy: mean any_expenditure		   

// Mean overall expenditures per person
svy: mean totalx

// mean expenditures per person with an expense
svy, subpop(if any_expenditure==1): mean totalx

// Mean and median expenditures per person with an expense, by age group
svy, subpop(if any_expenditure==1): mean totalx, over(agecat)

summ totalx [aw=perwt19f] if any_expenditure==1, d
table agecat [pw=perwt19f] if any_expenditure==1, stat(mean totalx) stat(median totalx)
          
log close


