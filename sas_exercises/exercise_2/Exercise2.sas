/*********************************************************************

PROGRAM: 	EXERCISE2.SAS

PURPOSE:	THIS PROGRAM GENERATES SELECTED ESTIMATES FOR A 2016 VERSION OF THE Purchases and Expenses for Narcotic analgesics or Narcotic analgesic combos


    (1) FIGURE 1: TOTAL EXPENSE FOR Narcotic analgesics or Narcotic analgesic combos

    (2) FIGURE 2: TOTAL NUMBER OF PURCHASES OF Narcotic analgesics or Narcotic analgesic combos

    (3) FIGURE 3: TOTAL NUMBER OF PERSONS PURCHASING ONE OR MORE Narcotic analgesics or Narcotic analgesic combos

    (4) FIGURE 4: AVERAGE TOTAL, OUT OF POCKET, AND THIRD PARTY PAYER EXPENSE
                  FOR Narcotic analgesics or Narcotic analgesic combos PER PERSON WITH AN Narcotic analgesics or Narcotic analgesic combos MEDICINE PURCHASE

INPUT FILES:  (1) C:\DATA\H1192.SAS7BDAT (2016 FULL-YEAR CONSOLIDATED PUF)
              (2) C:\DATA\H188A.SAS7BDAT (2016 PRESCRIBED MEDICINES PUF)

*********************************************************************/
/* IMPORTANT NOTES: Use the next 6 lines of code, if you want to specify an alternative destination for SAS log and 
SAS procedure output.*/

%LET MyFolder= S:\CFACT\Shared\WORKSHOPS\2019\Spring2019\Exercise_2;
OPTIONS LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;
FILENAME MYLOG "&MyFolder\Exercise2_log.TXT";
FILENAME MYPRINT "&MyFolder\Exercise2_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

proc datasets lib=work nolist kill; quit; /* delete  all files in the WORK library */
LIBNAME CDATA 'C:\DATA';
PROC FORMAT;
  VALUE GTZERO
     0         = '0'
     0 <- HIGH = '>0' ;
  VALUE SUBPOP    
          1 = 'PERSONS WITH 1+ Narcotic etc'
		  2 = 'OTHERS';
RUN;

/* KEEP THE SPECIFIED VARIABLES WHEN READING THE INPUT DATA SET AND
   RESTRICT TO OBSERVATIONS HAVING THERAPEUTIC CLASSIFICATION (TC) CODES
   FOR Narcotic analgesics or Narcotic analgesic combos */

DATA WORK.DRUG;
  SET CDATA.H188A (KEEP=DUPERSID RXRECIDX LINKIDX TC1S1_1 RXXP16X RXSF16X
                   WHERE=(TC1S1_1 IN (60, 191))); 
RUN;

ODS HTML CLOSE; /* This will make the default HTML output no longer active,
                  and the output will not be displayed in the Results Viewer.*/
TITLE1 ' ';
TITLE2 ' ';
TITLE3 '2019 AHRQ MEPS DATA USERS WORKSHOP (EXERCISE2.SAS)';
TITLE4 "A SAMPLE DUMP FOR PMED RECORDS WITH Narcotic analgesics or Narcotic analgesic combos, 2016";
PROC PRINT DATA=WORK.DRUG (OBS=30);
VAR RXRECIDX LINKIDX TC1S1_1 RXXP16X RXSF16X;
 BY DUPERSID;
RUN;


/* SUM "RXXP16X and RXSF16X" DATA TO PERSON-LEVEL*/

PROC SUMMARY DATA=WORK.DRUG NWAY;
  CLASS DUPERSID;
  VAR RXXP16X RXSF16X;
  OUTPUT OUT=WORK.PERDRUG (DROP=_TYPE_) sum=TOT OOP;
RUN;

TITLE4 "A SAMPLE DUMP FOR PERSON-LEVEL EXPENDITURES FOR Narcotic analgesics or Narcotic analgesic combos";
PROC PRINT DATA=PERDRUG (OBS=30);
RUN;

