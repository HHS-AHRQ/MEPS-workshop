******************************************************************************************************************
*  Exercise 2: 
*  This program generates National Totals and Per-person Averages for Narcotic
*  analgesics and Narcotic analgesic combos for the U.S. civilian non-institutionalized population, including:
*   - Number of purchases (fills)  
*   - Total expenditures          
*   - Out-of-pocket payments       
*   - Third-party payments        
* 
*  Input files:
*   - C:/MEPS/h216.dta  (2019 Full-year file)
*   - C:/MEPS/h213a.dta (2019 Prescribed medicines file)
* 
*  This program is available at:
*  https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/stata_exercises
******************************************************************************************************************
clear
set more off
capture log close
cd C:\MEPS
log using Ex2.log, replace

// Read in Drug File 
use C:\MEPS\h213a, clear

// 1) identify Narcotic analgesics or Narcotic analgesic combos using therapeutic classification (tc) codes, keep only narcotic Rx
keep if (tc1s1_1==60 | tc1s1_1==191)
list dupersid rxrecidx linkidx rxxp19x rxsf19x in 1/30, table
tab1 tc1s1_1

// 2) sum data to person-level
gen one=1
collapse (sum) n_purchase=one tot=rxxp19x oop=rxsf19x, by(dupersid)
gen third_payer   = tot - oop
list dupersid n_purchase tot oop third_payer in 1/20
save person_Rx, replace

// 3) merge the person-level expenditures to the FY PUF, identify subpopulation 
use C:\MEPS\h216, clear
rename *, lower
merge 1:1 dupersid using person_Rx, gen(merge1)

recode n_purchase tot oop third_payer (missing=0)

save merge_h216_h213a, replace

// 4) calculate estimates on expenditures and use
svyset [pweight= perwt19f], strata( varstr) psu(varpsu) vce(linearized) singleunit(centered)

svy, sub(if merge1==3): mean n_purchase tot oop third_payer
svy, sub(if merge1==3): total n_purchase tot oop third_payer
estimates table, b(%15.0f) se(%11.0f)
svy, sub(if merge1==3): mean tot oop third_payer, over(racethx)

log close




