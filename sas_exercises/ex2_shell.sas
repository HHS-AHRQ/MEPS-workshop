
/******************************************************************************************

This program pools 2018, 2019, and 2020 MEPS FYC files and calculates annual averages for: 
  - proportion of people diagnosed with bladder cancer
  - average expenditures and average amount paid out of pocket per person by bladder cancer diagnosis status 
  - standard errors by specifying common variance structure

 Input files:
  - C:\MEPS\h209.sas7bdat (2018 Full-Year Consolidated (FYC) file)
  - C:\MEPS\h216.sas7bdat (2019 Full-Year Consolidated (FYC) file)
  - C:\MEPS\h224.sas7bdat (2020 Full-Year Consolidated (FYC) file)
  - C:\MEPS\h36u20.sas7bdat (1996-2020 Pooled Linkage File for Common Variance Structure)

When pooling data years before and after 2002 or 2019, the Pooled Linkage File (h36u20) must be used for correct 
variance estimation.  

!!Note: The name of the Pooled Linkage File changes with each new year of data (e.g. 'h36u21' once 2021 data is added).

**********************************************************************/

/* Set libname for folder with MEPS data */



/* Read in 2018-2020 FYC data files, rename year-specific variables to common names across years, create year variable,
and keep only needed variables */ 

/* 2018 */ 





/* 2019 */





/* 2020 */





/* Look at the variable cabladdr and cancerdx for one year to understand skip pattern */
/* From the documentation: 
		 - Questions about cancer were asked only of persons aged 18 or older. 
		 - CANCERDX asks whether person ever diagnosed with cancer 
	 	 - Only if YES to CANCERDX, then asked what type (CABLADDR, CABLOOD, CABREAST...) */




/* Concatenate (stack) 2018, 2019 and 2020 full year consolidated files, create pooled weight, and create variable
for bladder cancer diagnosis */






 /* QC construction of variables */





/* Read in the Pooled Linkage Variance file.

 !! Note: DUPERSID changed from 8 characters to 10 characters starting in panel 22.  If using panels 1-21, 
 you will need to add the panel number to DUPERSID to create comparable DUPERSID across panels. */





/* Sort the pooled linkage file for merging */ 




 /* Sort the pooled 2018-2020 meps file for merging */




/* Merge the pooled 2018-2020 meps file with the PLF file to get common variance structure across years*/
/* Note: Because DUPERSID are recycled, you need to merge by both DUPERSID and PANEL */ 





/* QC merge - results should be the same for each output below*/





/* Suppress the graphics for easier viewing */ 



/* Proportion of people diagnosed with bladder cancer - ANNUAL AVERAGE from 2018-2020 */

title 'Proportion of people diagnosed with bladder cancer, 2018-2020 annual average';






/* Average expenditures and out of pocket payments per person by bladder cancer status,
ANNUAL AVERAGES from 2018-2020 */

title 'Average expenditures and out of pocket per person with and without bladder cancer, 2018-2020 annual average';






title;  /* cancel the TITLE statements */



