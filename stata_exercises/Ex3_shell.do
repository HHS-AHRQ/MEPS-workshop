**********************************************************************************************
* Exercise 3
*  This program illustrates how to pool MEPS data files from different years. It
*  highlights one example of a discontinuity that may be encountered when 
*  working with data from before and after the 2018 CAPI re-design.
*  
*  The program pools 2017, 2018 and 2019 data and calculates:
*   - Percentage of people with Joint Pain / Arthritis (JTPAIN**, ARTHDX)
*   - Average expenditures per person, by Joint Pain status (TOTEXP, TOTSLF)
* 
*  Notes:
*   - Variables with year-specific names must be renamed before combining files
*     (e.g. 'TOTEXP17' and 'TOTEXP18' renamed to 'totexp')
* 
*   - HC-36 must be merged to get strata and psu variables when pooling years
* 
*  Input files: 
*   - C:/MEPS/h216.dta (2019 Full-year file)
*   - C:/MEPS/h209.dta (2018 Full-year file)
*   - C:/MEPS/h201.dta (2017 Full-year file)
*	- C:/MEPS/h36u19.dta (pooled linkage file)
* 
*  This program is available at:
*  https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/stata_exercises
**********************************************************************************************
clear
set more off
capture log close
cd C:\MEPS
log using Ex3.log, replace

/* 2017 */
// rename 2017 variables, create joint pain indicator

// merge pooled linkage file


/* 2018 */
// rename 2018 variables, create joint pain indicator 

// merge pooled linkage file


/* 2019 */
// rename 2019 variables, create joint pain indicator 

// merge pooled linkage file 


/* append 2018 to 2017, erase temp file */

/* create pooled person-level weight and subpop */

/* set up survey parameters */

/* estimate percent with any joint pain (any_jtpain) */

/* estimate mean expenditures per person by whether they have joint pain*/

log close
