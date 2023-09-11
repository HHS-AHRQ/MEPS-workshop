/* ----------------------------------------------------------------------------------------------------------------

MEPS-HC: Office-based medical visits and expenditures for the treatment of COVID-19

This example code shows how to link the MEPS-HC Medical Conditions file to the Office-based medical visits file for 
data year 2020 in order to estimate the following:
	- Total number of people with an office-based visit for the treatment of COVID-19 
	- Total number of office-based visits for the treatment of COVID-19
	- Total expenditures on office-based visits for the treatment of COVID-19 
	- Percent of people with an office-based visit for COVID-19, by age
	- Mean office-based expenditures per person on COVID-19 among people with an office-based visit for COVID-19, by age

Input files:
  - h220g.sas7bdat        (2020 Office-Based Medical Visits file)
  - h222.sas7bdat         (2020 Medical Conditions file)
  - h220if1.sas7bdat      (2020 CLNK: Condition-Event Link file)
  - h224.sas7bdat         (2020 Full-Year Consolidated file)

Resources:
  - CCSR codes: 
    https://github.com/HHS-AHRQ/MEPS/blob/master/Quick_Reference_Guides/meps_ccsr_conditions.csv

  - MEPS-HC Public Use Files: 
    https://meps.ahrq.gov/mepsweb/data_stats/download_data_files.jsp

  - MEPS-HC online data tools: 
    https://datatools.ahrq.gov/meps-hc

---------------------------------------------------------------------------------------------------------------- */

/* Set libname for where MEPS SAS data files are saved on your computer */ 




/**** Read in data files and keep only needed variables ------------------------------------------------------- */ 

/* Office-based (OB) medical visits file (record = office-based visit for a person) */





/* Conditions file (record = medical condition for a person) */





/* Conditions-event link file (crosswalk between conditions and medical events) */





/* Full-year consolidated (person-level) file (record = MEPS sample member) */





/**** Prepare data for estimation --------------------------------------------------------------------------------- */

/* Subset to only condition records for COVID-19 (any CCSR = "INF012") */
/* Note: you can find the CCSRs for collapsed condition categories here: 
https://github.com/HHS-AHRQ/MEPS/blob/master/Quick_Reference_Guides/meps_ccsr_conditions.csv */ 





/* Example to show someone with 'duplicate' COVID-19 conditions with different CONDIDXs. */





/* Get EVNTIDX values for COVID-19 records from CLNK file */





/* Sort data to prepare for merge between clnk_covid and ob20 */





/* Because some people can have multiple CONDIDX values for COVID-19 as shown in the example above, and each of 
these different CONDIDX IDs can link to the same OB stay, it is necessary to de-duplicate on EVNTIDX. 
!!Note - we do not have an issue with duplicates in this particular example, but there can be issues with duplicates
when analyzing another condition/event pair. */






/* Merge to OB file and only keep records in both files.
Create dummy variable for each unique OB visit (this will be used for estimating events) */





/* Sum number of OB stays and OB expenditures on COVID-19 within each person */





/* Merge person-level totals back to FYC and create flag for whether a person has any OB visits for COVID-19 */





/* QC creation of agecat and confirm there are no values of 'Error!' or missing values */ 





/* QC: check counts of covid_ob_flag=1 and compare to the number of rows in ob_by_pers.  
Confirm there are no missing values */





/* Check sample sizes in each age group to make sure they are sufficient */ 





/* QC: There should be no records where covid_ob_flag=0 and (tot_exp > 0 or tot_ob > 0) */





/*** ESTIMATION -------------------------------------------------------------------------------------------------- */ 

* Suppress graphics;




* National Totals; 

/* Estimates for the following:
	- sum of covid_ob_flag = total people with OB visit for COVID-19
	- sum of tot_ob = total number of OB visits for COVID-19
	- sum of tot_exp = total OB expenditures for COVID-19 */

title 'National Totals for OB visits related to COVID-19';






/* Proportion of people with an OB visit for COVID-19 by age group */
/* To convert to percentages, multiply by 100.  See exercise 1 for alternate methods of calculating percents */ 

title 'Proportion of people with an OB visit for COVID-19 by age group'; 






/* Average expenditures per person on OB visits for COVID-19 among people with at least one OB visit for COVID-19 
(covid_ob_flag = '1'), by age */ 

title 'Average per-person expenditures on COVID-19 OB visits among people with COVID-19 OB visits';








title;  /* Cancel title statement */


/******** Bonus! **********/ 

/* A note about telehealth:
   - telehealth questions were added to the survey in fall 2020           
   - TELEHEALTHFLAG = -15 for events reported before telehealth questions were added   
   - Recommendation: imputation or sensitivity analysis  */ 
