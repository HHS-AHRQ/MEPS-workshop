* Exercise 3:
* This program is an example of how to link the MEPS-HC Medical Conditions file, 
* the Office Visits Event file, and the Full-Year Consolidated file for 
* data year 2021 in order to estimate the following:
*
*   - Total number of people with office-based medical visit for cancer (malignant neoplasms)
*   - Total number of office visits for cancer
*   - Total expenditures on office visits for cancer 
*   - Percent of people with office visit for cancer
*   - Average expenditure on office visits for cancer
* 
* Input files:
*   - h229g.dta        (2021 Office visits file)
*   - h231.dta         (2021 Conditions file)
*   - h229if1.dta      (2021 CLNK: Condition-Event Link file)
*   - h233.dta         (2021 Full-Year Consolidated file)
* 
* Resources:
*   - CCSR codes: 
*   https://github.com/HHS-AHRQ/MEPS/blob/master/Quick_Reference_Guides/meps_ccsr_conditions.csv
* 
*   - MEPS-HC Public Use Files: 
*   https://meps.ahrq.gov/mepsweb/data_stats/download_data_files.jsp
* 
*   - MEPS-HC online data tools: 
*   https://datatools.ahrq.gov/meps-hc
*
* -----------------------------------------------------------------------------

clear
set more off
capture log close
cd C:\MEPS
log using Ex3, replace 

****************************
/* condition linkage file */
****************************
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h229i/h229if1dta.zip" "h229if1dta.zip", replace
unzipfile "h229if1dta.zip", replace 
use h229if1, clear
rename *, lower
save CLNK_2021, replace


*************************************
/* Office visits file, visit level */
*************************************
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h229g/h229gdta.zip" "h229gdta.zip", replace
unzipfile "h229gdta.zip", replace
use DUPERSID EVNTIDX OBXP21X using h229g, clear
rename *, lower
save OB_2021, replace

****************************************
/* FY condolidated file, person-level */
****************************************
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h233/h233dta.zip" "h233dta.zip", replace
unzipfile "h233dta.zip", replace 
use DUPERSID SEX RACETHX CHOLDX INSURC21 POVCAT21 VARSTR VARPSU PERWT21F using h233, clear
rename *, lower
save FY_2021, replace


***************************************************************************
/* Conditions file, person-condition-level, subset to malignant neoplasms */
***************************************************************************
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h231/h231dta.zip" "h231dta.zip", replace
unzipfile "h231dta.zip", replace
use DUPERSID CONDIDX ICD10CDX CCSR1X CCSR2X CCSR3X using h231, clear
rename *, lower
// keep only records for malignant neoplasms
gen malneo1=((substr(ccsr1x,1,3)=="NEO" & ccsr1x~="NEO073") | (ccsr1x=="FAC006"))
gen malneo2=((substr(ccsr2x,1,3)=="NEO" & ccsr2x~="NEO073") | (ccsr2x=="FAC006"))
gen malneo3=((substr(ccsr3x,1,3)=="NEO" & ccsr3x~="NEO073") | (ccsr3x=="FAC006"))
keep if malneo1==1 | malneo2==1 | malneo3==1
save COND_2021, replace


********************************************************************************
/* merge to CLNK file by dupersid and condidx, drop unmatched, drop duplicates */
********************************************************************************

// drop observations that do not match

// inspect file

// drop duplicate office visits--- single visits that would otherwise be counted multiple times */

// inspect file after de-duplication

*******************************************************************************************
/* merge to office visits by dupersid and evntidx, drop unmatched, drop duplicates */
*******************************************************************************************

// drop observations for that do not match

// inspect file

***************************************************************************************
/* collapse to person-level (DUPERSID), sum to get number of visits and expenditures */
***************************************************************************************

/* merge to FY file, create flag for any Rx fill for HL */


*********************************************************************************************
/* merge to FY file to get any individual characteristics of interest (e.g. age, sex, race) */
*********************************************************************************************



*******************************************
/* Analysis                              */
*******************************************
/* Set survey options */
svyset varpsu [pw = perwt21f], strata(varstr) vce(linearized) singleunit(centered)

/* total people with office visit for malignant neoplasm */

/* total number of office visits for malignant neoplasm */

/* total expenditures for office visits for malignant neoplasm */

/* percent with office visit for malignant neoplasm */

/* average number of office visits for malignant neoplasm per person */
 
/* average expenditure on office visits for malignant neoplasm per person */
