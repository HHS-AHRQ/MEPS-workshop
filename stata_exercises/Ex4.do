**********************************************************************************
*
*program:      c:\work\meps_workshop\programs\ex4.do
*
*description:  description:  this program illustrates how to pool meps longitudinal data files from different panels
*              the example used is panels 19-21 population age 27-64 who are uninsured but have high income in the first year
*
*	         	data from panels 19, 20, and 21 are pooled.
*
*input file:   (1) c:\meps\sas\data\h183.ssp (panel 19 longitudinal file)
*	            (2) c:\meps\sas\data\h193.ssp (panel 20 longitudinal file)
*	            (3) c:\meps\sas\data\h202.ssp (panel 21 longitudinal file)
*********************************************************************************

clear
set more off
capture log close
log using c:\MEPS\statapgms\ex4.log, replace
cd c:\MEPS\DATA

// pool three panels of data to get sufficient sample size

use h202, clear
append using h193 h183
 
tab panel 

gen poolwt=longwt/3
gen subpop=(agey1x>26 & agey1x<65 & inscovy1==3 & povcaty1==5)
label define insf -1 "na" 1 "1 any private" 2 "2 public only" 3 "3 uninsured"
label define povcat 1 "1 poor/negative" 2 "2 near poor" 3 "3 low income" 4 "4 midlle income" 5 "5 high income"
label value inscovy1 inscovy2 insf
label value povcaty1 povcat

tab1 agey1x inscovy1 inscovy2 povcaty1 panel if subpop==1
tab subpop
summarize  if subpop==1

svyset [pweight=poolwt], strata( varstr) psu(varpsu) vce(linearized) singleunit(missing)

// weighted estimate on totslf for combined data w/age=26-30, uninsured whole year, and high income
// in the first year
svy, subpop(subpop): tabulate inscovy2, cell se obs


