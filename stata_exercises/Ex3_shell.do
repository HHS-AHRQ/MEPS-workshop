**********************************************************************************************
* Exercise 3
*  This program illustrates how to pool MEPS data files from multiple years to enable 
*  the analysis of a small sub-sample (people with bladder cancer)
*  
*  The program pools 2018-2020 data and calculates:
*   - Percentage of people with bladder cancer 
*   - Average expenditures per person, with and without bladder cancer
* 
*  Notes:
*   - strata and psu variables must be taken from the pooled-linkage file
*   - Variables with year-specific names must be renamed before combining files
*     (e.g. 'TOTEXP18' renamed to 'totexp')
* 
*  Input files: 
*   - C:/MEPS/H36u20.dta (pooled linkage file)
*   - C:/MEPS/h209.dta (2018 Full-year file)
*   - C:/MEPS/h216.dta (2019 Full-year file)
*   - C:/MEPS/h224.dta (2020 Full-year file)
* 
*  This program is available at:
*  https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/stata_exercises
**********************************************************************************************
clear
set more off
capture log close
cd C:\MEPS
log using Ex3.log, replace

/* Get Data */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h209/h209dta.zip" "h209dta.zip", replace
unzipfile "h209dta.zip", replace 

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h216/h216dta.zip" "h216dta.zip", replace
unzipfile "h216dta.zip", replace 

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h224/h224dta.zip" "h224dta.zip", replace
unzipfile "h224dta.zip", replace 

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h036/h36u20dta.zip" "h36u20dta.zip", replace
unzipfile "h36u20dta.zip", replace 

/* prepare pooled linkage file */







/* rename 2018 variables, merge on pooled-linkage variables */






/* rename 2019 variables, merge on pooled-linkage variables */






/* rename 2020 variables, merge on pooled-linkage variables */







/* append years together, erase temp files */






/* create common bladder cancer variable */ 






/* create pooled person-level weight and subpop */





/* set up survey parameters */

/* estimate percent with any bladder cancer */





/* estimate mean expenditures per person by whether they have bladder cancer*/





