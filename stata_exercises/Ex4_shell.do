*****************************************************************************************************
* Exercise 4
*  This program includes a regression example for persons receiving a flu shot in 2018
*  for the U.S. civilian non-institutionalized population with standard errors calculated using BRR
* 
*  Input files: 
*   - C:/MEPS/h209.dta (2018 Full-year file)
*   - 
* 
*  This program is available at:
*  https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/stata_exercises
*****************************************************************************************************
clear
set more off
capture log close
cd c:\MEPS

log using Ex4.log, replace

use h209, clear

// create variable identifying individuals who received flu shot in last year

// create variable to identify subpopulation

// merge on brr weights 

// set survey parameters for linearized standard errors 

// regression analysis

// set survey parameters for BRR standard errors 

// regression analysis

log close

