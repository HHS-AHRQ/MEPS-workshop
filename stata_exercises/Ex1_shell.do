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



/* define expenditure variables (transformations, etc.)  */



/* create age categorical variable */

// here's an alternative way to create a categorical variable 
*egen agecat2=cut(agelast), at(0 65 100)

// create and assign value labels to age 



/* QC check new variables*/




/* identify the survey design characteristics */




/* total expenses */

// list output stored in r()

// display results without scientific notation 



/* percent of people with any expense */



/* mean expense per person */



/* mean expense per person with an expense */



/* mean expense per person with an expense, by age */



/* median expense per person with an expense, by age */

// alternative way  
*table agecat [pw=perwt] if total_exp>0, stat(median total_exp)






