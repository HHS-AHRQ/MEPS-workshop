/* ----------------------------------------------------------------------------------------------------------------

MEPS-HC: Office-based medical visits and expenditures for the treatment of cancer

This example code shows how to link the MEPS-HC Medical Conditions file to the Office-based medical visits file for 
data year 2021 in order to estimate the following:
	- Total number of people with an office-based visit for the treatment of cancer 
	- Total number of office-based visits for the treatment of cancer
	- Total expenditures on office-based visits for the treatment of cancer 
	- Percent of people with an office-based visit for cancer
	- Mean office-based expenditures per person on cancer among people with an office-based visit for cancer

Input files:
  - h229g.sas7bdat        (2021 Office-Based Medical Visits file)
  - h231.sas7bdat         (2021 Medical Conditions file)
  - h229if1.sas7bdat      (2021 CLNK: Condition-Event Link file)
  - h233.sas7bdat         (2021 Full-Year Consolidated file)

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

/* Subset to only condition records for cancer.  Cancer is any CCSR starting with "NEO" EXCEPT for NEO073, which is
benign neoplasms.  We are also including FAC006 which is "encounter for antineoplastic therapies". */
/* Note: you can find the CCSRs for collapsed condition categories, including cancer, here: 
https://github.com/HHS-AHRQ/MEPS/blob/master/Quick_Reference_Guides/meps_ccsr_conditions.csv */ 





/* Example to show someone with 'duplicate' cancer conditions with different CONDIDXs. DUPERSID = '2320291102' */





/* Get EVNTIDX values for cancer records from CLNK file */





/* Sort data to prepare for merge between clnk_cancer and ob21 */





/* Example to show OB visits that treat multiple cancer conditions for the same person. DUPERSID = '2320379102' */





/* Because some people can have multiple CONDIDX values for cancer, and each of these different CONDIDXs can link 
to the same OB visit, it is necessary to de-duplicate on EVNTIDX before merging so these OB visits are not double
counted. */





/* Merge to OB file and only keep records in both files.
Create dummy variable for each unique OB visit (this will be used for estimating events) */





/* Sum number of OB stays and OB expenditures on cancer within each person */





/* Merge person-level totals back to FYC and create flag for whether a person has any OB visits for cancer */





/* QC: check counts of cancer_ob_flag=1 and compare to the number of rows in ob_by_pers.  
Confirm there are no missing values */





/* QC: There should be no records where cancer_ob_flag=0 and (tot_exp > 0 or tot_ob > 0) */





/*** ESTIMATION -------------------------------------------------------------------------------------------------- */ 

* Suppress graphics;



* National Totals; 

/* Estimates for the following:
	- sum of cancer_ob_flag = total people with OB visit for cancer
	- sum of tot_ob = total number of OB visits for cancer
	- sum of tot_exp = total OB expenditures for cancer */

title 'National Totals';






/* Proportion of people with an OB visit for cancer */
/* To convert to percentages, multiply by 100.  See exercise 1 for alternate methods to directly calculate percents */ 

title 'Proportion of people with an OB visit for cancer';






/* Average expenditures per person on OB visits for cancer among people with at least one OB visit for cancer
(cancer_ob_flag = '1') */ 

title 'Avg. exp. per person on OB visits for cancer among people with 1+ OB visit for cancer';







title; /* cancel the title statement */ 
