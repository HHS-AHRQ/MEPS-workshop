/**********************************************************************************
PROGRAM:      EXERCISE1.SAS

DESCRIPTION:  THIS PROGRAM GENERATES THE FOLLOWING ESTIMATES ON NATIONAL HEALTH CARE EXPENSES, 2017:

	           (1) OVERALL EXPENSES 
	           (2) PERCENTAGE OF PERSONS WITH AN EXPENSE
	           (3) MEAN EXPENSE PER PERSON WITH AN EXPENSE


INPUT FILE:   C:\DATA\H201.SAS7BDAT (2017 FULL-YEAR FILE)

*********************************************************************************/;
/*  IMPORTANT NOTE:  Use the next 6 lines of code, only if you want SAS to create 
    separate files for SAS log and output.  Otherwise comment  out those 6 lines */

%LET MyFolder= S:\CFACT\Shared\WORKSHOPS\2020\April2020\SAS_Exercises\Exercise_1;
OPTIONS LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;
FILENAME MYLOG "&MyFolder\Exercise1_log.TXT";
FILENAME MYPRINT "&MyFolder\Exercise1_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

proc datasets lib=work nolist kill; quit; /* delete  all files in the WORK library */

libname CDATA "C:\DATA"; 

PROC FORMAT;
  VALUE AGECAT
       .     = 'ALL AGES'
	   1 = '0-64'
	   2 = '65+';

  VALUE GTZERO
     0         = '0'
     0 <- HIGH = '>0';

  VALUE FLAG
      .         = 'No or any expense'
      0         = 'No expense'
      1         = 'Any expense';
RUN;
TITLE "MEPS FULL-YEAR CONSOLIDATED FILE, 2017";

/* READ IN DATA FROM 2017 CONSOLIDATED DATA FILE (HC-201) */
DATA WORK.PUF201;
  SET CDATA.H201 (KEEP = TOTEXP17 AGELAST   VARSTR  VARPSU  PERWT17F
                  RENAME = (TOTEXP17 = totexp));

  /* CREATE FLAG (1/0) VARIABLES FOR PERSONS WITH AN EXPENSE */  
  X_ANYSVCE=0;
  IF totexp > 0 THEN X_ANYSVCE=1;

  /* CREATE A CATEGORICAL AGE VARIABLE */

  IF 0 LE AGELAST   LE 64 THEN AGECAT=1 ;
  ELSE IF   AGELAST  > 64 THEN AGECAT=2 ;
RUN;
ODS HTML CLOSE; /* This will make the default HTML output no longer active,
                  and the output will not be displayed in the Results Viewer.*/
PROC FREQ DATA=PUF201;
   TABLES X_ANYSVCE*totexp
          AGELAST*AGECAT
          /LIST MISSING;
   FORMAT totexp        	gtzero.      
          AGECAT        agecat.
     ;
RUN;
 
ods graphics off; /*Suppress the graphics */
ods listing; /* Open the listing destination*/
TITLE2 'PERCENTAGE OF PERSONS WITH AN EXPENSE & OVERALL EXPENSES';
PROC SURVEYMEANS DATA=WORK.PUF201 NOBS SUMWGT MEAN STDERR SUM ;
    VAR  X_ANYSVCE totexp ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT17F;
RUN;


TITLE2 'MEAN EXPENSE PER PERSON WITH AN EXPENSE, FOR OVERALL, AGE 0-64, AND AGE 65+';
ODS EXCLUDE STATISTICS; /* Not to generate output for the overall population */
PROC SURVEYMEANS DATA= WORK.PUF201 NOBS SUMWGT MEAN STDERR SUM ;
    VAR  totexp;
	STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  PERWT17F ;	
	DOMAIN X_ANYSVCE('1')  X_ANYSVCE('1')*AGECAT ;
	FORMAT  AGECAT agecat.;
RUN;

/* THE PROC PRINTTO null step is required to close the PROC PRINTTO, 
 only if used earlier */
PROC PRINTTO;
RUN;
