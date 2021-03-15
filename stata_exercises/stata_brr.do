******************************************************************************
* Description:  This program estimates the logistic regression model in 
* Exercise 4 using BRR instead of Linearization for the standard errors
*
* Input data: H209 & H36BRR
******************************************************************************
clear
set more off
capture log close
log using stata_brr.log, replace
cd c:\MEPS

use c:\MEPS\DATA\h36brr, clear

/* Merge H209 to FUP and brr weights */
merge 1:1 dupersid panel using c:\MEPS\DATA\h209 
drop if _merge==1
drop _merge

// create variable identifying individuals who received flu shot in last year
gen flushot=(adflst42==1)
replace flushot=. if adflst42<0
tab adflst42 flushot, m

// create variable to identify subpopulation
gen sub1=~missing(flushot, povcat18, inscov18, sex, racethx)

// Set up BRR weights for analysis
foreach var of varlist brr1-brr128 {
	replace `var'=`var'*perwt18f
}

// regression analysis using BRR  
svyset varpsu [pw = saqwt18f], strata(varstr) brrweight(brr1-brr128) vce(brr) singleunit(missing)
svy, sub(sub1): logit flushot i.povcat18 i.inscov18 i.sex i.racethx

// regression analysis using Taylor Series Linearization  
svyset varpsu [pw = saqwt18f], strata(varstr) vce(linearized) singleunit(missing)
svy, sub(sub1): logit flushot b5.povcat18 i.inscov18 i.sex i.racethx


