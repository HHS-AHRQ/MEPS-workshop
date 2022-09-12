*****************************************************************************************************************************************
* Exercise 1: 
* This program generates the following estimates on national health care for the U.S. civilian non-institutionalized population, 2020:
*  - Overall expenses (National totals)
*  - Percentage of persons with an expense
*  - Mean expense per person
*  - Mean/median expense per person with an expense:
*    - Mean expense per person with an expense
*    - Mean expense per person with an expense, by age group
*    - Median expense per person with an expense, by age group
*
* Input file:
*  - C:/MEPS/h224.dta (2020 Full-year file)
*
* This program is available at:
* https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/stata_exercises
*****************************************************************************************************************************************


clear
set more off
capture log close
cd C:\MEPS
log using Ex1.log, replace 

/* Get data from web (you can also download manually) */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h224/h224dta.zip" "h224dta.zip", replace
unzipfile "h224dta.zip", replace 

/* Read in 2020 Full-year consolidated file */ 
use h224, clear
rename *, lower

/* define expenditure variables  */
gen total_exp=totexp20

/* create flag (1/0) variables for persons with an expense  */
gen any_expenditure=(total_exp>0)

/* create age categorical variable */
gen agecat=.
replace agecat=1 if agelast>=0 & agelast<65
replace agecat=2 if agelast>=65
/* here's an alternative way to create a categorical variable */
egen agecat2=cut(agelast), at(0 65 100)

label define agecat 1 "<65" 2 "65+"
label values agecat agecat
label values agecat2 agecat

/* qc check on new variables*/
list total_exp any_expenditure agecat age20x in 1/20, table

tab1 any_expenditure agecat, m
 
summarize total_exp, d
summarize total_exp if any_expenditure==1, d

/* identify the survey design characteristics */
svyset varpsu [pw = perwt20f], strata(varstr) vce(linearized) singleunit(missing)
// overall expenses
svy: mean total_exp
svy: total total_exp

di %15.0f r(table)[1,1]
di %15.0f r(table)[2,1]

          
// percentage of persons with an expense
svy: mean any_expenditure		   
		   
// mean expense per person with an expense
svy, subpop(if any_expenditure==1): mean total_exp

// mean expenditures, median expenditures, percent with any expenditures, mean expenditures conditional on having any, all by age category
svy: mean total_exp, over(agecat)
svy: mean any_expenditure, over(agecat)
svy, sub(if any_expenditure==1): mean total_exp, over(agecat)

table agecat [pw=perwt] if total_exp>0, stat(median total_exp)


