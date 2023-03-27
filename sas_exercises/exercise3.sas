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

libname meps 'C:\MEPS';

/**** Read in data files and keep only needed variables ------------------------------------------------------- */ 

/* PMED file (record = rx fill or refill for a person) */

data pmed20;
	set meps.h220a;
	evntidx = linkidx; /* rename LINKIDX to EVNTIDX for merging to conditions */ 
	keep dupersid drugidx rxrecidx evntidx rxdrgnam rxxp20x;
run;

/* Conditions file (record = medical condition for a person) */

data cond20;
	set meps.h222;
	keep dupersid condidx icd10cdx ccsr1x ccsr2x ccsr3x;
run;

/* Conditions-event link file (crosswalk between conditions and medical events, including PMEDs) */

data clnk20;
	set meps.h220if1;
run;

/* Full-year consolidated (person-level) file (record = MEPS sample member) */

data fyc20;
	set meps.h224;
	keep dupersid sex choldx perwt20f varpsu varstr;
run;


/**** Prepare data for estimation --------------------------------------------------------------------------------- */

/* Subset to only condition records for hyperlipidemia (any CCSR = "END010") */
/* Note: you can find the CCSRs for collapsed condition categories here: 
https://github.com/HHS-AHRQ/MEPS/blob/master/Quick_Reference_Guides/meps_ccsr_conditions.csv */ 

data hl;
	set cond20;  
	where ccsr1x = 'END010' or ccsr2x = 'END010' or ccsr3x = 'END010';
run; 

/* Example to show someone with 'duplicate' hyperlipidemia conditions with different CONDIDXs.  This usually happens 
when the collapsed 3-digit ICD10s are the same but the fully-specified ICD10s are different (e.g., one person has 
different condition records for both E78.1 and E78.5, which both map to END010 collapse to E78 on the PUF). */

proc sort data=hl nodupkey dupout=dup_hl out=temp1; /* duplicate IDs are output to dup_hl */
	by dupersid;
run;

proc print data=hl noobs;
	where dupersid = '2320134102'; /* using the first duplicate DUPERSID from dup_hl as an example */ 
run;

/* Get EVNTIDX values for hyperlipidemia records from CLNK file */

proc sort data=hl;
	by dupersid condidx;
run;

proc sort data=clnk20;
	by dupersid condidx;
run;

/* Note - this merge can be 1-1 or 1-many */

data clnk_hl;
	merge hl (in=A) clnk20 (in=B);
	by dupersid condidx;
	if A and B; /* only keep records that are in both files */ 
run;

/* Sort data to prepare for merge between clnk_hl and pmed20 */

proc sort data=clnk_hl;
	by dupersid evntidx;
run;

proc sort data=pmed20;
	by dupersid evntidx;
run;

/* !!Note: Our 'duplicate' hyperlipidemia records have created a many-to-many merge between clnk_hl and pmed20, but the
SAS merge statement does not do 'full' or 'traditional' many to many merges! */ 

/* Example - for EVNTIDX = '2320134102003703' there are 2 records on clnk_hl and 3 records on pmed20 */

proc print data=clnk_hl noobs;
	where evntidx='2320134102003703'; 
run;

proc print data=pmed20 noobs;
	where evntidx='2320134102003703'; 
run;

/* A 'full' many-to-many merge would create 2 x 3 = 6 combinations (rows) in the output, but let's look at what SAS
merge does for this one example case */

data clnk_example;
	set clnk_hl;
	where evntidx='2320134102003703'; 
run;

data pmed_example;
	set pmed20;
	where evntidx='2320134102003703'; 
run;

data merge_example;
	merge clnk_example (in=a) pmed_example (in=b);
	by evntidx;
	if a and b;
run;

/* We can see in the above example that we only get 3 records using the merge statement instead of 6. 
SAS merge statement only keeps the maximum number of records (rows) from either file in the merge.  */ 

/* Get PMED fills linked to hyperlipidemia.
Using proc sql to factilitate 'full' many-to-many merge which regular SAS merge statements don't do */

proc sql;
 	create table hl_merged as
 	select a.*, b.*
 	from clnk_hl a inner join pmed20 b
 	on a.DUPERSID=b.DUPERSID and
 	a.EVNTIDX=b.EVNTIDX;
 quit;
 run; 

