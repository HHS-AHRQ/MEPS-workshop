*********************************************************************
*
*PROGRAM: 	C:\work\MEPS_workshop\programs\Ex2.do
*
*PURPOSE:		THIS PROGRAM GENERATES SELECTED ESTIMATES FOR A 2018 VERSION OF Purchases and Expenses for Narcotic analgesics or Narcotic analgesic combos
*				IT LINKS 2018 FULL YEAR AND PRESCRIBED MEDICINES FILES
*          	
*    				(1) TOTAL EXPENSE FOR Narcotic analgesics or Narcotic analgesic combos
*
*    				(2) TOTAL NUMBER OF PURCHASES OF Narcotic analgesics or Narcotic analgesic combos
*
*    				(3) TOTAL NUMBER OF PERSONS PURCHASING ONE OR MORE Narcotic analgesics or Narcotic analgesic combos
*
*    				(4) AVERAGE TOTAL, OUT OF POCKET, AND THIRD PARTY PAYER EXPENSE
*                  				FOR Narcotic analgesics or Narcotic analgesic combos PER PERSON WITH A Narcotic analgesics or Narcotic analgesic combos 
*
*INPUT FILES:  (1) C:\MEPS\STATA\DATA\H209.dta  (2018 FULL-YEAR CONSOLIDATED PUF)
*              (2) C:\MEPS\STATA\DATA\H206A.dta (2018 PRESCRIBED MEDICINES PUF)
*
*********************************************************************

clear
set more off
capture log close
log using C:\MEPS\statapgms\Ex2.log, replace
cd C:\MEPS\DATA

// 1) identify Narcotic analgesics or Narcotic analgesic combos using therapeutic classification (tc) codes
*import sasxport5 h197a.ssp
*keep dupersid rxrecidx linkidx tc1s1_1 rxxp17x rxsf17x
*use dupersid rxrecidx linkidx tc1s1_1 rxxp17x rxsf17x using h197a, clear

use h206a, clear
rename *, lower
keep if (tc1s1_1==60 | tc1s1_1==191)

list dupersid rxrecidx linkidx rxxp18x rxsf18x in 1/30, table
tab1 tc1s1_1

// 2) sum data to person-level

gen one=1
collapse (sum) n_purchase=one tot=rxxp18x oop=rxsf18x, by(dupersid)
gen third_payer   = tot - oop
list dupersid n_purchase tot oop third_payer in 1/20


// 3) merge the person-level expenditures to the fy puf 
tempfile perdrug
save "`perdrug'"

use h209, clear
rename *, lower
sort dupersid

merge 1:m dupersid using "`perdrug'", keep(master matches) gen(merge1)
gen sub=(merge1==3)
tab sub

recode n_purchase tot oop third_payer (missing=0)
sum n_purchase tot oop third_payer if sub==0

 keep if perwt18f>0
// 4) calculate estimates on expenditures and use
svyset [pweight= perwt18f], strata( varstr) psu(varpsu) vce(linearized) singleunit(missing)

svy, subpop(sub): mean n_purchase tot oop third_payer, cformat(%8.3g)
svy, subpop(sub): total n_purchase tot oop third_payer
estimates table, b(%13.0f) se(%11.0f)

svy, subpop(sub): mean tot oop third_payer, over(racethx)



