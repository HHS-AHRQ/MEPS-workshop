/**********************************************************************************

PROGRAM:      EXERCISE3.SAS

DESCRIPTION:  THIS PROGRAM ILLUSTRATES HOW TO POOL MEPS DATA FILES FROM DIFFERENT YEARS
              THE EXAMPLE USED IS POPULATION AGE 26-30 WHO ARE UNINSURED BUT HAVE HIGH INCOME

	         DATA FROM 2017 AND 2018 ARE POOLED.

              VARIABLES WITH YEAR-SPECIFIC NAMES MUST BE RENAMED BEFORE COMBINING FILES.  
              IN THIS PROGRAM THE INSURANCE COVERAGE VARIABLES 'INSCOV17' AND 'INSCOV18' ARE RENAMED TO 'INSCOV'.

	         SEE HC-036 (1996-2016 POOLED ESTIMATION FILE) FOR
              INSTRUCTIONS ON POOLING AND CONSIDERATIONS FOR VARIANCE
	         ESTIMATION FOR PRE-2002 DATA.

INPUT FILE:     (1) C:\DATA\201.SAS7BDAT (2017 FULL-YEAR FILE)
	            (2) C:\DATA\H209.SAS7BDAT (2018 FULL-YEAR FILE)

**********************************************************************************/
proc datasets lib=work nolist kill; quit; /* Delete  all files in the WORK library */
OPTIONS LS=132 PS=79 NODATE VARLENCHK=NOWARN  FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;
%LET DataFolder = C:\DATA\MySDS;   /* Adjust the folder name, if needed */


/*********************************************************************************
 IMPORTANT NOTE:  Use the next 5 lines of code, only if you want SAS to create 
    separate files for SAS log and output.  Otherwise comment  out these lines.
***********************************************************************************/


%LET RootFolder= C:\Fall2020\sas_exercises\Exercise_3;
FILENAME MYLOG "&RootFolder\Exercise3_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise3_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;


libname CDATA "&DataFolder"; 
OPTIONS NODATE;
TITLE1 '2020 AHRQ MEPS DATA USERS WORKSHOP (EXERCISE3.SAS)';
TITLE2 'COMBINED MEPS DATA FROM 2017 and 2018';

PROC FORMAT;
	VALUE POVCAT 
    1 = '1 POOR/NEGATIVE'
    2 = '2 NEAR POOR'
    3 = '3 LOW INCOME'
    4 = '4 MIDDLE INCOME'
    5 = '5 HIGH INCOME'
    ;

	VALUE INSF
	1 = '1 ANY PRIVATE'
	2 = '2 PUBLIC ONLY'
	3 = '3 UNINSURED';

    VALUE AGE
    26-30='26-30'
    0-25='0-25'
    31-HIGH='31+';
VALUE  SUBPOP (max= 30)
	1 = 'AGE 26-30, UNINS_HI_INC'
	2 ='OTHERS';
run;


/* KEEP THE SPECIFIED VARIABLES WHEN READING THE INPUT DATA SET AND
   RENAME YEAR SPECIFIC VARIABLES PRIOR TO COMBINING FILES */

DATA WORK.POOL;
	SET CDATA.H201 
       (KEEP= DUPERSID INSCOV17 PERWT17F VARSTR VARPSU POVCAT17 AGELAST TOTSLF17
        RENAME=(INSCOV17=INSCOV PERWT17F=PERWT POVCAT17=POVCAT TOTSLF17=TOTSLF))

        CDATA.H209 
        (KEEP= DUPERSID INSCOV18 PERWT18F VARSTR VARPSU POVCAT18 AGELAST TOTSLF18
        RENAME=(INSCOV18=INSCOV PERWT18F=PERWT POVCAT18=POVCAT TOTSLF18=TOTSLF))
           INDSNAME=source;

	 /* Create a YEAR Variable for checking data*/
	 year=SUBSTR(source, LENGTH(source)-3);

     POOLWT = PERWT/2 ;  /* Pooled survey weight */

     /*Create a dichotomous SUBPOP variable 
	   (POPULATION WITH AGE=26-30, UNINSURED WHOLE YEAR, AND HIGH INCOME)
	 */

     IF 26 LE AGELAST LE 30 AND POVCAT=5 AND INSCOV=3 THEN SUBPOP=1;
     ELSE SUBPOP=2; 
     
RUN;


ODS HTML CLOSE; /*This will make the default HTML output no longer active,
                  and the output will not be displayed in the Results Viewer.*/
ODS LISTING ;  /*Open the listing destination */
TITLE "COMBINED MEPS DATA FROM 2017 and 2018 Consolidated Files";
PROC SORT DATA=WORK.POOL; BY YEAR SUBPOP; RUN;

/* QC purposes */
/*
PROC FREQ DATA=WORK.POOL;
    BY YEAR SUBPOP;
   	TABLES AGELAST*POVCAT*INSCOV/ LIST MISSING ;
	TABLES POVCAT*INSCOV/ LIST MISSING ;
	FORMAT AGELAST AGE. POVCAT POVCAT. INSCOV INSF.;
RUN;
PROC MEANS DATA=POOL N NMISS;
RUN;
*/

ods graphics off; /*Suppress the graphics */
TITLE2 'WEIGHTED ESTIMATE FOR OUT-OF-POCKET EXPENSES FOR PERSONS AGES 26-30, UNINSURED WHOLE YEAR, AND HIGH INCOME';

ODS GRAPHICS OFF;
ods listing; /* Open the listing destination*/
ODS EXCLUDE STATISTICS; /* Not to generate output for the overall population */
/* PROC SURVEYMEANS computes the NOBS, MEANS, STDERR, and CLM statistics by default */
PROC SURVEYMEANS DATA=WORK.POOL; 
    VAR  TOTSLF;
    STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  POOLWT;
	DOMAIN  SUBPOP("AGE 26-30, UNINS_HI_INC");
    FORMAT SUBPOP SUBPOP.;
RUN;

/* THE PROC PRINTTO null step is required to close the PROC PRINTTO,  only if used earlier.
   Otherswise. please comment out the next two lines */
PROC PRINTTO;
RUN;
 