DATA WORK.PERDRUG2;
 SET PERDRUG  (RENAME=(_FREQ_ = N_PHRCHASE)) ; /*# OF PURCHASES PER PERSON */
 /* CREATE A NEW VARIABLE FOR EXPENSES EXCLUDING OUT-OF-POCKET EXPENSES */
 THIRD_PAYER   = TOT - OOP; 
 RUN;
PROC SORT DATA=WORK.PERDRUG2; BY DUPERSID; RUN;

/*SORT THE FULL-YEAR(FY) CONSOLIDATED FILE*/
PROC SORT DATA=CDATA.H192 (KEEP=DUPERSID VARSTR VARPSU PERWT16F) OUT=WORK.H192;
BY DUPERSID; RUN;

/*MERGE THE PERSON-LEVEL EXPENDITURES TO THE FY PUF*/
DATA  WORK.FY;
MERGE WORK.H192 (IN=AA) 
      WORK.PERDRUG2  (IN=BB KEEP=DUPERSID N_PHRCHASE TOT OOP THIRD_PAYER);
   BY DUPERSID;
   IF AA AND BB THEN SUBPOP = 1; /*PERSONS WITH 1+ Narcotic analgesics or Narcotic analgesic combos */
   ELSE IF AA NE BB THEN DO;   
         SUBPOP         = 2 ;  /*PERSONS WITHOUT ANY PURCHASE OF Narcotic analgesics or Narcotic analgesic combos*/
         N_PHRCHASE  = 0 ;  /*# OF PURCHASES PER PERSON */
         THIRD_PAYER = 0 ;
         TOT         = 0 ;
         OOP         = 0 ;
    END;
    IF AA; 
	LABEL   TOT = 'TOTAL EXPENSE FOR NACROTIC ETC'
            THIRD_PAYER = 'TOTAL-OOP EXPENSES'
            N_PHRCHASE  = '# OF PURCHASES PER PERSON';
RUN;
/*DELETE ALL THE DATA SETS IN THE LIBRARY WORK and STOPS the DATASETS PROCEDURE*/
PROC DATASETS LIBRARY=WORK; 
 DELETE DRUG PERDRUG2 H192; 
RUN;
QUIT;
TITLE4 "SUPPORTING CROSSTABS FOR NEW VARIABLES";
PROC FREQ DATA=WORK.FY;
  TABLES  SUBPOP * N_PHRCHASE * TOT * OOP * THIRD_PAYER / LIST MISSING ;
  FORMAT SUBPOP SUBPOP. N_PHRCHASE TOT OOP THIRD_PAYER gtzero. ;
RUN;


/* CALCULATE ESTIMATES ON USE AND EXPENDITURES*/
ods graphics off; /*Suppress the graphics */
ods listing; /* Open the listing destination*/
TITLE4 "PERSON-LEVEL ESTIMATES ON EXPENDITURES AND USE FOR Narcotic analgesics or Narcotic analgesic combos, 2016";
TITLE5 "AUTOMATIC OUTPUT GENERATED FROM PROC SURVEYMEANS";
PROC SURVEYMEANS DATA=WORK.FY NOBS SUMWGT SUM STD MEAN STDERR;
  STRATA  VARSTR ;
  CLUSTER VARPSU;
  WEIGHT  PERWT16F;
  VAR TOT N_PHRCHASE  OOP THIRD_PAYER ;
  DOMAIN  SUBPOP("PERSONS WITH 1+ Narcotic etc");
  FORMAT SUBPOP SUBPOP.;
  ODS OUTPUT DOMAIN=work.domain_results;
RUN;

TITLE5 "CUSTOMIZED OUTPUT BASED ON ODS TABLE NAME (DOMAIN OUTPUT DATA SET) CREATED FROM PROC SURVEYMEANS";
proc print data= work.domain_results noobs split='*';
 var   VARLABEL N  SumWgt  mean StdErr  Sum stddev;
 label SumWgt = 'Population*Size'
       mean = 'Mean'
       StdErr = 'SE of Mean'
       Sum = 'Total'
       Stddev = 'SE of*Total';
       format N SumWgt Comma12. mean 9.1 stderr 9.4
              sum Stddev comma17.;
run;
/* THE PROC PRINTTO null step is required to close the PROC PRINTTO, 
 only if used earlier */
PROC PRINTTO;
RUN;
