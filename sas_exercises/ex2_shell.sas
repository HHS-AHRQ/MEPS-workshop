
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
data is added).  The Pooled Linkage File is NOT needed for this example because all data years are after 2019.

The pooled linkage file and documentation is available here: 
https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-036

**********************************************************************/

/* Set libname for folder with MEPS data */




/********** Read in data files **********/

/* Read in 2019, 2020, and 2021 FYC data files, rename year-specific variables to common names across years, 
create year variable, and keep only needed variables */ 

/* 2019 */




/* 2020 */




/* 2021 */





/********** Prepare the data **********/

/* Look at the variable cabladdr and cancerdx for one year to understand skip pattern */
/* From the documentation: 
		 - Questions about cancer were asked only of persons aged 18 or older 
		 - CANCERDX asks whether person was ever diagnosed with cancer 
	 	 - Only if YES to CANCERDX, then asked what type (CABLADDR, CABLOOD, CABREAST...) */





/* Concatenate (stack) 2019, 2020, and 2021 full year consolidated files, create pooled weight, and create variable
for bladder cancer diagnosis */






 /* QC construction of variables */





/********** Estimation **********/

/* Suppress the graphics for easier viewing */ 



/* Proportion of people diagnosed with bladder cancer - ANNUAL AVERAGE from 2019-2021 */

title 'Proportion of people diagnosed with bladder cancer, 2019-2021 annual average';





/* Average expenditures and out of pocket payments per person by bladder cancer status,
ANNUAL AVERAGES from 2019-2021 */

title 'Average expenditures and out of pocket per person with and without bladder cancer, 2019-2021 annual average';






title;  /* cancel the TITLE statements */



