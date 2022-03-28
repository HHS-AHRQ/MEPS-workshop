/**********************************************************************************
PROGRAM:      EXERCISE1.SAS

This program generates the following estimates on national health care expenses
for the civilian noninstitutionized population, 2019:
  - Overall expenses (National totals)
  - Percentage of persons with an expense
  - Mean expense per person
  - Mean/median expense per person with an expense:
    - Mean expense per person with an expense
    - Mean expense per person with an expense, by age group
    - Median expense per person with an expense, by age group
 Input file:
 - 2019 Full-year consolidated file

This program is available at:
 https://github.com/HHS-AHRQ/MEPS-workshop/tree/master/sas_exercises
*******************************************************************************************************/

/* Clear log, output, and ODSRESULTS from the previous run automatically */
DM "Log; clear; output; clear; odsresults; clear";

proc datasets nolist lib=work kill ; quit; /* Delete  all files in the WORK library */

OPTIONS NOCENTER LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;

/*********************************************************************************
 IMPORTANT NOTE:  Use the next 5 ines of code, only if you want SAS to create 
    separate files for SAS log and output.  Otherwise comment  out these lines.
***********************************************************************************/

%LET RootFolder= C:\Mar2022\sas_exercises\Exercise_1;
FILENAME MYLOG "&RootFolder\Exercise1_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise1_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

/* Create user-defined formats and store them in a catalog called FORMATS 
   in the work folder. They will be automatically deleted at the end of the SAS session.
*/

PROC FORMAT;
  VALUE AGECAT
       low-64 = '0-64'
	   65-high = '65+';

   VALUE totexp19_cate
      0         = 'No Expense'
      Other     = 'Any Expense';
RUN;


%LET DataFolder = C:\MEPS_Data;  /* Create a macro variable. Adjust the folder name, if needed */
libname CDATA "&DataFolder";  /* Assign a libref () to a SAS library.
/* READ IN DATA FROM 2019 CONSOLIDATED DATA FILE (HC-216) */
DATA WORK.PUF216;
  SET CDATA.H216 (KEEP = TOTEXP19 AGELAST   VARSTR  VARPSU  PERWT19F panel);
     WITH_AN_EXPENSE= TOTEXP19; /* Create another version of the TOTEXP19 variable */

	 /* Create a character variable based on a numeric variable using a table lookup */
	 CHAR_WITH_AN_EXPENSE = PUT(TOTEXP19,totexp19_cate.); 
	 
  RUN;
TITLE;

TITLE "MEPS FULL-YEAR CONSOLIDATED FILE, 2019";
ODS HTML CLOSE; /* This will make the default HTML output no longer active,
                  and the output will not be displayed in the Results Viewer.*/

ods graphics off; /*Suppress the graphics */
ods listing; /* Open the listing destination*/
TITLE2 'PROPORTION OF PERSONS WITH AN EXPENSE (2-category NUMERIC VARIABLE/CLASS statement required), 2019 _Method 1';
PROC SURVEYMEANS DATA=WORK.PUF216 NOBS MEAN STDERR sum ;
    VAR  WITH_AN_EXPENSE  ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT19F;
	class WITH_AN_EXPENSE;
	FORMAT WITH_AN_EXPENSE TOTEXP19_CATE. ;
RUN;

TITLE2 'PROPORTION OF PERSONS WITH AN EXPENSE (2-CATEGORY CHARACTER VARIABLE), 2019 - Method 2';
PROC SURVEYMEANS DATA=WORK.PUF216 NOBS MEAN STDERR sum ;
    VAR  CHAR_WITH_AN_EXPENSE  ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
    WEIGHT PERWT19F;
RUN;

TITLE2 'PERCENTAGE OF PERSONS WITH AN EXPENSE, 2019 - Method 3';
PROC SURVEYFREQ DATA=WORK.PUF216 ;
    TABLES  CHAR_WITH_AN_EXPENSE ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT19F;
RUN;

TITLE2 'MEAN AND MEDIAN EXPENSE PER PERSON WITH AN EXPENSE, OVEALL and FOR AGES 0-64, AND 65+, 2019';

PROC SURVEYMEANS DATA= WORK.PUF216 NOBS MEAN STDERR sum median  ;
    VAR  totexp19;
    STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  PERWT19F ;	
	DOMAIN WITH_AN_EXPENSE('Any Expense') WITH_AN_EXPENSE('Any Expense')*AGELAST;
	FORMAT WITH_AN_EXPENSE TOTEXP19_CATE. AGELAST agecat.;
RUN;
title;
/* THE PROC PRINTTO null step is required to close the PROC PRINTTO,  only if used earlier.
   Otherswise. please comment out the next two lines */


PROC PRINTTO;
RUN;
