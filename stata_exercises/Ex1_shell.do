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

/* define expenditure variables (transformations, etc.)  */

/* create age categorical variable */

// create and assign value labels to age 

/* QC check new variables*/

/* identify the survey design characteristics */

/* total expenses */

// list output stored in r()
return list 
matrix list r(table)
// display results without scientific notation 
di %15.0f r(table)[1,1]
di %15.0f r(table)[2,1]

/* percent of people with any expense */

/* mean expense per person */

/* mean expense per person with an expense */

/* mean expense per person with an expense, by age */

/* median expense per person with an expense, by age */

// alternative way 2 

/* alternative way 2 
_pctile total_exp [pw=perwt20f] if total_exp>0 & agecat==1
return list
putexcel B10=`r(r1)' 
_pctile total_exp [pw=perwt20f] if total_exp>0 & agecat==2
return list
putexcel B11=`r(r1)' 







