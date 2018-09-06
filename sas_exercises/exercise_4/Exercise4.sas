/**********************************************************************************

PROGRAM:      C:\MEPS\SAS\PROG\EXERCISE8.SAS

DESCRIPTION:  THIS PROGRAM ILLUSTRATES HOW TO POOL MEPS LONGITUDINAL DATA FILES FROM DIFFERENT PANELS
              THE EXAMPLE USED IS PANELS 17-19 POPULATION AGE 26-30 WHO ARE UNINSURED BUT HAVE HIGH INCOME IN THE FIRST YEAR

	            DATA FROM PANELS 17, 18, AND 19 ARE POOLED.

INPUT FILE:   (1) C:\MEPS\SAS\DATA\H183.SAS7BDAT (PANEL 19 LONGITUDINAL FILE)
	          (2) C:\MEPS\SAS\DATA\H172.SAS7BDAT (PANEL 18 LONGITUDINAL FILE)
	          (3) C:\MEPS\SAS\DATA\H164.SAS7BDAT (PANEL 17 LONGITUDINAL FILE)

*********************************************************************************/;
*LIBNAME CDATA 'C:\MEPS\SAS\DATA';
*LIBNAME CDATA "\\programs.ahrq.local\programs\MEPS\AHRQ4_CY2\B_CFACT\BJ001DVK\Workshop_2018_Fall\SAS\DATA";

ods graphics off;

OPTIONS NODATE;
TITLE1 '2018 AHRQ MEPS DATA USERS WORKSHOP';
TITLE2 'EXERCISE8.SAS: POOL MEPS DATA FILES FROM DIFFERENT PANELS (PANELS 17, 18, 19)';

/* LOAD SAS TRANSPORT FILES (.ssp) */
FILENAME in_h183 'C:\MEPS\h183.ssp';
proc xcopy in = in_h183 out = WORK IMPORT;
run;

FILENAME in_h172 'C:\MEPS\h172.ssp';
proc xcopy in = in_h172 out = WORK IMPORT;
run;

FILENAME in_h164 'C:\MEPS\h164.ssp';
proc xcopy in = in_h164 out = WORK IMPORT;
run;

/* CREATE FORMATS */
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
	   SET H164 (KEEP=DUPERSID INSCOVY1 INSCOVY2 LONGWT VARSTR VARPSU POVCATY1 AGEY1X PANEL)
	       H172 (KEEP=DUPERSID INSCOVY1 INSCOVY2 LONGWT VARSTR VARPSU POVCATY1 AGEY1X PANEL)
	       H183 (KEEP=DUPERSID INSCOVY1 INSCOVY2 LONGWT VARSTR VARPSU POVCATY1 AGEY1X PANEL);
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


TITLE3 'INSURANCE STATUS IN THE SECOND YEAR FOR THOSE W/ AGE=26-30, UNINSURED WHOLE YEAR, AND HIGH INCOME IN THE FIRST YEAR';
PROC SURVEYMEANS DATA=POOL NOBS MEAN STDERR;
	STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  POOLWT;
	DOMAIN  SUBPOP;
	VAR  INSCOVY2;
	CLASS INSCOVY2;
	FORMAT INSCOVY2 INSF.;
RUN;


TITLE3 'INSURANCE STATUS IN THE SECOND YEAR FOR THOSE W/ AGE=26-30, UNINSURED WHOLE YEAR, AND HIGH INCOME IN THE FIRST YEAR, surveyfreq version';
PROC SURVEYfreq DATA=POOL ;
	STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  POOLWT;
	table  subpop*INSCOVY2;
	FORMAT INSCOVY2 INSF.;
RUN;
