/**********************************************************************************
PROGRAM:      EXERCISE1.SAS

DESCRIPTION:  THIS PROGRAM GENERATES THE FOLLOWING ESTIMATES ON NATIONAL HEALTH CARE EXPENSES, 2017:

	           (1) OVERALL EXPENSES 
	           (2) PERCENTAGE OF PERSONS WITH AN EXPENSE
	           (3) MEAN EXPENSE PER PERSON WITH AN EXPENSE

INPUT FILE:   C:\DATA\H201.SAS7BDAT (2017 FULL-YEAR FILE)
*********************************************************************************/;
/* IMPORTANT NOTES: Use the next 6 lines of code, if you want to specify an alternative destination for SAS log and 
SAS procedure output.*/

%LET MyFolder= S:\CFACT\Shared\WORKSHOPS\2019\Fall2019\SAS\Exercise_1;
OPTIONS LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;
FILENAME MYLOG "&MyFolder\Exercise1_log.TXT";
FILENAME MYPRINT "&MyFolder\Exercise1_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

proc datasets lib=work nolist kill; quit; /* delete  all files in the WORK library */

libname CDATA "C:\DATA"; 

PROC FORMAT;
  VALUE AGEF
     .      = 'ALL AGES'
     0-  64 = '0-64'
     65-HIGH = '65+';

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

TITLE1 '2019 AHRQ MEPS DATA USERS WORKSHOP (EXERCISE1.SAS)';
TITLE2 "NATIONAL HEALTH CARE EXPENSES, 2017";

/* READ IN DATA FROM 2017 CONSOLIDATED DATA FILE (HC-201) */
DATA WORK.PUF201;
  SET CDATA.h201 (KEEP = TOTEXP17 AGELAST   VARSTR  VARPSU  PERWT17F
                  RENAME = (TOTEXP17 = TOTAL));

  /* CREATE FLAG (1/0) VARIABLES FOR PERSONS WITH AN EXPENSE */  
  X_ANYSVCE=0;
  IF TOTAL > 0 THEN X_ANYSVCE=1;

  /* CREATE A SUMMARY VARIABLE FROM END OF YEAR, 42, AND 31 VARIABLES*/

  IF 0 LE AGELAST   LE 64 THEN AGECAT=1 ;
  ELSE IF   AGELAST  > 64 THEN AGECAT=2 ;
RUN;

TITLE3 "Supporting crosstabs for the flag variables";
PROC FREQ DATA=PUF201;
   TABLES X_ANYSVCE*TOTAL
          AGECAT*AGELAST
          /LIST MISSING;
   FORMAT TOTAL        	gtzero.      
          AGECAT        agef.
     ;
RUN;
ods graphics off;
TITLE3 'PERCENTAGE OF PERSONS WITH AN EXPENSE & OVERALL EXPENSES';
PROC SURVEYMEANS DATA=WORK.PUF201 MEAN NOBS SUMWGT STDERR SUM STD;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT17F;
	VAR  X_ANYSVCE TOTAL ;
	ods output Statistics=work.Overall_results;
RUN;

ods listing ; 
TITLE3 'PERCENTAGE OF PERSONS WITH AN EXPENSE';
proc print data=work.Overall_results (firstobs=1 obs=1) noobs split='*'; 
var  N  SumWgt  mean StdErr  Sum stddev;
 label SumWgt = 'Population*Size'
       mean = 'Proportion'
       StdErr = 'SE of Proportion'
       Sum = 'Persons*with Any*Expense '
       Stddev = 'SE of*Number*Persons*with*Any Expense';
       format N SumWgt Comma12. mean 7.2 stderr 7.5
              sum Stddev comma19.;
run;

TITLE3 'OVERALL EXPENSES';
proc print data=work.Overall_results (firstobs=2) noobs split='*'; 
var  N  SumWgt  mean StdErr  Sum stddev;
 label SumWgt = 'Population*Size'
       mean = 'Mean($)'
       StdErr = 'SE of Mean($)'
       Sum = 'Total*Expense ($)'
       Stddev = 'SE of*Total Expense($)';
       format N SumWgt Comma12. mean stderr comma9. 
              sum Stddev comma19.;
run;

ods select summary domain; 
TITLE3 'MEAN EXPENSE PER PERSON WITH AN EXPENSE, FOR OVERALL, AGE 0-64, AND AGE 65+';
PROC SURVEYMEANS DATA= WORK.PUF201 MEAN NOBS SUMWGT STDERR SUM STD;
	STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  PERWT17F ;	
	VAR  TOTAL;
	DOMAIN X_ANYSVCE('1')  X_ANYSVCE('1')*AGECAT ;
	FORMAT  AGECAT agecat.;
	ods output domain= work.domain_results;
RUN;


proc print data= work.domain_results noobs split='*';
 var AGECAT  N  SumWgt  mean StdErr  Sum stddev;
 label AGECAT = 'Age Group'
       SumWgt = 'Population*Size'
       mean = 'Mean($)'
       StdErr = 'SE of Mean($)'
       Sum = 'Total*Expense ($)'
       Stddev = 'SE of*Total Expense($)';
       format AGECAT AGECAT. N SumWgt Comma12. mean stderr comma9. 
              sum Stddev comma19.;
run;

/* THE PROC PRINTTO null step is required to close the PROC PRINTTO */
PROC PRINTTO;
RUN;
