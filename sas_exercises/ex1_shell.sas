/**********************************************************************************
This program generates the following estimates of national health care expenses for 2020:
  	- overall expenses (national totals)
  	- proportion/percentage of people with an expense
  	- mean expense per person
  	- mean expense per person with an expense, overall and by age group (0-64 vs. 65+)
  	- median expense per person with an expense, overall and by age group (0-64 vs. 65+)

 Input file: 
	- C:\MEPS\h224.sas7bdat (2020 Full-Year Consolidated (FYC) file)
*******************************************************************************************************/

/* Define a SAS library and assign a libref to it */



/**** Prepare data ****/

/* Read in the 2020 FYC SAS data file, keep only needed variables, and create new variables for estimation */






/**** QC construction of new variables ****/

/* Look at unweighted sample sizes and check for any missing values */




/* Check the min and max of total expenditures for people with and without expenses
Note - min and max should BOTH be zero for people with no expenses */




/* Check the min and max age within each age category
Note - max of agelast within the 'under 65' category should be <= 64 */




/**** Estimation ****/ 

/* Suppress the graphics - for easier viewing of estimates in ods output */



/* Method 1 for estimating the proportion of people with an expense - taking the mean of our 0/1 numeric variable */

title 'Proportion of people with an expense in 2020 - method 1 (numeric 0/1 variable)';




/* Method 2 for estimating the proportion of people with an expense - using character variable */ 

title 'Proportion of people with an expense in 2020 - method 2 (2-category character variable)';





/* Method 3 for estimating the percent of people with an expense - using surveyfreq to output PERCENT (not proportion) */ 

title 'Percentage of people with an expense, 2020 - method 3 (using surveyfreq)';





/* Total expenditures, mean expense (overall), and mean and median expense among those with an expense 
(overall and by age group) */

title 'Mean and median expenses, overall and by whether person has an expense and by age group';






title;  /* cancel the TITLE statements */






