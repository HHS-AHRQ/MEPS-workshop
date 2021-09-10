clear
set more off
capture log close
cd C:\MEPS
log using example_brr.log, replace 

/* Get brr weights */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h036brr/h36brr19dta.zip" "h36brr.zip"
unzipfile "h36brr.zip", replace 
use h36brr19, clear
rename *, lower

/* Merge FY 2018 FUP and brr weights */
merge 1:1 dupersid panel using h209.dta, keepusing(dupersid panel perwt18f varstr varpsu totexp18)
drop if _merge ~= 3
drop _merge

***************************************************************
/* unadjusted standard errors                                 */
***************************************************************
mean totexp18

***********************************************************************
/* standard errors adjusted using Stata's Taylor series linearization */
***********************************************************************
svyset varpsu [pw=perwt18f], str(varstr) vce(linearized)
svy: mean totexp18

***********************************************************************
/* standard errors adjusted using Stata's BRR                         */
***********************************************************************
foreach var of varlist brr1-brr128 {
	replace `var'=`var'*2*perwt18f
}
svyset varpsu [pw=perwt18f], str(varstr) brrweight(brr1-brr128) vce(brr)
svy: mean totexp18

