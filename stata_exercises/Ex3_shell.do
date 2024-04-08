* Exercise 3:
* This program is an example of how to link the MEPS-HC Medical Conditions file, 
* the Office Visits Event file, and the Full-Year Consolidated file for 
* data year 2021 in order to estimate the following:
*
*   - Total number of people with office-based medical visit for cancer (malignant neoplasms)
*   - Total number of office visits for cancer
*   - Total expenditures on office visits for cancer 
*   - Percent of people with office visit for cancer, by age
*   - Average expenditure on office visits for cancer, by age
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
log using Ex3.log, replace 

/* Get data from web (you can also download manually) */
/* Office visits */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h229g/h229gdta.zip" "h229gdta.zip", replace
unzipfile "h229gdta.zip", replace 
/* Conditions */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h231/h231dta.zip" "h231dta.zip", replace
unzipfile "h231dta.zip", replace 
/* CLNK */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h229i/h229if1dta.zip" "h229if1dta.zip", replace
unzipfile "h229if1dta.zip", replace 
/* Full-year consolidated file */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h233/h233dta.zip" "h233dta.zip", replace
unzipfile "h233dta.zip", replace 

/* linkage file */

// inspect file, save




/* FY condolidated file, person-level */




/* Office-based file, visit-level */

// inspect file, save




/* Conditions file, condition-level, subset to cancer--malignant neoplasms */

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


/* merge to FY file, create flag for any office visit for malignant neoplasm */


/* Set survey options */

/* total people with office visit for malignant neoplasm */

/* total number of office visits for malignant neoplasm */

/* total expenditures for office visits for malignant neoplasm */

/* percent with office visit for malignant neoplasm by age */

/* average number of office visits for malignant neoplasm per person by age */
 
/* average expenditure on office visits for malignant neoplasm per person by age */
