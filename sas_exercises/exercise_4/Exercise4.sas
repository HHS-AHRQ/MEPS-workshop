/**********************************************************************************
PROGRAM:      EXERCISE4.SAS

DESCRIPTION:  THIS PROGRAM ILLUSTRATES HOW TO POOL MEPS LONGITUDINAL DATA FILES FROM DIFFERENT PANELS
              THE EXAMPLE USED IS PANELS 17-19 POPULATION AGE 26-30 WHO ARE UNINSURED BUT HAVE HIGH INCOME IN THE FIRST YEAR

	            DATA FROM PANELS 19, 20, AND 21 ARE POOLED.

INPUT FILE:     (1) C:\MEPS\SAS\DATA\H183.SAS7BDAT (PANEL 19 LONGITUDINAL FILE)
	            (2) C:\MEPS\SAS\DATA\H193.SAS7BDAT (PANEL 20 LONGITUDINAL FILE)
	            (3) C:\MEPS\SAS\DATA\H202.SAS7BDAT (PANEL 21 LONGITUDINAL FILE)
***************************************************************************************/

proc datasets lib=work nolist kill; quit; /* Delete  all files in the WORK library */
OPTIONS LS=132 PS=79 NODATE VARLENCHK=NOWARN FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1 ;
%LET DataFolder = C:\DATA\MySDS;   /* Adjust the folder name, if needed */

/*********************************************************************************
* IMPORTANT NOTE:  Use the next 5 lines of code, only if you want SAS to create 
*   separate files for SAS log and output.  Otherwise comment  out those 5 lines 
************************************************************************************/

%LET RootFolder= C:\Fall2020\sas_exercises\Exercise_4;
FILENAME MYLOG "&RootFolder\Exercise4_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise4_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

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

	VALUE  SUBPOP (max= 30)
	1 = 'AGE 26-30, UNINS_HI_INC'
	2 ='OTHERS';
run;

libname CDATA "&DataFolder"; 
/* RENAME YEAR SPECIFIC VARIABLES PRIOR TO COMBINING FILES */
DATA WORK.POOL;
      SET CDATA.H183 (KEEP=DUPERSID INSCOVY1 INSCOVY2 LONGWT VARSTR VARPSU POVCATY1 AGEY1X PANEL YEARIND)
	       CDATA.H193 (KEEP=DUPERSID INSCOVY1 INSCOVY2 LONGWT VARSTR VARPSU POVCATY1 AGEY1X PANEL YEARIND)
	       CDATA.H202 (KEEP=DUPERSID INSCOVY1 INSCOVY2 LONGWT VARSTR VARPSU POVCATY1 AGEY1X PANEL YEARIND);
     POOLWT = LONGWT/3 ;
   
     IF INSCOVY1=3 AND 26 LE AGEY1X LE 30 AND POVCATY1=5 THEN SUBPOP=1;
     ELSE SUBPOP=2;
  RUN;
ODS HTML CLOSE; /* This will make the default HTML output no longer active,
                  and the output will not be displayed in the Results Viewer.*/
TITLE "COMBINED MEPS DATA FROM PANELS 19, 20, and 21";
PROC MEANS DATA=POOL N NMISS;
RUN;
/*QC purposes*/
/*
PROC FREQ DATA=POOL;
TABLES SUBPOP SUBPOP*PANEL SUBPOP*INSCOVY1*AGEY1X*POVCATY1/LIST MISSING;
FORMAT AGEY1X AGE. POVCATY1 POVCAT. INSCOVY1 INSF. SUBPOP SUBPOP.;
RUN;
*/
ODS GRAPHICS OFF;
ods listing; /* Open the listing destination*/
ODS EXCLUDE STATISTICS; /* Not to generate output for the overall population */
TITLE2 'INSURANCE STATUS IN THE SECOND YEAR FOR THOSE W/ AGE=26-30, UNINSURED WHOLE YEAR, AND HIGH INCOME IN THE FIRST YEAR';
/* PROC SURVEYMEANS computes the NOBS, MEANS, STDERR, and CLM statistics by default */
PROC SURVEYMEANS DATA=POOL; 
    VAR  INSCOVY2;
    STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  POOLWT;
	CLASS INSCOVY2;
    DOMAIN  SUBPOP("AGE 26-30, UNINS_HI_INC");
	FORMAT INSCOVY2 INSF. SUBPOP SUBPOP.;
RUN;

/*Explanation for the above code: PROC SURVEYMEANS always analyzes character variables as categorical. 
If you want categorical analysis for a numeric variable, 
you must include that variable in the CLASS statement as well as the VAR statement.*/  


/* THE PROC PRINTTO null step is required to close the PROC PRINTTO,  only if used earlier.
   Otherswise. please comment out the next two lines */


PROC PRINTTO;
RUN;


