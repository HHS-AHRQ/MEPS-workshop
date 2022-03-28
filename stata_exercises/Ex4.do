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
gen flushot=(adflst42==1)
replace flushot=. if adflst42<0
tab adflst42 flushot, m

// create variable to identify subpopulation
gen sub1=~missing(flushot, povcat18, inscov18, sex, racethx)

// merge on brr weights 
merge 1:m dupersid using h36brr19
drop if _merge ~= 3

// set survey parameters for linearized standard errors 
svyset varpsu [pw = saqwt18f], strata(varstr) vce(linearized) singleunit(missing)
// regression analysis
svy, sub(sub1): reg flushot i.sex i.racethx i.inscov18
svy, sub(sub1): logit flushot i.sex i.racethx i.inscov18 

// set survey parameters for BRR standard errors 
svyset varpsu [pw=saqwt18f], str(varstr) brrweight(brr1-brr128) vce(brr)
// regression analysis
svy, sub(sub1): reg flushot agelast i.sex i.racethx i.inscov18
svy, sub(sub1): logit flushot agelast i.sex i.racethx i.inscov18 

log close

