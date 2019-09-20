*********************************************************************
*
*PROGRAM: 	C:\MEPS\EXERCISE2.do
*
*PURPOSE:		THIS PROGRAM GENERATES SELECTED ESTIMATES FOR A 2017 VERSION OF Purchases and Expenses for Narcotic analgesics or Narcotic analgesic combos
*          	
*    				(1) FIGURE 1: TOTAL EXPENSE FOR Narcotic analgesics or Narcotic analgesic combos
*
*    				(2) FIGURE 2: TOTAL NUMBER OF PURCHASES OF Narcotic analgesics or Narcotic analgesic combos
*
*    				(3) FIGURE 3: TOTAL NUMBER OF PERSONS PURCHASING ONE OR MORE Narcotic analgesics or Narcotic analgesic combos
*
*    				(4) FIGURE 4: AVERAGE TOTAL, OUT OF POCKET, AND THIRD PARTY PAYER EXPENSE
*                  				FOR Narcotic analgesics or Narcotic analgesic combos PER PERSON WITH A Narcotic analgesics or Narcotic analgesic combos MEDICINE PURCHASE
*
*INPUT FILES:  (1) C:\meps\h201.dta  (2017 FULL-YEAR CONSOLIDATED PUF)
*              (2) C:\meps\STATA\DATA\H197A.dta (2017 PRESCRIBED MEDICINES PUF)
*
*********************************************************************

clear
set more off
capture log close
cd c:\meps\

log using Ex2.log, replace

/* 1) identify Narcotic analgesics or Narcotic analgesic combos using therapeutic classification (tc) codes */
import sasxport "C:\MEPS\h197a.ssp"
keep dupersid rxrecidx linkidx tc1s1_1 rxxp17x rxsf17x 
keep if (tc1s1_1==60 | tc1s1_1==191)

list dupersid rxrecidx linkidx rxxp17x rxsf17x in 1/30, table
tab1 tc1s1_1

// 2) sum data to person-level

collapse (sum) tot=rxxp17x oop=rxsf17x (count) n_purchase=rxxp17x, by(dupersid)
gen third_payer=tot-oop

/* alternative to the two lines of code above */
/*
sort dupersid
by dupersid: egen tot=sum(rxxp17x)
by dupersid: egen oop=sum(rxsf17x)
by dupersid: gen n_purchase=_n

list dupersid n_purchase tot oop rxxp17x rxsf17x in 1/20

by dupersid: keep if _n==_N
gen third_payer   = tot - oop
*/
tempfile perdrug
save "`perdrug'"

// 3) merge the person-level expenditures to the fy puf 
import sasxport "C:\MEPS\h201.ssp"
keep dupersid varstr varpsu perwt17f
sort dupersid

merge 1:m dupersid using "`perdrug'", keep(master matches)

gen sub=(_merge==3)
tab sub

recode n_purchase tot oop third_payer (missing=0)
summarize n_purchase tot oop third_payer if sub==0

keep if perwt17f>0
// 4) calculate estimates on expenditures and use
svyset varpsu [pweight= perwt17f], strata(varstr) vce(linearized) singleunit(missing)

svy, subpop(sub): mean n_purchase tot oop third_payer, cformat(%8.3g)
svy, subpop(sub): total n_purchase tot oop third_payer
estimates table, b(%13.0f) se(%11.0f)

*log close  
*exit, clear