/* Because some people can have multiple CONDIDX values for hyperlipidemia as shown in the example above, and each of 
these different CONDIDX IDs can link to the same rx fills, it is necessary to de-duplicate on the unique fill identifier
RXRECIDX within a person who has hyperlipidemia.

For example, the same drug/fill can link to both E78.1 and E78.5, but these are both hyperlipidemia.    

An example below illustrating the above issue.  Note that there are 'duplicate' RXRECIDX (fill IDs) repeated across two 
different CONDIDX values for the same person because this person has 'duplicate' hyperlipidemia records and some fills 
are linked to both CONDIDX values for hyperlipidemia. */ 

proc sort data=hl_merged nodupkey dupout=dup_hl_fills out=temp2; /* duplicate fill records are output to dup_hl_fills */
	by dupersid rxrecidx;
run;

proc print data=hl_merged noobs;
	where dupersid = '2320134102'; /* using first duplicate record as an example */ 
run;

/* De-duplicate unique fills within a person who has hyperlipidemia */

proc sort data=hl_merged nodupkey out=hl_dedup;
	by dupersid rxrecidx;
run;

/* Revisit 'duplicate' fill example to see effects of de-duplicating */

proc print data=hl_dedup noobs;
	where dupersid = '2320134102'; /* same example case as above */ 
run;

/* QC: Look at top PMEDs for hyperlipidemia to see if they make sense */

proc freq data=hl_dedup order=freq;
	tables RXDRGNAM / nocum maxlevels=10;
run;

/* Create dummy variable for each unique fill (this will be summed within each person to get total fills per person) */

data hl_dedup;
	set hl_dedup;
	hl_fill = 1;
run;

/* Sum number of fills, number of drugs, and expenditures linked to hyperlipidemia within each person */

proc means data=hl_dedup noprint nway sum;
	class dupersid; 	/* sum within each person */
	var hl_fill rxxp20x; 
	output out=drugs_by_pers (drop = _TYPE_ _FREQ_) sum=n_hl_fills hl_drug_exp;
run;

/* Revisiting 'duplicate' example at the person-level to show that fills were only counted once */

proc print data=drugs_by_pers noobs;
	where dupersid = '2320134102'; 
run;

/* Merge person-level totals back to FYC and create flag for whether a person has any pmed fills for hyperlipidemia */

data fyc_hl;
	merge fyc20 (in=A) drugs_by_pers;
	by dupersid;
	if A; 	/* keep all people on the FYC */ 

	if n_hl_fills > 0 then hl_pmed_flag = '1'; 	/* create flag for anyone who has rx fills for HL */
	else hl_pmed_flag = '0'; 	/* set flag to 0 for people with no rx fills for HL */ 

	if n_hl_fills = . then n_hl_fills = 0; /* replace missings caused by the merge with 0's */
	if hl_drug_exp = . then hl_drug_exp = 0; 
run;

/* QC: check counts of hl_pmed_flag=1 and compare to the number of rows in drugs_by_pers.  
Confirm there are no missing values */

proc freq data=fyc_hl;
	tables hl_pmed_flag;
run;

/* QC: There should be no records where hl_pmed_flag=0 and (hl_drug_exp > 0 or n_hl_fills > 0) */

proc print data=fyc_hl;
	where hl_pmed_flag = '0' and (hl_drug_exp > 0 or n_hl_fills > 0); 
run;

/*** ESTIMATION -------------------------------------------------------------------------------------------------- */ 

* Suppress graphics;

 ods graphics off;

* National Totals; 

/* Estimates for the following:
	- sum of hl_pmed_flag = total people with any rx fills for HL
	- sum of n_hl_fills = total number of rx fills for HL
	- sum of hl_drug_exp = total rx expenditures for HL */

proc surveymeans data=fyc_hl sum; 
	stratum varstr; /* stratum */ 
	cluster varpsu; /* PSU */ 
	weight perwt20f; /* person weight */ 
	var hl_pmed_flag n_hl_fills hl_drug_exp;  /* variables we want to estimate totals for */
run;


/* Per-person averages for people with at least one PMED fill for hyperlipidemia (hl_pmed_flag = 1) 
	-mean of hl_drug_exp = avg expenditures per person on rx for HL 
	-mean of n_hl_fills = avg number of fills per person on rx for HL */

proc surveymeans data=fyc_hl mean;
	stratum varstr; 	/* stratum */
	cluster varpsu; 	/* PSU */ 
	weight perwt20f;	 /* person weight */ 
	domain hl_pmed_flag('1'); 	/*subpop is people with any rx fills for HL */ 
	var hl_drug_exp n_hl_fills; 
run;
