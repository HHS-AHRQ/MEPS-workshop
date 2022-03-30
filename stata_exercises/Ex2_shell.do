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


// 2) sum data to person-level


// 3) merge the person-level expenditures to the FY PUF, identify subpopulation 


// 4) calculate estimates on expenditures and use


log close




