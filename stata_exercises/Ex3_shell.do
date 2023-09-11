* Exercise 3:
* This program is an example of how to link the MEPS-HC Medical Conditions file, 
* the Office Visits Event file, and the Full-Year Consolidated file for 
* data year 2020 in order to estimate the following:
*
*   - Total number of people with office-based medical visit for COVID
*   - Total number of office visits for COVID
*   - Total expenditures on office visits for COVID 
*   - Percent of people with office visit for COVID, by age
*   - Average expenditure on office visits for COVID, by age
* 
* Input files:
*   - h220d.dta        (2020 Inpatient Stays file)
*   - h222.dta         (2020 Conditions file)
*   - h220if1.dta      (2020 CLNK: Condition-Event Link file)
*   - h224.dta         (2020 Full-Year Consolidated file)
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
log using Ex3.log, replace 

/* Get data from web (you can also download manually) */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h220g/h220gdta.zip" "h220gdta.zip", replace
unzipfile "h220gdta.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h222/h222dta.zip" "h222dta.zip", replace
unzipfile "h222dta.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h220i/h220if1dta.zip" "h220if1dta.zip", replace
unzipfile "h220if1dta.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h224/h224dta.zip" "h224dta.zip", replace
unzipfile "h224dta.zip", replace 

/* linkage file */
// inspect file, save

/* FY condolidated file, person-level */

/* Office-based file, visit-level */

// inspect file, save

/* Conditions file, condition-level, subset to COVID */

// keep only records for COVID

// inspect file, save 

/* merge conditions to CLNK file by condidx, drop unmatched */

// drop observations that do not match

// inspect file

// drop duplicate fills--- fills that would otherwise be counted twice */

// inspect file after de-duplication

/* merge to inpatient file by evntidx, drop unmatched */

// drop observations for that do not match

// inspect file

/* collapse to person-level (DUPERSID), sum to get number of office visits and expenditures */

/* merge to FY file, create flag for any ipat for COVID */



/* Set survey options */

/* total people with office visit for COVID */

/* total number of office visits for COVID */

/* total expenditures for office visits for COVID */

/* percent with office visit for COVID by age */

/* average number of office visits for COVID per person by age */
 
/* average expenditure on office visits for COVID per person by age */
