/**********************************************************************************
This program generates the following estimates of national health care expenses for 2021:
  	- overall expenses (national totals)
  	- proportion/percentage of people with an expense
  	- mean expense per person
  	- mean expense per person with an expense, overall and by age group (0-64 vs. 65+)
  	- median expense per person with an expense, overall and by age group (0-64 vs. 65+)

 Input file: 
	- C:\MEPS\h233.sas7bdat (2021 Full-Year Consolidated (FYC) file)
*******************************************************************************************************/

/* Define a SAS library and assign a libref to it */

libname meps "C:/MEPS";  

/**** Prepare data ****/

/* Read in the 2021 FYC SAS data file, keep only needed variables, and create new variables for estimation */

data fyc21;
  set meps.h233 (keep = dupersid totexp21 agelast varstr varpsu perwt21f);

  /* Create both numeric and character indicators for having a healthcare expense 
  (Numeric is only needed for estimating proportion as a mean)*/ 

  if totexp21 > 0 then do;  /* if total healthcare expenditures for a person is positive */
	has_exp = 1;
	has_exp_c = "Yes";
	end;
  else do;
	has_exp = 0;
	has_exp_c = "No";
	end;

	/* Create age categories for under 65 and 65+ */

	if agelast < 65 then agecat = "<65";
	else agecat = "65+";

  run;


/**** QC construction of new variables ****/

/* Look at unweighted sample sizes and check for any missing values */

proc freq data=fyc21;
	tables has_exp_c*agecat / missing;  
run;

/* Check the min and max of total expenditures for people with and without expenses
Note - min and max should BOTH be zero for people with no expenses */

proc means data=fyc21 min max;  
   class has_exp_c;
   var totexp21;  
run;

/* Check the min and max age within each age category
Note - max of agelast within the 'under 65' category should be <= 64 */

proc means data=fyc21 min max;
	class agecat;
	var agelast;  
run;


/**** Estimation ****/ 

/* Suppress the graphics - for easier viewing of estimates in ods output */

ods graphics off; 

/* Method 1 for estimating the proportion of people with an expense - taking the mean of our 0/1 numeric variable */

title 'Proportion of people with an expense in 2021 - method 1 (numeric 0/1 variable)';

proc surveymeans data=fyc21 nobs mean sum;
	stratum varstr;		/* stratum */
	cluster varpsu; 	/* PSU */
	weight perwt21f; 	/* person level weight */
	var has_exp;   		/* 1 if person has expense, 0 otherwise */  
	*class has_exp; 	/* this is only needed if you want to output proportions for BOTH categories (0 and 1) */
run;

/* Method 2 for estimating the proportion of people with an expense - using character variable */ 

title 'Proportion of people with an expense in 2021 - method 2 (2-category character variable)';

proc surveymeans data=fyc21 nobs mean sum;
	stratum varstr;		/* stratum */
	cluster varpsu;		/* PSU */
    weight perwt21f; 	/* person-level weight */
	var has_exp_c; 		/* yes/no character variable */
run;

/* Method 3 for estimating the percent of people with an expense - using surveyfreq to output PERCENT (not proportion) */ 

title 'Percentage of people with an expense, 2021 - method 3 (using surveyfreq)';

proc surveyfreq data=fyc21;
	stratum varstr;		/* stratum */
	cluster varpsu;		/* PSU */
	weight perwt21f;	/* person-level weight */
	tables has_exp_c;	/* yes/no character variable */
run;

/* Total expenditures, mean expense (overall), mean and median expense among those with an expense 
(overall and by age group) */

title 'Total, mean, and median expenses, 2021, overall and by whether person has an expense and by age group';

proc surveymeans data=fyc21 nobs mean median sum;
    stratum varstr;		/* stratum */
	cluster varpsu;		/* psu */ 
	weight  perwt21f;	/* person-level weight */ 
	var totexp21;		/* total expenditures for person */
	domain has_exp_c has_exp_c('Yes')*agecat;  /* the subpopulations/domains we want estimates for */
	ods output statistics=overall_stats domain=subpop_stats domainquantiles=subpop_median; 
					/* optional statements to output results to SAS datasets */
run;

title;  /* cancel the TITLE statements */

/* Example to show full precision of estimate where SAS has rounded or used scientific notation */ 

proc print data=subpop_stats;
	format sum 20.2 mean 20.2;
run;

