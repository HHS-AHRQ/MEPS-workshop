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

/* define expenditure variables (transformations, etc.)  */
gen total_exp=totexp20
gen any_expenditure=(total_exp>0)

/* create age categorical variable */
gen agecat=.
replace agecat=1 if agelast>=0 & agelast<65
replace agecat=2 if agelast>=65
// here's an alternative way to create a categorical variable 
*egen agecat=cut(agelast), at(0 65 100)
// create and assign value labels to the categorical age variable just created 
label define agecat 1 "<65" 2 "65+"
label values agecat agecat

/* QC check new variables*/
list total_exp any_expenditure agecat age20x in 1/20, table

tab1 any_expenditure agecat, m

tab any_expenditure agecat, m
 
summarize total_exp, d
summarize total_exp if any_expenditure==1, d

/* specify survey design characteristics */
svyset varpsu [pw = perwt20f], strata(varstr) vce(linearized) singleunit(missing)

/* total expenses */
svy: total total_exp

// list output stored in r()
return list 
matrix list r(table)

// display results without scientific notation 
di %15.0f r(table)[1,1]
di %15.0f r(table)[2,1]

// output results to Excel file
putexcel set Results.xlsx, modify sheet(Ex1) 
putexcel B2=matrix(r(table)[1,1]) C2=matrix(r(table)[2,1])

/* percent of people with any expense */
svy: mean any_expenditure
matrix list r(table)		   
putexcel B3=matrix(r(table)[1,1]) C3=matrix(r(table)[2,1])

/* mean expense per person */
svy: mean total_exp
matrix list r(table)		   
putexcel B4=matrix(r(table)[1,1]) C4=matrix(r(table)[2,1])

/* mean expense per person with an expense */
svy, subpop(if any_expenditure==1): mean total_exp
matrix list r(table)		   
putexcel B5=matrix(r(table)[1,1]) C5=matrix(r(table)[2,1])

/* mean expense per person with an expense, by age */
svy, subpop(if any_expenditure==1): mean total_exp, over(agecat)
matrix list r(table)		   
putexcel B7=matrix(r(table)[1,1]) C7=matrix(r(table)[2,1])
putexcel B8=matrix(r(table)[1,2]) C8=matrix(r(table)[2,2])

/* median expense per person with an expense, by age */
_pctile total_exp [pw=perwt20f] if total_exp>0 & agecat==1
return list
putexcel B10=`r(r1)' 
_pctile total_exp [pw=perwt20f] if total_exp>0 & agecat==2
return list
putexcel B11=`r(r1)' 

// alternative way to calculate median 
table agecat [pw=perwt] if total_exp>0, stat(median total_exp)




