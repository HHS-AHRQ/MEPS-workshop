**********************************************************************************************
* Exercise 2
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
*   - C:/MEPS/H36u21.dta (pooled linkage file)
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
log using Ex2.log, replace

/* Get Data */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h209/h209dta.zip" "h209dta.zip", replace
unzipfile "h209dta.zip", replace 

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h216/h216dta.zip" "h216dta.zip", replace
unzipfile "h216dta.zip", replace 

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h224/h224dta.zip" "h224dta.zip", replace
unzipfile "h224dta.zip", replace 

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h036/h36u21dta.zip" "h36u21dta.zip", replace
unzipfile "h36u21dta.zip", replace 

/* prepare pooled linkage file */
use h36u21.dta, clear
rename *, lower
keep if inh209==1|inh216==1|inh224==1
save h36, replace

/* rename 2018 variables, merge on pooled-linkage variables */
use C:\MEPS\h209, clear
rename *, lower
keep dupersid panel varpsu varstr perwt18f inscov18 povcat18 totexp18 totslf18 cancerdx cabladdr agelast
rename (perwt18f inscov18 povcat18 totexp18 totslf18) (perwtf inscov povcat totexp totslf) 
gen year=2018

merge 1:1 dupersid using h36, keepusing(stra9621 psu9621)
drop if _merge~=3
drop _merge
save ex3_2018.dta, replace

/* rename 2019 variables, merge on pooled-linkage variables */
use C:\MEPS\h216, clear
rename *, lower
keep dupersid panel varpsu varstr perwt19f inscov19 povcat19 totexp19 totslf19 cancerdx cabladdr agelast
rename (perwt19f inscov19 povcat19 totexp19 totslf19) (perwtf inscov povcat totexp totslf) 
gen year=2019

merge 1:1 dupersid using h36, keepusing(stra9621 psu9621)
drop if _merge~=3
drop _merge
save ex3_2019.dta, replace

/* rename 2020 variables, merge on pooled-linkage variables */
use C:\MEPS\h224, clear
rename *, lower
keep dupersid panel varpsu varstr perwt20f inscov20 povcat20 totexp20 totslf20 cancerdx cabladdr agelast
rename (perwt20f inscov20 povcat20 totexp20 totslf20) (perwtf inscov povcat totexp totslf) 
gen year=2020

merge 1:1 dupersid using h36, keepusing(stra9621 psu9621)
drop if _merge~=3
drop _merge
save ex3_2020.dta, replace

/* append years together, erase temp files */
append using ex3_2019 ex3_2018
erase ex3_2018.dta
erase ex3_2019.dta
erase ex3_2020.dta

/* create common bladder cancer variable */ 
recode cabladdr (1=1) (2=0) (*=.), gen(bladder_cancer)
replace bladder_cancer=0 if cancerdx==2
tab bladder_cancer, m
// here is an alternative way to create bladder cancer variable 
//gen bladder_cancer=.
//replace bladder_cancer=0 if cancerdx==2 | cabladdr==2
//replace bladder_cancer=1 if cabladdr==1 

/* create pooled person-level weight and subpop */
gen poolwt=perwt/3

/* set up survey parameters */
svyset psu9621 [pw=poolwt], str(stra9621) vce(linearized) singleunit(centered) 

/* estimate percent with any bladder cancer */
svy, sub(if cancerdx>0): mean bladder_cancer

/* estimate mean expenditures per person by whether they have bladder cancer*/
// Total expenditures
svy, sub(if cancerdx>0): mean totexp, over(bladder_cancer)

// OOP expenditures
svy, sub(if cancerdx>0): mean totslf, over(bladder_cancer)

