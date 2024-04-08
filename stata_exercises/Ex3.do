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
use h229if1, clear
rename *, lower
// inspect file, save
describe
list dupersid condidx evntidx eventype if _n<20
save CLNK_2021, replace

/* FY condolidated file, person-level */
use DUPERSID AGELAST VARSTR VARPSU PERWT21F using h233, clear
rename *, lower
gen agecat=.
replace agecat=1 if agelast < 18
replace agecat=2 if agelast >= 18 & agelast < 65
replace agecat=3 if agelast >= 65

label define agecat 1 "<18" 2 "18-64" 3 "65+"
label values agecat agecat
tab1 agecat, m 

save FY_2021, replace
describe

/* Office-based file, visit-level */
use DUPERSID EVNTIDX OBXP21X using h229g, clear
rename *, lower
// inspect file, save
list dupersid evntidx obxp21x if _n<21
save OB_2021, replace
describe

/* Conditions file, condition-level, subset to cancer--malignant neoplasms */
use DUPERSID CONDIDX ICD10CDX CCSR1X CCSR2X CCSR3X using h231, clear
rename *, lower
// keep only records for COVID
gen malneo1=((substr(ccsr1x,1,3)=="NEO" & ccsr1x~="NEO073") | (ccsr1x=="FAC006"))
gen malneo2=((substr(ccsr2x,1,3)=="NEO" & ccsr2x~="NEO073") | (ccsr2x=="FAC006"))
gen malneo3=((substr(ccsr3x,1,3)=="NEO" & ccsr3x~="NEO073") | (ccsr3x=="FAC006"))
keep if malneo1==1 | malneo2==1 | malneo3==1

// inspect file, save 
list dupersid condidx ccsr1x ccsr2x ccsr3x icd10cdx if _n<21
save COND_2021, replace
describe

/* merge conditions to CLNK file by condidx, drop unmatched */
merge m:m condidx using CLNK_2021
// drop observations that do not match
drop if _merge~=3
drop _merge
// inspect file
list dupersid condidx evntidx icd10cdx if _n<21
// drop duplicate fills--- fills that would otherwise be counted twice */
duplicates drop evntidx, force
// inspect file after de-duplication
list dupersid condidx evntidx icd10cdx if _n<21
describe

/* merge to inpatient file by evntidx, drop unmatched */
merge 1:m evntidx using OB_2021
// drop observations for that do not match
drop if _merge~=3
drop _merge
// inspect file
list dupersid condidx icd10cdx evntidx obxp21x if _n<21
describe

/* collapse to person-level (DUPERSID), sum to get number of office visits and expenditures */
gen one=1
collapse (sum) num_obvis=one (sum) exp_obvis=obxp21x, by(dupersid)

/* merge to FY file, create flag for any office visit for malignant neoplasm */
merge 1:1 dupersid using FY_2021
replace exp_obvis=0 if _merge==2
replace num_obvis=0 if _merge==2
gen any_obvis=(num_obvis>0)

/* Set survey options */
svyset varpsu [pw = perwt21f], strata(varstr) vce(linearized) singleunit(centered)

/* total people with office visit for malignant neoplasm */
svy: total any_obvis
di %15.0f r(table)[1,1]
di %15.0f r(table)[2,1]

/* total number of office visits for malignant neoplasm */
svy: total num_obvis
di %15.0f r(table)[1,1]
di %15.0f r(table)[2,1]

/* total expenditures for office visits for malignant neoplasm */
svy: total exp_obvis
di %15.0f r(table)[1,1]
di %15.0f r(table)[2,1]

/* percent with office visit for malignant neoplasm by age */
svy: mean any_obvis
svy: mean any_obvis, over(agecat)

/* average number of office visits for malignant neoplasm per person by age */
svy, sub(if any_obvis==1): mean num_obvis
svy, sub(if any_obvis==1): mean num_obvis, over(agecat)
 
/* average expenditure on office visits for malignant neoplasm per person by age */
svy, sub(if any_obvis==1): mean exp_obvis
svy, sub(if any_obvis==1): mean exp_obvis, over(agecat)
