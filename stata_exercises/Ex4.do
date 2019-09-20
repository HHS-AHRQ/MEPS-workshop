**********************************************************************************
*
*PROGRAM:      C:\MEPS\Ex4.do
*
*DESCRIPTION:  DESCRIPTION:  THIS PROGRAM ILLUSTRATES HOW TO POOL MEPS LONGITUDINAL DATA FILES FROM DIFFERENT PANELS
*              THE EXAMPLE USED IS PANELS 18-20 POPULATION AGE 26-30 WHO ARE UNINSURED BUT HAVE HIGH INCOME IN THE FIRST YEAR
*
*	         		 DATA FROM PANELS 18, 19, AND 20 ARE POOLED.
*
*INPUT FILE:   (1) C:\MEPS\SAS\DATA\H193.DAT (PANEL 20 LONGITUDINAL FILE)
*	            (2) C:\MEPS\SAS\DATA\H183.DAT (PANEL 19 LONGITUDINAL FILE)
*	            (3) C:\MEPS\SAS\DATA\H172.DAT (PANEL 18 LONGITUDINAL FILE)
*********************************************************************************

clear
set more off
capture log close
cd c:\meps

log using Ex4.log, replace

// pool three panels of data to get sufficient sample size
/* Stata-IC can't load longitudinal files from SAS xport (too many variables) */
/* Either SAS xport files need to be converted to Stata and read using the Stata "use" command */
/* Or the variables need to be read in from an ascii file using the Stata "infix" command  */

/* panel 20 */
infix ///
  str    dupersid 9-16 ///
  byte   panel 17-18 ///
  byte   inscovy1 4368-4369 ///
  byte   inscovy2 4370-4371 ///
  double longwt 10293-10305 ///
  byte   varpsu 10288-10288 ///
  int    varstr 10289-10292 ///
  byte   povcaty1 2843-2844 ///
  byte   povcaty2 2845-2846 ///
  byte   agey1x 334-335 ///
  byte   agey2x 336-337 ///
using H193.dat, clear
tempfile panel20
save "`panel20'"

/* panel 19 */
infix ///
  str    dupersid 9-16 ///
  byte   panel 17-18 ///
  byte   inscovy1 4167-4168 ///
  byte   inscovy2 4169-4170 ///
  double longwt 10114-10126 ///
  byte   varpsu 10109-10109 ///
  int    varstr 10110-10113 ///
  byte   povcaty1 2645-2646 ///
  byte   povcaty2 2647-2648 ///
  byte   agey1x 334-335 ///
  byte   agey2x 336-337 ///
using H183.dat, clear
tempfile panel19
save "`panel19'"

/* panel 18 */
infix ///
  str    dupersid 9-16 ///
  byte   panel 17-18 ///
  byte   inscovy1 4077-4078 ///
  byte   inscovy2 4079-4080 ///
  double longwt 9971-9983 ///
  byte   varpsu 9966-9966 ///
  int    varstr 9967-9970 ///
  byte   povcaty1 2602-2603 ///
  byte   povcaty2 2604-2605 ///
  byte   agey1x 334-335 ///
  byte   agey2x 336-337 ///
using H172.dat, clear

append using "`panel19'" "`panel20'"


gen poolwt=longwt/3
gen subpop=(agey1x>=26 & agey1x<=30 & inscovy1==3 & povcaty1==5)
label define insf -1 "NA" 1 "1 Any private" 2 "2 Public only" 3 "3 Uninsured"
label define povcat 1 "1 Poor/negative" 2 "2 Near poor" 3 "3 Low income" 4 "4 Midlle income" 5 "5 High income"
label value inscovy1 inscovy2 insf
label value povcaty1 povcat

tab1 agey1x inscovy1 inscovy2 povcaty1 panel if subpop==1
tab subpop
summarize  if subpop==1

svyset [pweight=poolwt], strata( varstr) psu(varpsu) vce(linearized) singleunit(missing)

// weighted estimate on totslf for combined data w/age=26-30, uninsured whole year, and high income
// in the first year
svy, subpop(subpop): tabulate inscovy2, cell se obs


