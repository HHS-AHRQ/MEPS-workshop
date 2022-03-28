/*********************************************************************
PROGRAM: 	EXERCISE2.SAS

This program generates National Totals and Per-person Averages for Narcotic
 analgesics and Narcotic analgesic combos care for the U.S. civilian 
 non-institutionalized population (2019), including:
  - Number of purchases (fills)  
  - Total expenditures          
  - Out-of-pocket payments       
  - Third-party payments        

 Input files:
    - 2019 Prescribed medicines file
    - 2019 Full-year consolidated file

 This program is available at:
 https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/sas_exercises
************************************************************************************/
/* Clear log, output, and ODSRESULTS from the previous run automatically */
DM "Log; clear; output; clear; odsresults; clear";
proc datasets nolist lib=work  kill; quit; /* Delete  all files in the WORK library */

OPTIONS NOCENTER LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;

/*********************************************************************************
    IMPORTANT NOTE:  Use the next 5 lines of code, only if you want SAS to create 
    separate files for SAS log and output.  Otherwise comment  out these lines.
***********************************************************************************/

%LET RootFolder= C:\Mar2022\sas_exercises\Exercise_2;
FILENAME MYLOG "&RootFolder\Exercise2_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise2_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;


/* Create use-defined formats and store them in a catalog called FORMATS 
   in the work folder. They will be deleted at the end of tjr SAS session.
*/

PROC FORMAT;
   VALUE SUBPOP    
          1 = 'OnePlusNacroticEtc'
		  2 = 'OTHERS';
RUN;

/* KEEP THE SPECIFIED VARIABLES WHEN READING THE INPUT DATA SET AND
   RESTRICT TO OBSERVATIONS HAVING THERAPEUTIC CLASSIFICATION (TC) CODES
   FOR NARCOTIC ANALGESICS OR NARCOTIC ANALGESIC COMBOS 
*/

%LET DataFolder = C:\MEPS_Data;  /* Adjust the folder name, if needed */
libname CDATA "&DataFolder"; 

DATA WORK.DRUG;
  SET CDATA.H213A (KEEP=DUPERSID RXRECIDX LINKIDX TC1S1_1 RXXP19X RXSF19X
                   WHERE=(TC1S1_1 IN (60, 191))); 
RUN;

ODS HTML CLOSE; /* This will make the default HTML output no longer active,
                  and the output will not be displayed in the Results Viewer.*/
TITLE "A SAMPLE DUMP FOR PMED RECORDS WITH Narcotic analgesics or Narcotic analgesic combos, 2019";
PROC PRINT DATA=WORK.DRUG (OBS=12) noobs;
   VAR dupersid RXRECIDX LINKIDX TC1S1_1 RXXP19X RXSF19X;
RUN;


/* SUM "RXXP19X and RXSF19X" DATA TO PERSON-LEVEL*/

PROC SUMMARY DATA=WORK.DRUG NWAY;
  CLASS DUPERSID;
  VAR RXXP19X RXSF19X;
  OUTPUT OUT=WORK.PERDRUG (DROP = _TYPE_ RENAME=(_FREQ_ = N_PHRCHASE))
                  /*# OF PURCHASES PER PERSON */
             sum=TOT_EXP OOP_EXP;
RUN;

TITLE "A SAMPLE DUMP FOR PERSON-LEVEL EXPENDITURES FOR NARCOTIC ANALGESICS OR NARCOTIC ANALGESIC COMBOS";
PROC PRINT DATA=PERDRUG (OBS=3);
SUM N_PHRCHASE;
RUN;

DATA WORK.PERDRUG;
 SET PERDRUG; 
 /* CREATE A NEW VARIABLE FOR EXPENSES EXCLUDING OUT-OF-POCKET EXPENSES */
 THIRD_PAYER   = TOT_EXP- OOP_EXP; 
 RUN;
PROC SORT DATA=WORK.PERDRUG; BY DUPERSID; RUN;

/*SORT THE FULL-YEAR(FY) CONSOLIDATED FILE*/
PROC SORT DATA=CDATA.H216 (KEEP=DUPERSID VARSTR VARPSU PERWT19F) OUT=WORK.H216;
BY DUPERSID; RUN;

/*MERGE THE PERSON-LEVEL EXPENDITURES TO THE FY PUF*/
DATA  WORK.PersonRxLinked;
MERGE WORK.H216 (IN=Person) 
      WORK.PERDRUG  (IN=RX KEEP=DUPERSID N_PHRCHASE TOT_EXP OOP_EXP THIRD_PAYER);
   BY DUPERSID;
   IF Person and RX THEN SUBPOP = 1; /*PERSONS WITH 1+ Narcotic analgesics or Narcotic analgesic combos */

   ELSE IF Person NE RX THEN DO;   
         SUBPOP         = 2 ;  /*PERSONS WITHOUT ANY PURCHASE OF Narcotic analgesics or Narcotic analgesic combos*/
         N_PHRCHASE  = 0 ;  /*# OF PURCHASES PER PERSON */
         THIRD_PAYER = 0 ;
         TOT_EXP = 0 ;
         OOP_EXP = 0 ;
    END;
    IF PERSON; 
	LABEL   TOT_EXP= 'TOTAL EXPENSES FOR NACROTIC ETC'
	        OOP_Exp = 'OUT-OF-POCKET EXPENSES'
            THIRD_PAYER = 'TOTAL EXPENSES MINUS OUT-OF-POCKET EXPENSES'
            N_PHRCHASE  = '# OF PURCHASES PER PERSON';
RUN;
TITLE;

/* CALCULATE ESTIMATES ON USE AND EXPENDITURES*/
ods graphics off; /*Suppress the graphics */
ods listing; /* Open the listing destination*/
ods exclude Statistics /* Not to generate output for the overall population */
TITLE "PERSON-LEVEL ESTIMATES ON EXPENDITURES AND USE FOR NARCOTIC ANALGESICS or NARCOTIC COMBOS, 2168";
/* When you request SUM in PROC SURVEYMEANS, the procedure computes STD by default.*/
PROC SURVEYMEANS DATA=WORK.PersonRxLinked NOBS SUMWGT MEAN STDERR SUM;
  VAR  N_PHRCHASE TOT_EXP OOP_EXP THIRD_PAYER ;
  STRATA  VARSTR ;
  CLUSTER VARPSU;
  WEIGHT  PERWT19f;
  DOMAIN  SUBPOP("OnePlusNacroticEtc");
  FORMAT SUBPOP SUBPOP.;
 RUN;
title;
/* THE PROC PRINTTO null step is required to close the PROC PRINTTO, 
 only if used earlier., Otherswise. please comment out the next two lines  */

PROC PRINTTO;
RUN;

