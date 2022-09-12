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
*   - C:/MEPS/h224.dta  (2020 Full-year file)
*   - C:/MEPS/h220a.dta (2020 Prescribed medicines file)
* 
*  This program is available at:
*  https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/stata_exercises
******************************************************************************************************************

clear
set more off
capture log close
cd C:\MEPS
log using Ex2.log, replace

/* Get data */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h220a/h220adta.zip" "h220adta.zip", replace
unzipfile "h220adta.zip", replace

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h224/h224dta.zip" "h224dta.zip", replace
unzipfile "h224dta.zip", replace 

use C:\MEPS\h220astata, clear
rename *, lower
// 1) identify Narcotic analgesics or Narcotic analgesic combos using therapeutic classification (tc) codes, keep only narcotic Rx
keep if (tc1s1_1==60 | tc1s1_1==191)
list dupersid rxrecidx linkidx rxxp20x rxsf20x in 1/30, table
tab1 tc1s1_1

// 2) sum data to person-level
collapse (count) n_purchase=tc1s1_1 (sum) total_exp=rxxp20x (sum) oop_exp=rxsf20x, by(dupersid)
gen third_payer_exp = total_exp - oop_exp
list dupersid n_purchase total_exp oop_exp third_payer_exp in 1/20
save person_Rx, replace

// 3) merge the person-level expenditures to the FY PUF, identify subpopulation 
use C:\MEPS\h224, clear
rename *, lower
merge 1:1 dupersid using person_Rx, gen(merge1)
recode n_purchase total_exp oop_exp third_payer_exp (.=0) if merge1==1

save merge_h224_h230a, replace

// 4) calculate estimates on expenditures and use
svyset [pweight= perwt20f], strata( varstr) psu(varpsu) vce(linearized) singleunit(missing)

svy: total n_purchase total_exp oop_exp third_payer_exp, cformat(%13.3g)
estimates table, b(%13.0f) se(%11.0f)

svy: mean n_purchase total_exp oop_exp third_payer_exp
svy, subpop(if n_purchase>0): mean n_purchase total_exp oop_exp third_payer_exp




