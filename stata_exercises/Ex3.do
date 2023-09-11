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
use h220if1, clear
rename *, lower
// inspect file, save
describe
list dupersid condidx evntidx eventype if _n<20
save CLNK_2020, replace

/* FY condolidated file, person-level */
use DUPERSID AGELAST VARSTR VARPSU PERWT20F using h224, clear
rename *, lower
gen agecat=.
replace agecat=1 if agelast < 18
replace agecat=2 if agelast >= 18 & agelast < 65
replace agecat=3 if agelast >= 65

label define agecat 1 "<18" 2 "18-64" 3 "65+"
label values agecat agecat
tab1 agecat, m 

save FY_2020, replace
describe

/* Office-based file, visit-level */
use DUPERSID EVNTIDX OBXP20X using h220g, clear
rename *, lower
// inspect file, save
list dupersid evntidx obxp20x if _n<21
save OB_2020, replace
describe

/* Conditions file, condition-level, subset to COVID */
use DUPERSID CONDIDX ICD10CDX CCSR1X CCSR2X CCSR3X using h222, clear
rename *, lower
// keep only records for COVID
keep if ccsr1x=="INF012" | ccsr2x=="INF012" | ccsr3x=="INF012" 
// inspect file, save 
list dupersid condidx ccsr1x ccsr2x ccsr3x icd10cdx if _n<21
save COND_2020, replace
describe

/* merge conditions to CLNK file by condidx, drop unmatched */
merge m:m condidx using CLNK_2020
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
merge 1:m evntidx using OB_2020
// drop observations for that do not match
drop if _merge~=3
drop _merge
// inspect file
list dupersid condidx icd10cdx evntidx obxp20x if _n<21
describe

/* collapse to person-level (DUPERSID), sum to get number of office visits and expenditures */
gen one=1
collapse (sum) num_obvis=one (sum) exp_obvis=obxp20x, by(dupersid)

/* merge to FY file, create flag for any ipat for COVID */
merge 1:1 dupersid using FY_2020
replace exp_obvis=0 if _merge==2
replace num_obvis=0 if _merge==2
gen any_obvis=(num_obvis>0)



/* Set survey options */
svyset varpsu [pw = perwt20f], strata(varstr) vce(linearized) singleunit(centered)

/* total people with office visit for COVID */
svy: total any_obvis

/* total number of office visits for COVID */
svy: total num_obvis
di %15.0f r(table)[1,1]
di %15.0f r(table)[2,1]

/* total expenditures for office visits for COVID */
svy: total exp_obvis
di %15.0f r(table)[1,1]
di %15.0f r(table)[2,1]

/* percent with office visit for COVID by age */
svy: mean any_obvis, over(agecat)

/* average number of office visits for COVID per person by age */
svy: mean num_obvis, over(agecat)
svy, sub(if any_obvis==1): mean num_obvis, over(agecat)
 
/* average expenditure on office visits for COVID per person by age */
svy: mean exp_obvis, over(agecat)
svy, sub(if any_obvis==1): mean exp_obvis, over(agecat)
