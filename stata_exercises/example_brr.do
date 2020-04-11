********************************************************************************
*
* PROGRAM:     C:\work\MEPS_workshop\example_brr.do
*
* DESCRIPTION: This program compares standard error estimates calculated by:
*
*	(1) Balanced Repeated Replicates (BRR) - using explicit loop
*	(2) Balanced Repeated Replicates (BRR) - using Stata's internal commands
*	(3) Taylor Series Linearization (Stata default)
*
* INPUT FILE:  C:\work\MEPS_workshop\H201.dta (2017 FULL-YEAR FILE)
*
********************************************************************************

set more 1
capture log close

global home "C:\work\MEPS_workshop"
cd $home\programs
log using example_brr.log, replace

cd $home\data

/* Merge FY 2017 PUF and brr weights */
use dupersid panel perwt17f varstr varpsu totexp17 using h201.dta, clear
merge 1:1 dupersid panel using h36_2017.dta
drop if _merge ~= 3
drop _merge

*******************************************************
/* brr sample variance estimation with explicit loop */
*******************************************************
gen brrweight=.
/* create and populate a column vector of brr replicate weights (128) */
matrix mean_reps=J(128,1,.)
forvalues rep = 1/128 {
   display `rep'
   replace brrweight=brr`rep'*perwt17f*2
   mean totexp17 [pweight=brrweight]
   matrix rtable=r(table)
   matrix mean_reps[`rep',1]=rtable[1,1]
}
/* calculate weighted sample mean and store in column vector */
mean totexp17 [pw=perwt17f]
matrix rtable=r(table)
local sample_mean=rtable[1,1]
matrix sample_mean=J(128,1,`sample_mean')
/* create vector of sample mean subtracted from replicate means */ 
matrix rep_m_sample=mean_reps-sample_mean
/* Square each element and sum */
matrix V=rep_m_sample'*rep_m_sample
/* divide by 128 to get sampling variance, take sqrt to get SE */
local SE=sqrt(V[1,1]/128)
di `SE'

*********************************************************
/* brr sample variance using Stata's internal commands */
*********************************************************
foreach var of varlist brr1-brr128 {
	replace `var'=`var'*2*perwt17f
}
svyset varpsu [pw=perwt17f], str(varstr) brrweight(brr1-brr128) vce(brr)
svy: mean totexp17

***************************************************************
/* sample variance using default Taylor series linearization */
***************************************************************
svyset varpsu [pw=perwt17f], str(varstr) vce(linearized)
svy: mean totexp17
   
