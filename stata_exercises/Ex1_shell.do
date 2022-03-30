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


/* create flag (1/0) variables for persons with an expense  */


/* create age categorical variable */


/* qc check on new variables*/


/* specify the survey design parameters */


// Total overall health are expenditures 


// Percentage of persons with an expense


// Mean overall expenditures per person


// mean expenditures per person with an expense


// Mean and median expenditures per person with an expense, by age group

          
log close


