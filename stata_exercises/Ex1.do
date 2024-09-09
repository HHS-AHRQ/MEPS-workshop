************************************************************************************************************************************
* Exercise 1: 
* This program generates the following estimates on national health care for the U.S. civilian non-institutionalized population, 2021:
*  - Overall expenses (National totals)
*  - Percentage of persons with an expense
*  - Mean expense per person
*  - Mean/median expense per person with an expense:
*    - Mean expense per person with an expense
*    - Mean expense per person with an expense, by age group
*    - Median expense per person with an expense, by age group
*
* Input file:
*  - C:/MEPS/h233.dta (2021 Full-year file)
*
* This program is available at:
* https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/stata_exercises
************************************************************************************************************************************


clear
set more off
capture log close
cd C:\MEPS
log using Ex1.log, replace 

/* Get data from web (you can also download manually) */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h233/h233dta.zip" "h233dta.zip", replace
unzipfile "h233dta.zip", replace 

/* Read in 2021 Full-year consolidated file */ 
use h233, clear
rename *, lower

/* define expenditure variables (transformations, etc.)  */
gen total_exp=totexp21
gen any_expenditure=(total_exp>0)

/* create age categorical variable */
gen agecat=.
replace agecat=1 if agelast>=0 & agelast<65
replace agecat=2 if agelast>=65
// here's an alternative way to create a categorical variable 
*egen agecat2=cut(agelast), at(0 65 100)

// create and assign value labels to age 
label define agecat 1 "<65" 2 "65+"
label values agecat agecat

/* QC check new variables*/
list total_exp any_expenditure agecat agelast in 1/20, table

tab1 any_expenditure agecat, m

tab any_expenditure agecat, m
 
summarize total_exp, d
summarize total_exp if any_expenditure==1, d

/* identify the survey design characteristics */
svyset varpsu [pw = perwt21f], strata(varstr) vce(linearized) singleunit(centered)

/* total expenses */
svy: total total_exp
// list output stored in r()
return list 
matrix list r(table)
// display results without scientific notation 
di %15.0f r(table)[1,1]
di %15.0f r(table)[2,1]

/* percent of people with any expense */
svy: mean any_expenditure

/* mean expense per person */
svy: mean total_exp

/* mean expense per person with an expense */
svy, subpop(if any_expenditure==1): mean total_exp

/* mean expense per person with an expense, by age */
svy, subpop(if any_expenditure==1): mean total_exp, over(agecat)

/* median expense per person with an expense, by age */
epctile total_exp, subpop(if total_exp>0) p(50) svy
epctile total_exp, subpop(if total_exp>0) p(50) svy over(agecat)

// alternative way 2 
table agecat [pw=perwt] if total_exp>0, stat(median total_exp)






