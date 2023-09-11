
/******************************************************************************************

This program pools 2018, 2019, and 2020 MEPS FYC files and calculates annual averages for: 
  - proportion of people diagnosed with bladder cancer
  - average expenditures and average amount paid out of pocket per person by bladder cancer diagnosis status 
  - standard errors by specifying common variance structure

 Input files:
  - C:\MEPS\h209.sas7bdat (2018 Full-Year Consolidated (FYC) file)
  - C:\MEPS\h216.sas7bdat (2019 Full-Year Consolidated (FYC) file)
  - C:\MEPS\h224.sas7bdat (2020 Full-Year Consolidated (FYC) file)
  - C:\MEPS\h36u21.sas7bdat (1996-2021 Pooled Linkage File for Common Variance Structure)

When pooling data years before and after 2002 or 2019, the Pooled Linkage File (h36u21) must be used for correct 
variance estimation.  

!!Note: The name of the Pooled Linkage File changes with each new year of data (e.g. 'h36u22' once 2022 data is added).

**********************************************************************/

/* Set libname for folder with MEPS data */

libname meps "C:/MEPS";

/* Read in 2018-2020 FYC data files, rename year-specific variables to common names across years, create year variable,
and keep only needed variables */ 

/* 2018 */ 
data fyc18;
	set meps.h209;
	year = 2018;
	totexp = totexp18;
	totslf = totslf18;
	perwt = perwt18f;
	keep year dupersid panel perwt cancerdx cabladdr totexp totslf;
run;

/* 2019 */
data fyc19;
	set meps.h216;
	year = 2019;
	totexp = totexp19;
	totslf = totslf19;
	perwt = perwt19f;
	keep year dupersid panel perwt cancerdx cabladdr totexp totslf;
run;

/* 2020 */
data fyc20;
	set meps.h224;
	year = 2020;
	totexp = totexp20;
	totslf = totslf20;
	perwt = perwt20f;
	keep year dupersid panel perwt cancerdx cabladdr totexp totslf;
run;

/* Look at the variable cabladdr and cancerdx for one year to understand skip pattern */
/* From the documentation: 
		 - Questions about cancer were asked only of persons aged 18 or older 
		 - CANCERDX asks whether person ever diagnosed with cancer 
	 	 - Only if YES to CANCERDX, then asked what type (CABLADDR, CABLOOD, CABREAST...) */

proc freq data=fyc20;
	tables cabladdr*cancerdx / missing;
run;


/* Concatenate (stack) 2018, 2019 and 2020 full year consolidated files, create pooled weight, and create variable
for bladder cancer diagnosis */

data meps_pooled;
	set fyc18 fyc19 fyc20;

 	/* Create pooled weight by dividing by the number of years being pooled */

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


/* Read in the Pooled Linkage Variance file.

 !! Note: DUPERSID changed from 8 characters to 10 characters starting in panel 22.  If using panels 1-21, 
 you will need to add the panel number to DUPERSID to create comparable DUPERSID across panels. */

data plf;				 
	set meps.h36u21; 
	where panel ge 22; 	/* only need panels 22 + for 2018-2020 */
	keep dupersid panel stra9621 psu9621;
run;

/* Sort the pooled linkage file for merging */ 

proc sort data= plf;
 	by dupersid panel;
 run;

/* Sort the pooled 2018-2020 meps file for merging */

proc sort data=meps_pooled;
	by dupersid panel;
run;

/* Merge the pooled 2018-2020 meps file with the PLF file to get common variance structure across years*/
/* Note: Because DUPERSID are recycled, you need to merge by both DUPERSID and PANEL */ 

data meps_pooled_plf;
 	merge meps_pooled (in=a) plf;
  	by dupersid panel;
 	if a; /* keep only records in 2018-2020 pooled MEPS file - note that Panel 22 includes 2017 and Panel 26 includes 2021 */
run;

/* QC merge - results should be the same for each output below*/

proc freq data=meps_pooled;
	tables panel;
run;

proc freq data=meps_pooled_plf;
	tables panel;
run;

/* QC - check for missings in merged on pooled variance estimation variables */

proc print data=meps_pooled_plf;
	where psu9621 = . or stra9621 = .;
run;

/* Suppress the graphics for easier viewing */ 

ods graphics off; 

/* Proportion of people diagnosed with bladder cancer - ANNUAL AVERAGE from 2018-2020 */

title 'Proportion of people diagnosed with bladder cancer, 2018-2020 annual average';

proc surveymeans data=meps_pooled_plf nobs mean sum;
    stratum stra9621;	/* common variance stratum from PLF */
	cluster psu9621; 	/* common variance PSU from PLF */ 
    weight poolwt; 		/* pooled weight */
	var bladder_cancer; /* 1/0 variable for whether person has bladder cancer, will exclude missings */ 
run;

/* Average expenditures and out of pocket payments per person by bladder cancer status,
ANNUAL AVERAGES from 2018-2020 */

title 'Average expenditures and out of pocket per person with and without bladder cancer, 2018-2020 annual average';

proc surveymeans data=meps_pooled_plf nobs mean;
    stratum stra9621; 		/* common variance stratum from PLF */
	cluster psu9621; 		/* common variance PSU from PLF */
    weight poolwt;			/* pooled weight */
	var totexp totslf;		/* total expenditures and OOP expenditures */
	domain bladder_cancer;	/* subpops are people who have and don't have bladder cancer, with missings excluded */
run;

title;  /* cancel the TITLE statements */



