
/******************************************************************************************

This program pools 2019, 2020, and 2021 MEPS FYC files and calculates annual averages for: 
  - proportion of people diagnosed with bladder cancer
  - average expenditures and average amount paid out of pocket per person by bladder cancer diagnosis status 
  - standard errors for annual averages

 Input files:
  - C:\MEPS\h216.sas7bdat (2019 Full-Year Consolidated (FYC) file)
  - C:\MEPS\h224.sas7bdat (2020 Full-Year Consolidated (FYC) file)
  - C:\MEPS\h233.sas7bdat (2021 Full-Year Consolidated (FYC) file)

!!Note: When pooling data years before and after 2002 or 2019, the Pooled Linkage File (h36u22) must be used for correct 
variance estimation.  The name of the Pooled Linkage File changes with each new year of data (e.g. 'h36u23' once 2023 
data is added).  The Pooled Linkage File is NOT needed for this example because all data years are 2019 and after.

The pooled linkage file and documentation is available here: 
https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-036

**********************************************************************/

/* Set libname for folder with MEPS data */

libname meps "C:/MEPS";


/********** Read in data files **********/

/* Read in 2019, 2020, and 2021 FYC data files, rename year-specific variables to common names across years, 
create year variable, and keep only needed variables */ 

/* 2019 */
data fyc19;
	set meps.h216;
	year = 2019;
	totexp = totexp19;
	totslf = totslf19;
	perwt = perwt19f;
	keep year dupersid panel cancerdx cabladdr totexp totslf perwt varstr varpsu;
run;

/* 2020 */
data fyc20;
	set meps.h224;
	year = 2020;
	totexp = totexp20;
	totslf = totslf20;
	perwt = perwt20f;
	keep year dupersid panel cancerdx cabladdr totexp totslf perwt varstr varpsu;
run;

/* 2021 */
data fyc21;
	set meps.h233;
	year = 2021;
	totexp = totexp21;
	totslf = totslf21;
	perwt = perwt21f;
	keep year dupersid panel cancerdx cabladdr totexp totslf perwt varstr varpsu;
run;


/********** Prepare the data **********/

/* Look at the variable cabladdr and cancerdx for one year to understand skip pattern */
/* From the documentation: 
		 - Questions about cancer were asked only of persons aged 18 or older 
		 - CANCERDX asks whether person was ever diagnosed with cancer 
	 	 - Only if YES to CANCERDX, then asked what type (CABLADDR, CABLOOD, CABREAST...) */

proc freq data=fyc21;
	tables cabladdr*cancerdx / missing;
run;

/* Concatenate (stack) 2019, 2020, and 2021 full year consolidated files, create pooled weight, and create variable
for bladder cancer diagnosis */

data meps_pooled;
	set fyc19 fyc20 fyc21;

 	/* Create pooled weight by dividing by the number of years being pooled.
		This will produce an annual average across the number of years being pooled as your estimate. */

	 poolwt = perwt/3;

  	/* Create a new variable: bladder_cancer */
	
 	if cabladdr = 1 then bladder_cancer = 1; /* has bladder cancer */
  	else if cabladdr = 2 or cancerdx = 2 then bladder_cancer = 0; /* need to check both CABLADDR *AND* CANCERDX for no*/
  	else if cabladdr < 0 then bladder_cancer = .; /* negative codes in MEPS are for missing and inapplicable */
 run;

 /* QC construction of variables */

proc freq data=meps_pooled;
	tables bladder_cancer bladder_cancer*cancerdx / missing;
run;


/********** Estimation **********/

/* Suppress the graphics for easier viewing */ 

ods graphics off; 

/* Proportion of people diagnosed with bladder cancer - ANNUAL AVERAGE from 2019-2021 */

title 'Proportion of people diagnosed with bladder cancer, 2019-2021 annual average';

proc surveymeans data=meps_pooled nobs mean;
    stratum varstr;		/* stratum from FYCs*/
	cluster varpsu; 	/* PSU from FYCs */ 
    weight poolwt; 		/* pooled weight we created */
	var bladder_cancer; /* 1/0 variable for whether person has bladder cancer */ 
run;

/* Average expenditures and out of pocket payments per person by bladder cancer status,
ANNUAL AVERAGES from 2019-2021 */

title 'Average expenditures and out of pocket per person with and without bladder cancer, 2019-2021 annual average';

proc surveymeans data=meps_pooled nobs mean;
    stratum varstr; 		/* stratum from FYCs */
	cluster varpsu; 		/* PSU from FYCs */
    weight poolwt;			/* pooled weight we created */
	var totexp totslf;		/* total expenditures and OOP expenditures */
	domain bladder_cancer;	/* subpops are people who have and don't have bladder cancer */
run;

title;  /* cancel the TITLE statements */



