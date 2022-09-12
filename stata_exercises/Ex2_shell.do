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







// 2) sum data to person-level







// 3) merge the person-level expenditures to the FY PUF, identify subpopulation 







// 4) calculate estimates on expenditures and use


