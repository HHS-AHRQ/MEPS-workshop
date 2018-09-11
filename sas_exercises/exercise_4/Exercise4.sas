/**********************************************************************************

PROGRAM:      C:\MEPS\SAS\PROG\EXERCISE4.SAS

DESCRIPTION:  THIS PROGRAM ILLUSTRATES HOW TO POOL MEPS LONGITUDINAL DATA FILES FROM DIFFERENT PANELS
              THE EXAMPLE USED IS PANELS 17-19 POPULATION AGE 26-30 WHO ARE UNINSURED BUT HAVE HIGH INCOME IN THE FIRST YEAR

	            DATA FROM PANELS 17, 18, AND 19 ARE POOLED.

INPUT FILE:     (1) C:\MEPS\SAS\DATA\H183.SAS7BDAT (PANEL 19 LONGITUDINAL FILE)
	            (2) C:\MEPS\SAS\DATA\H172.SAS7BDAT (PANEL 18 LONGITUDINAL FILE)
	            (3) C:\MEPS\SAS\DATA\H164.SAS7BDAT (PANEL 17 LONGITUDINAL FILE)

*********************************************************************************/;
/* IMPORTANT NOTES: Use the next 6 lines of code, if you want to specify an alternative destination for SAS log and 
SAS procedure output.*/

%LET MyFolder= U:\Workshop_Fall2018_PradipM\Exercise_4;
OPTIONS LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;
FILENAME MYLOG "&MyFolder\Exercise4_log.TXT";
FILENAME MYPRINT "&MyFolder\Exercise4_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

proc datasets lib=work nolist kill; quit; /* delete  all files in the WORK library */
LIBNAME CDATA 'C:\MEPS\SAS\DATA';
*LIBNAME CDATA "\\programs.ahrq.local\programs\MEPS\AHRQ4_CY2\B_CFACT\BJ001DVK\Workshop_2018_Fall\SAS\DATA";

OPTIONS NODATE;
TITLE1 '2018 AHRQ MEPS DATA USERS WORKSHOP';
TITLE2 'EXERCISE8.SAS: POOL MEPS DATA FILES FROM DIFFERENT PANELS (PANELS 17, 18, 19)';

PROC FORMAT;
	VALUE POVCAT 
    1 = '1 POOR/NEGATIVE'
    2 = '2 NEAR POOR'
    3 = '3 LOW INCOME'
    4 = '4 MIDDLE INCOME'
    5 = '5 HIGH INCOME'
    ;

	VALUE INSF
	-1= '-1 INAPPLICABLE'
	1 = '1 ANY PRIVATE'
	2 = '2 PUBLIC ONLY'
	3 = '3 UNINSURED';

    VALUE AGE
	  -1= '-1 INAPPLICABLE'    
    26-30='26-30'
    0-25, 31-HIGH='0-25, 31+';
run;

/* RENAME YEAR SPECIFIC VARIABLES PRIOR TO COMBINING FILES */
DATA POOL;
     LENGTH INSCOVY1 INSCOVY2 PANEL AGEY1X POVCATY1 VARSTR VARPSU 8;
	   SET CDATA.H164 (KEEP=DUPERSID INSCOVY1 INSCOVY2 LONGWT VARSTR VARPSU POVCATY1 AGEY1X PANEL)
	       CDATA.H172 (KEEP=DUPERSID INSCOVY1 INSCOVY2 LONGWT VARSTR VARPSU POVCATY1 AGEY1X PANEL)
	       CDATA.H183 (KEEP=DUPERSID INSCOVY1 INSCOVY2 LONGWT VARSTR VARPSU POVCATY1 AGEY1X PANEL);
     POOLWT = LONGWT/3 ;
   
     IF INSCOVY1=3 AND 26 LE AGEY1X LE 30 AND POVCATY1=5 THEN SUBPOP=1;
     ELSE SUBPOP=2;

     LABEL SUBPOP='POPULATION WITH AGE=26-30, UNINSURED, AND HIGH INCOME IN FIRST YEAR'
           INSCOVY2="HEALTH INSURANCE COVERAGE INDICATOR IN YEAR 2";
RUN;

TITLE3 "CHECK MISSING VALUES ON THE COMBINED DATA";
PROC MEANS DATA=POOL N NMISS;
RUN;

TITLE3 'SUPPORTING CROSSTAB FOR THE CREATION OF THE SUBPOP FLAG';
PROC FREQ DATA=POOL;
TABLES SUBPOP SUBPOP*PANEL SUBPOP*INSCOVY1*AGEY1X*POVCATY1/LIST MISSING;
FORMAT AGEY1X AGE. POVCATY1 POVCAT. INSCOVY1 INSF.;
RUN;
ODS GRAPHICS OFF;
ODS EXCLUDE ALL; /* Suppress the printing of output */ 
TITLE3 'INSURANCE STATUS IN THE SECOND YEAR FOR THOSE W/ AGE=26-30, UNINSURED WHOLE YEAR, AND HIGH INCOME IN THE FIRST YEAR';
PROC SURVEYMEANS DATA=POOL NOBS MEAN STDERR;
	STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  POOLWT;
	VAR  INSCOVY2;
	CLASS INSCOVY2;
    FORMAT INSCOVY2 INSF.;
	DOMAIN  SUBPOP('1');
	ODS OUTPUT DOMAIN=work.domain_results;
RUN;
ODS EXCLUDE NONE; /* Unsuppress the printing of output */
TITLE3 'INSURANCE STATUS IN THE SECOND YEAR FOR THOSE W/ AGE=26-30, UNINSURED WHOLE YEAR, AND HIGH INCOME IN THE FIRST YEAR';
proc print data= work.domain_results noobs split='*';
 var   VARLEVEL N  mean StdErr  ;
 label mean = 'Proportion'
       StdErr = 'SE of Proportion';
       format N Comma12. mean comma9.3 stderr 9.6;             
run;
ODS _ALL_ CLOSE;
/* THE PROC PRINTTO null step is required to close the PROC PRINTTO */
PROC PRINTTO;
RUN;

