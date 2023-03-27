/* ----------------------------------------------------------------------------------------------------------------

MEPS-HC: Prescribed medicine utilization and expenditures for the treatment of hyperlipidemia

This example code shows how to link the MEPS-HC Medical Conditions file to the Prescribed Medicines file for data year 
2020 in order to estimate the following:
	- Total rx fills for the treatment of hyperlipidemia
	- Total rx expenditures for the treatment of hyperlipidemia 
	- Number of people treated for hyperlipidemia with prescribed medicines
	- Mean rx expenditures and fills per person for the treatment of hyperlipidemia (among those with any rx fills for 
	  hyperlipidemia)

Input files:
  - h220a.sas7bdat        (2020 Prescribed Medicines file)
  - h222.sas7bdat         (2020 Conditions file)
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

/* PMED file (record = rx fill or refill for a person) */




/* Conditions file (record = medical condition for a person) */





/* Conditions-event link file (crosswalk between conditions and medical events, including PMEDs) */





/* Full-year consolidated (person-level) file (record = MEPS sample member) */





/**** Prepare data for estimation --------------------------------------------------------------------------------- */

/* Subset to only condition records for hyperlipidemia (any CCSR = "END010") */
/* Note: you can find the CCSRs for collapsed condition categories here: 
https://github.com/HHS-AHRQ/MEPS/blob/master/Quick_Reference_Guides/meps_ccsr_conditions.csv */ 





/* Example to show someone with 'duplicate' hyperlipidemia conditions with different CONDIDXs. */





/* Get EVNTIDX values for hyperlipidemia records from CLNK file */






/* Sort data to prepare for merge between clnk_hl and pmed20 */






/* !!Note: Our 'duplicate' hyperlipidemia records have created a many-to-many merge between clnk_hl and pmed20, but the
SAS merge statement does not do 'full' or 'traditional' many to many merges! */ 

/* Example - for EVNTIDX = '2320134102003703' there are 2 records on clnk_hl and 3 records on pmed20 */






/* A 'full' many-to-many merge would create 2 x 3 = 6 combinations (rows) in the output, but let's look at what SAS
merge does for this one example case */







/* Get PMED fills linked to hyperlipidemia.
Using proc sql to factilitate 'full' many-to-many merge which regular SAS merge statements don't do */






/* Example showing 'duplicate' fills created from 'duplicate' conditions */





/* De-duplicate unique fills within a person who has hyperlipidemia */





/* Revisit 'duplicate' fill example to see effects of de-duplicating */





/* QC: Look at top PMEDs for hyperlipidemia to see if they make sense */





/* Create dummy variable for each unique fill (this will be summed within each person to get total fills per person) */





/* Sum number of fills, number of drugs, and expenditures linked to hyperlipidemia within each person */





/* Revisiting 'duplicate' example at the person-level to show that fills were only counted once */





/* Merge person-level totals back to FYC and create flag for whether a person has any pmed fills for hyperlipidemia */








/* QC: check counts of hl_pmed_flag=1 and compare to the number of rows in drugs_by_pers.  
Confirm there are no missing values */





/* QC: There should be no records where hl_pmed_flag=0 and (hl_drug_exp > 0 or n_hl_fills > 0) */





/*** ESTIMATION -------------------------------------------------------------------------------------------------- */ 

/* Suppress graphics */



/* National Totals */

/* Estimates for the following:
	- sum of hl_pmed_flag = total people with any rx fills for HL
	- sum of n_hl_fills = total number of rx fills for HL
	- sum of hl_drug_exp = total rx expenditures for HL */








/* Per-person averages for people with at least one PMED fill for hyperlipidemia (hl_pmed_flag = 1) 
	-mean of hl_drug_exp = avg expenditures per person on rx for HL 
	-mean of n_hl_fills = avg number of fills per person on rx for HL */



