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

libname meps 'C:\MEPS';

/**** Read in data files and keep only needed variables ------------------------------------------------------- */ 

/* Office-based (OB) medical visits file (record = office-based visit for a person) */

data ob21;
	set meps.h229g;
	keep dupersid evntidx obxp21x;
run;

/* Conditions file (record = medical condition for a person) */

data cond21;
	set meps.h231;
	keep dupersid condidx icd10cdx ccsr1x ccsr2x ccsr3x;
run;

/* Conditions-event link file (crosswalk between conditions and medical events) */

data clnk21;
	set meps.h229if1;
run;

/* Full-year consolidated (person-level) file (record = MEPS sample member) */

data fyc21;
	set meps.h233;
	keep dupersid agelast perwt21f varpsu varstr;
run;


/**** Prepare data for estimation --------------------------------------------------------------------------------- */

/* Subset to only condition records for cancer.  Cancer is any CCSR starting with "NEO" EXCEPT for NEO073, which is
benign neoplasms.  We are also including FAC006 which is "encounter for antineoplastic therapies". */
/* Note: you can find the CCSRs for collapsed condition categories, including cancer, here: 
https://github.com/HHS-AHRQ/MEPS/blob/master/Quick_Reference_Guides/meps_ccsr_conditions.csv */ 

data cancer;
	set cond21;  
	where (substr(CCSR1X, 1, 3) = "NEO" or substr(CCSR2X, 1, 3) = "NEO" or substr(CCSR3X, 1, 3) = "NEO" or
	CCSR1X = "FAC006" or CCSR2X = "FAC006" or CCSR3X = "FAC006") and (CCSR1X ne "NEO073" and CCSR2X ne "NEO073"
	and CCSR3X ne "NEO073");
run; 

/* Example to show someone with 'duplicate' cancer conditions with different CONDIDXs. */

proc sort data=cancer nodupkey dupout=dup_cancer out=temp1; /* duplicate IDs are output to dup_cancer */
	by dupersid;
run;

proc print data=cancer noobs;
	where dupersid = '2320291102'; /* using the first duplicate DUPERSID from dup_cancer as an example */ 
run;

/* Get EVNTIDX values for cancer records from CLNK file */

proc sort data=cancer; /* note this file intentionally still contains duplicates! */ 
	by dupersid condidx;
run;

proc sort data=clnk21;
	by dupersid condidx;
run;

/* Note - this merge can be 1-1 or 1-many (there can be multiple medical events associated with one condition ID) */

data clnk_cancer;
	merge cancer (in=a) clnk21 (in=b);
	by dupersid condidx;
	if a and b; /* only keep records that are in both files */ 
run;

/* Sort data to prepare for merge between clnk_cancer and ob21 */

proc sort data=clnk_cancer;
	by dupersid evntidx;
run;

proc sort data=ob21;
	by dupersid evntidx;
run;


/* Example to show OB visits that treat multiple cancer conditions for the same person. DUPERSID = '2320379102' */

proc print data=clnk_cancer noobs;
	where dupersid = '2320379102';  
run;


/* Because some people can have multiple CONDIDX values for cancer, and each of these different CONDIDXs can link 
to the same OB visit, it is necessary to de-duplicate on EVNTIDX before merging so these OB visits are not double
counted. */

proc sort data=clnk_cancer nodupkey; 
	by dupersid evntidx;
run;


/* Merge to OB file and only keep records in both files.
Create dummy variable for each unique OB visit (this will be used for estimating events) */

data cancer_ob;
	merge clnk_cancer (in=a) ob21 (in=b);
	by dupersid evntidx;
	if a and b;
	ob_cancer = 1;
run;

/* Sum number of OB stays and OB expenditures on cancer within each person */

proc means data=cancer_ob noprint nway sum;
	class dupersid; 	/* sum within each person */
	var ob_cancer obxp21x; 
	output out=ob_by_pers (drop = _TYPE_ _FREQ_) sum=tot_ob tot_exp;
run;


/* Merge person-level totals back to FYC and create flag for whether a person has any OB visits for cancer */

data fyc_merged;
	merge fyc21 (in=a) ob_by_pers;
	by dupersid;
	if a; 	/* keep all people on the FYC */ 

	if tot_ob > 0 then cancer_ob_flag = '1'; 	/* create person-level flag for anyone who has OB visit for cancer */
	else cancer_ob_flag = '0'; 	/* set flag to 0 for people with no OB visits for cancer */ 

	if tot_ob = . then tot_ob = 0; /* replace missings caused by the merge with 0's */
	if tot_exp = . then tot_exp = 0; 
run;


/* QC: check counts of cancer_ob_flag=1 and compare to the number of rows in ob_by_pers.  
Confirm there are no missing values */

proc freq data=fyc_merged;
	tables cancer_ob_flag / missing;
run;


/* QC: There should be no records where cancer_ob_flag=0 and (tot_exp > 0 or tot_ob > 0) */

proc print data=fyc_merged;
	where cancer_ob_flag = '0' and (tot_exp > 0 or tot_ob > 0); 
run;


/*** ESTIMATION -------------------------------------------------------------------------------------------------- */ 

* Suppress graphics;

ods graphics off;

* National Totals; 

/* Estimates for the following:
	- sum of cancer_ob_flag = total people with OB visit for cancer
	- sum of tot_ob = total number of OB visits for cancer
	- sum of tot_exp = total OB expenditures for cancer */

title 'National Totals';

proc surveymeans data=fyc_merged sum; 
	stratum varstr; /* stratum */ 
	cluster varpsu; /* PSU */ 
	weight perwt21f; /* person weight */ 
	var cancer_ob_flag tot_ob tot_exp;  /* variables we want to estimate totals for */
run;

/* Proportion of people with an OB visit for cancer */
/* To convert to percentages, multiply by 100.  See exercise 1 for alternate methods to directly calculate percents */ 

title 'Proportion of people with an OB visit for cancer';

proc surveymeans data=fyc_merged mean;
	stratum varstr; 	/* stratum */
	cluster varpsu; 	/* PSU */ 
	weight perwt21f;	/* person weight */ 
	var cancer_ob_flag; /* 1/0 variable for whether someone had an OB visit for cancer */
run;


/* Average expenditures per person on OB visits for cancer among people with at least one OB visit for cancer
(cancer_ob_flag = '1') */ 

title 'Avg. exp. per person on OB visits for cancer among people with 1+ OB visit for cancer';

proc surveymeans data=fyc_merged mean;
	stratum varstr; 	/* stratum */
	cluster varpsu; 	/* PSU */ 
	weight perwt21f;	/* person weight */ 
	var tot_exp; 		/* total expenditures on OB visits for cancer*/
	domain cancer_ob_flag; 	/*subpopulation for estimates */ 
run;


title; /* cancel the title statement */ 
