**********************************************************************************************
* Exercise 2
*  This program illustrates how to pool MEPS data files from multiple years to enable 
*  the analysis of a small sub-sample (people with bladder cancer)
*  
*  The program pools 2019-2021 data and calculates:
*   - Percentage of people with bladder cancer 
*   - Average expenditures per person, with and without bladder cancer
* 
*  Notes:
*   - Variables with year-specific names must be renamed before combining files
*     (e.g. 'TOTEXP19' renamed to 'totexp')
* 
*  Input files: 
*   - C:/MEPS/h216.dta (2019 Full-year file)
*   - C:/MEPS/h224.dta (2020 Full-year file)
*   - C:/MEPS/h233.dta (2021 Full-year file)
*  This program is available at:
*  https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/stata_exercises
**********************************************************************************************
clear
set more off
capture log close
cd C:\MEPS
log using Ex2.log, replace

/* Get Data */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h216/h216dta.zip" "h216dta.zip", replace
unzipfile "h216dta.zip", replace 

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h224/h224dta.zip" "h224dta.zip", replace
unzipfile "h224dta.zip", replace 

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h233/h233dta.zip" "h233dta.zip", replace
unzipfile "h233dta.zip", replace 


/* rename 2019 variables, merge on pooled-linkage variables */
use C:\MEPS\h216, clear
rename *, lower
keep dupersid panel varpsu varstr perwt19f inscov19 povcat19 totexp19 totslf19 cancerdx cabladdr agelast
rename (perwt19f inscov19 povcat19 totexp19 totslf19) (perwtf inscov povcat totexp totslf) 
gen year=2019
save ex2_2019, replace

/* rename 2020 variables, merge on pooled-linkage variables */
use C:\MEPS\h224, clear
rename *, lower
keep dupersid panel varpsu varstr perwt20f inscov20 povcat20 totexp20 totslf20 cancerdx cabladdr agelast
rename (perwt20f inscov20 povcat20 totexp20 totslf20) (perwtf inscov povcat totexp totslf) 
gen year=2020
save ex2_2020, replace

/* rename 2021 variables, merge on pooled-linkage variables */
use C:\MEPS\h233, clear
rename *, lower
keep dupersid panel varpsu varstr perwt21f inscov21 povcat21 totexp21 totslf21 cancerdx cabladdr agelast
rename (perwt21f inscov21 povcat21 totexp21 totslf21) (perwtf inscov povcat totexp totslf) 
gen year=2021

/* append years together, erase temp files */
append using ex2_2020 ex2_2019
erase ex2_2019.dta
erase ex2_2020.dta

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
svyset varpsu [pw=poolwt], str(varstr) vce(linearized) singleunit(centered) 

/* estimate percent with any bladder cancer */
svy, sub(if cancerdx>0): mean bladder_cancer

/* estimate mean expenditures per person by whether they have bladder cancer*/
// Total expenditures
svy, sub(if cancerdx>0): mean totexp, over(bladder_cancer)

// OOP expenditures
svy, sub(if cancerdx>0): mean totslf, over(bladder_cancer)

