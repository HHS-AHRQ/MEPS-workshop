/**********************************************************************************
PROGRAM:      EXERCISE1.SAS

DESCRIPTION:  THIS PROGRAM GENERATES THE FOLLOWING ESTIMATES ON NATIONAL HEALTH CARE EXPENSES, 2018:

	           (1) OVERALL EXPENSES 
	           (2) PERCENTAGE OF PERSONS WITH AN EXPENSE
	           (3) MEAN EXPENSE PER PERSON WITH AN EXPENSE


INPUT FILE:   C:\DATA\MySDS\H209.SAS7BDAT (2018 FULL-YEAR FILE)
*/


proc datasets lib=work nolist kill; quit; /* Delete  all files in the WORK library */
OPTIONS nocenter LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;

%LET DataFolder = C:\DATA\MySDS;  /* Adjust the folder name, if needed */

/*********************************************************************************
 IMPORTANT NOTE:  Use the next 5 lines of code, only if you want SAS to create 
    separate files for SAS log and output.  Otherwise comment  out these lines.
***********************************************************************************/

%LET RootFolder= C:\Fall2020\sas_exercises\Exercise_1;
FILENAME MYLOG "&RootFolder\Exercise1_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise1_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

PROC FORMAT;
  VALUE AGECAT
       low-64 = '0-64'
	   65-high = '65+';

   VALUE totexp18_cate
      0         = 'No Expense'
      Other     = 'Any Expense';
RUN;
TITLE "MEPS FULL-YEAR CONSOLIDATED FILE, 2018";


libname CDATA "&DataFolder"; 
/* READ IN DATA FROM 2018 CONSOLIDATED DATA FILE (HC-201) */
DATA WORK.PUF209;
  SET CDATA.H209 (KEEP = TOTEXP18 AGELAST   VARSTR  VARPSU  PERWT18F panel);
     TOTEXP18_X = TOTEXP18;
	 AGELAST_X = AGELAST;
  RUN;
ODS HTML CLOSE; /* This will make the default HTML output no longer active,
                  and the output will not be displayed in the Results Viewer.*/

/* For QC purposes */
/*
PROC FREQ DATA=PUF209;
   TABLES TOTEXP18_X AGELAST PANEL
          /LIST MISSING;
   FORMAT TOTEXP18_X totexp18_cate.      
          AGELAST  AGECAT. ;
RUN;
*/
ods graphics off; /*Suppress the graphics */
ods listing; /* Open the listing destination*/
TITLE2 'PERCENTAGE OF PERSONS WITH AN EXPENSE and OVERALL HEALTH CARE EXPENSES, 2018';
PROC SURVEYMEANS DATA=WORK.PUF209  ;
    VAR  TOTEXP18_X TOTEXP18 ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	class TOTEXP18_X;
	FORMAT TOTEXP18_X TOTEXP18_CATE. ;
RUN;

TITLE2 'MEAN EXPENSE PER PERSON WITH AN EXPENSE, OVEALL and FOR AGES 0-64, AND 65+, 2018';
ODS SELECT DOMAIN ; /* Generate output for the DOMAIN only*/
PROC SURVEYMEANS DATA= WORK.PUF209 NOBS SUMWGT MEAN STDERR SUM ;
    VAR  totexp18;
	STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  PERWT18F ;	
	DOMAIN TOTEXP18_X('Any Expense')  TOTEXP18_X('Any Expense')*AGELAST;
	FORMAT TOTEXP18_X TOTEXP18_CATE. AGELAST agecat.;
RUN;

/* THE PROC PRINTTO null step is required to close the PROC PRINTTO,  only if used earlier.
   Otherswise. please comment out the next two lines */
PROC PRINTTO;
RUN;
