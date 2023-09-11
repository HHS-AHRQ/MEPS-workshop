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

libname meps 'C:\MEPS';

/**** Read in data files and keep only needed variables ------------------------------------------------------- */ 

/* Office-based (OB) medical visits file (record = office-based visit for a person) */

data ob20;
	set meps.h220g;
	keep dupersid evntidx obxp20x telehealthflag obdatemm;
run;

/* Conditions file (record = medical condition for a person) */

data cond20;
	set meps.h222;
	keep dupersid condidx icd10cdx ccsr1x ccsr2x ccsr3x;
run;

/* Conditions-event link file (crosswalk between conditions and medical events) */

data clnk20;
	set meps.h220if1;
run;

/* Full-year consolidated (person-level) file (record = MEPS sample member) */

data fyc20;
	set meps.h224;
	keep dupersid agelast perwt20f varpsu varstr;
run;


/**** Prepare data for estimation --------------------------------------------------------------------------------- */

/* Subset to only condition records for COVID-19 (any CCSR = "INF012") */
/* Note: you can find the CCSRs for collapsed condition categories here: 
https://github.com/HHS-AHRQ/MEPS/blob/master/Quick_Reference_Guides/meps_ccsr_conditions.csv */ 

data covid;
	set cond20;  
	where ccsr1x = 'INF012' or ccsr2x = 'INF012' or ccsr3x = 'INF012';
run; 

/* Example to show someone with 'duplicate' COVID-19 conditions with different CONDIDXs. */

proc sort data=covid nodupkey dupout=dup_covid out=temp1; /* duplicate IDs are output to dup_covid */
	by dupersid;
run;

proc print data=covid noobs;
	where dupersid = '2326578104'; /* using the first duplicate DUPERSID from dup_covid as an example */ 
run;

/* Get EVNTIDX values for COVID-19 records from CLNK file */

proc sort data=covid; /* note this file intentionally still contains duplicates! */ 
	by dupersid condidx;
run;

proc sort data=clnk20;
	by dupersid condidx;
run;

/* Note - this merge can be 1-1 or 1-many (e.g., there can be multiple events that treat the same condition */

data clnk_covid;
	merge covid (in=a) clnk20 (in=b);
	by dupersid condidx;
	if a and b; /* only keep records that are in both files */ 
run;

/* Sort data to prepare for merge between clnk_covid and ob20 */

proc sort data=clnk_covid;
	by dupersid evntidx;
run;

proc sort data=ob20;
	by dupersid evntidx;
run;


/* Because some people can have multiple CONDIDX values for COVID-19 as shown in the example above, and each of 
these different CONDIDX IDs can link to the same OB stay, it is necessary to de-duplicate on EVNTIDX before merging. 
!!Note - we do not have an issue with duplicates in this particular example, but there can be issues with duplicates
when analyzing another condition/event pair. */

proc sort data=clnk_covid nodupkey; 
	by dupersid evntidx;
run;


/* Merge to OB file and only keep records in both files.
Create dummy variable for each unique OB visit (this will be used for estimating events) */

data covid_ob;
	merge clnk_covid (in=a) ob20 (in=b);
	by dupersid evntidx;
	if a and b;
	ob_covid = 1;
run;

/* Sum number of OB stays and OB expenditures on COVID-19 within each person */

proc means data=covid_ob noprint nway sum;
	class dupersid; 	/* sum within each person */
	var ob_covid obxp20x; 
	output out=ob_by_pers (drop = _TYPE_ _FREQ_) sum=tot_ob tot_exp;
run;


/* Merge person-level totals back to FYC and create flag for whether a person has any OB visits for COVID-19 */

data fyc_merged;
	merge fyc20 (in=a) ob_by_pers;
	by dupersid;
	if a; 	/* keep all people on the FYC */ 

	if tot_ob > 0 then covid_ob_flag = '1'; 	/* create person-level flag for anyone who has OB visit for COVID-19 */
	else covid_ob_flag = '0'; 	/* set flag to 0 for people with no OB visits for COVID-19 */ 

	if tot_ob = . then tot_ob = 0; /* replace missings caused by the merge with 0's */
	if tot_exp = . then tot_exp = 0; 

	/* create age group variable */

	if agelast < 18 then agecat = "Under 18";
	else if 18 <= agelast <= 64 then agecat = "18-64";
	else if agelast ge 65 then agecat = "65+";
	else agecat = "Error!"; /* this is a QC, there should be no records with this value for agecat */ 
run;

/* QC creation of agecat and confirm there are no values of 'Error!' or missing values */ 

proc freq data=fyc_merged;
	tables agecat / missing;
run;


/* QC: check counts of covid_ob_flag=1 and compare to the number of rows in ob_by_pers.  
Confirm there are no missing values */

proc freq data=fyc_merged;
	tables covid_ob_flag / missing;
run;


/* Check sample sizes in each age group to make sure they are sufficient */ 

proc freq data=fyc_merged;
	tables covid_ob_flag*agecat;
run;


/* QC: There should be no records where covid_ob_flag=0 and (tot_exp > 0 or tot_ob > 0) */

proc print data=fyc_merged;
	where covid_ob_flag = '0' and (tot_exp > 0 or tot_ob > 0); 
run;


/*** ESTIMATION -------------------------------------------------------------------------------------------------- */ 

* Suppress graphics;

ods graphics off;

* National Totals; 

/* Estimates for the following:
	- sum of covid_ob_flag = total people with OB visit for COVID-19
	- sum of tot_ob = total number of OB visits for COVID-19
	- sum of tot_exp = total OB expenditures for COVID-19 */

proc surveymeans data=fyc_merged sum; 
	stratum varstr; /* stratum */ 
	cluster varpsu; /* PSU */ 
	weight perwt20f; /* person weight */ 
	var covid_ob_flag tot_ob tot_exp;  /* variables we want to estimate totals for */
run;

/* Proportion of people with an OB visit for COVID-19 by age group */
/* To convert to percentages, multiply by 100.  See exercise 1 for alternate methods to directly calculate percents */ 

proc surveymeans data=fyc_merged mean;
	stratum varstr; 	/* stratum */
	cluster varpsu; 	/* PSU */ 
	weight perwt20f;	 /* person weight */ 
	var covid_ob_flag;
	domain agecat;
run;


/* Average expenditures per person on OB visits for COVID-19 among people with at least one OB visit for COVID-19 
(covid_ob_flag = '1'), by age */ 

proc surveymeans data=fyc_merged mean;
	stratum varstr; 	/* stratum */
	cluster varpsu; 	/* PSU */ 
	weight perwt20f;	 /* person weight */ 
	var tot_exp; 
	domain covid_ob_flag('1')*agecat; 	/*subpop is people with any OB visits for COVID-19 by age */ 
run;


/******** Bonus! **********/ 

/* A note about telehealth:
   - telehealth questions were added to the survey in fall 2020           
   - TELEHEALTHFLAG = -15 for events reported before telehealth questions were added   
   - Recommendation: imputation or sensitivity analysis  */ 

proc freq data=covid_ob;
	tables telehealthflag*obdatemm / missing;
run;

