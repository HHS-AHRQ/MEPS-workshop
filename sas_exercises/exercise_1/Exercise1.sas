/**********************************************************************************
program:      exercise1.sas

this program generates the following estimates on national health care expenses for 2020:
  - overall expenses (national totals)
  - proportion/percentage of persons with an expense
  - mean expense per person, overall and by age group (0-64 vs. 65+)
  - mean expense per person with an expense, overall and by age group (0-64 vs. 65+)
  - median expense per person with an expense, overall and by age group (0-64 vs. 65+)

 input file: 2020 full-year consolidated file
*******************************************************************************************************/

/* clear log, output, and odsresults from the previous run automatically */
dm "log; clear; output; clear; odsresults; clear";

/* delete  all files in the work library */
proc datasets nolist lib=work kill ; quit; 
options nocenter ls=132 ps=79 nodate formchar="|----|+|---+=|-/\<>*" pageno=1;

/*********************************************************************************
 uncomment the next 5 lines of code, only if you want sas to create 
    separate files for log and output
***********************************************************************************/
/*
%let rootfolder= c:\SASHandsOnSep2022\sas_exercises\exercise_1;
filename mylog "&rootfolder\exercise1_log.txt";
filename myprint "&rootfolder\exercise1_output.txt";
proc printto log=mylog print=myprint new;
run;
*/
/* create user-defined formats and store them in the work folder */

proc format;
  value agecat
       low-64 = '0-64'
       65-high = '65+';

   value totexp20_cate
      0         = 'no expense'
      other     = 'any expense';
run;

%let datafolder = c:\meps_data;  /* create a macro variable. adjust the folder name, if needed */
libname cdata "&datafolder";  /* define a sas library and assign a libref to it */

/* read in the sas data set from the 2020 meps full-year consolidated file (hc-224) */
data work.puf224;
  set cdata.h224 (keep = totexp20 agelast   varstr  varpsu  perwt20f panel);

  /* create another version of the totexp20 variable for a domain variable */
     with_an_expense= totexp20; 

  /* create a character variable based on a numeric variable using a table lookup */
	 char_with_an_expense = put(totexp20,totexp20_cate.); 
	 
  run;

title 'meps full-year consolidated file, 2020';
ods html close; /* this will make the default html output no longer active,
                  and the output will not be displayed in the results viewer.*/

ods graphics off; /*suppress the graphics */
ods listing; /* open the listing destination*/
title2 'proportion of persons with an expense (2-category numeric variable/class statement required), 2020 _method 1';
proc surveymeans data=work.puf224 nobs mean stderr sum ;
    var  with_an_expense  ;
	stratum varstr;
	cluster varpsu;
	weight perwt20f;
	class with_an_expense;
	format with_an_expense totexp20_cate. ;
run;

title2 'proportion of persons with an expense (2-category character variable), 2020 - method 2';
proc surveymeans data=work.puf224 nobs mean stderr sum ;
    var  char_with_an_expense  ;
	stratum varstr;
	cluster varpsu;
    weight perwt20f;
run;

title2 'percentage of persons with an expense, 2020 - method 3';
proc surveyfreq data=work.puf224 ;
    tables  char_with_an_expense ;
	stratum varstr;
	cluster varpsu;
	weight perwt20f;
run;

title2 'mean and median expense per person with an expense, oveall and for ages 0-64, and 65+, 2020';
proc surveymeans data= work.puf224 nobs mean stderr sum median  ;
    var  totexp20;
    stratum varstr ;
	cluster varpsu ;
	weight  perwt20f ;	
	domain with_an_expense('any expense') with_an_expense('any expense')*agelast;
	format with_an_expense totexp20_cate. agelast agecat.;
run;
title;  /* cancel the TITLE and TITLE2 statements */
/* uncomment the next 2 lines of code to close the proc printto, only if used earlier */
/*
proc printto;
run;
*/
