* MEPS-HC: Prescribed medicine utilization and expenditures for 
* the treatment of hyperlipidemia
* 
* This example code shows how to link the MEPS-HC Medical Conditions file 
* to the Prescribed Medicines file for data year 2020 in order to estimate
* the following:
*
*   - Total number of people with one or more rx fills for hyperlipidemia
*   - Total rx fills for the treatment of hyperlipidemia
*   - Total rx expenditures for the treatment of hyperlipidemia 
*   - Mean number of Rx fills for hyperlipidemia per person, among those with any
*   - Mean expenditures on Rx fills for hyperlipidemia per person, among those with any
* 
* Input files:
*   - h220a.dta        (2020 Prescribed Medicines file)
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
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h220a/h220adta.zip" "h220adta.zip", replace
unzipfile "h220adta.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h222/h222dta.zip" "h222dta.zip", replace
unzipfile "h222dta.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h220i/h220if1dta.zip" "h220if1dta.zip", replace
unzipfile "h220if1dta.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h224/h224dta.zip" "h224dta.zip", replace
unzipfile "h224dta.zip", replace 

/* linkage file */
use h220if1, clear
rename *, lower
save CLNK_2020, replace

/* PMED file, person-Rx-level */
use DUPERSID DRUGIDX RXRECIDX LINKIDX RXDRGNAM RXXP20X using h220a, clear
rename *, lower
rename linkidx evntidx
save PM_2020, replace

/* FY condolidated file, person-level */
use DUPERSID SEX CHOLDX VARSTR VARPSU PERWT20F using h224, clear
rename *, lower
save FY_2020, replace

/* Conditions file, person-condition-level, subset to hyperlipidemia */
use DUPERSID CONDIDX ICD10CDX CCSR1X-CCSR3X using h222, clear
rename *, lower
keep if ccsr1x == "END010" | ccsr2x == "END010" | ccsr3x == "END010"
// inspect conditions file
sort dupersid condidx
list dupersid condidx icd10cdx if _n<20
list if dupersid=="2320134102"

/* merge to CLNK file by dupersid and condidx, drop unmatched */
merge m:m dupersid condidx using CLNK_2020
// drop observations for that do not match
drop if _merge~=3
drop _merge
// inspect file 
list dupersid condidx icd10cdx if dupersid=="2320134102"

/* merge to prescribed meds file by dupersid and evntidx, drop unmatched */
merge m:m dupersid evntidx using PM_2020
// drop observations for that do not match
drop if _merge~=3
drop _merge
// inspect file 
list dupersid condidx icd10cdx evntidx rxrecidx if dupersid=="2320134102"

/* drop duplicates */
duplicates drop dupersid rxrecidx, force
// inspect file 
list dupersid condidx icd10cdx evntidx rxrecidx if dupersid=="2320134102"

/* collapse to person-level (DUPERSID), sum to get number of fills and expenditures */
gen one=1
collapse (sum) num_rx=one (sum) exp_rx=rxxp20x, by(dupersid)
/* merge to FY file, create flag for any Rx fill for HL */
merge 1:1 dupersid using FY_2020
replace exp_rx=0 if _merge==2
replace num_rx=0 if _merge==2
gen any_rx=(num_rx>0)

/* Set survey options */
svyset varpsu [pw = perwt20f], strata(varstr) vce(linearized) singleunit(centered)

/* total number of people with 1+ Rx fills for HL */
svy: total any_rx
/* Total rx fills for the treatment of hyperlipidemia */
svy: total num_rx
/* Total rx expenditures for the treatment of hyperlipidemia */
svy: total exp_rx
/* mean number of Rx fills for hyperlipidemia per person, among those with any */
svy, sub(any_rx): mean num_rx
/* mean expenditures on Rx fills for hyperlipidemia per person, among those with any */
svy, sub(any_rx): mean exp_rx


