/************************************************************************************************/
/* stata user file for h201 data                                                                 */
/*                                                                                              */
/* this file contains information and a sample stata program to create a permanent              */
/* stata dataset for users who want to use stata in processing the meps data provided           */
/* in this puf release.  stata (statacorp) has the capability to produce                        */
/* appropriate standard errors for estimates from a survey with a complex sample                */
/* design such as the medical expenditure panel survey (meps).                                  */
/* the input file for creating a permanent stata dataset is the ascii data file                 */
/* (h201.dat) supplied in this puf release, which in turn can be extracted from the              */
/* .exe file. after entering the stata interactive environment access the stata do-file         */
/* editor by clicking on the appropriate icon in the command line at the top of the             */
/* screen.  copy and paste the following stata commands into the editor and save as a           */
/* do file.  a do file is a stata program which may then be executed using the do command.      */
/* for example, if the do file is named h201.do and is located in the directory                  */
/* c:\meps\prog, then the file may be executed by typing the following command into             */
/* the stata command line:                                                                      */
/*                         do c:\meps\prog\h201.do                                               */
/* the program below will output the stata dataset h201.dta                                      */
/************************************************************************************************/
cd "c:\work\meps_workshop"
capture log close
log using download_PUF_ascii.log, replace
clear

/* download zip files containing ascii data */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h201dat.zip" "h201dat.zip"
unzipfile "h201dat.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h197adat.zip" "h197adat.zip"
unzipfile "h197adat.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h192dat.zip" "h192dat.zip"
unzipfile "h192dat.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h202dat.zip" "h202dat.zip"
unzipfile "h202dat.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h193dat.zip" "h193dat.zip"
unzipfile "h193dat.zip", replace 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h183dat.zip" "h183dat.zip"
unzipfile "h183dat.zip", replace 

#delimit ;

/**************************************/
/* hc 201    2017 Full Year Person    */
/**************************************/
* input all variables;
infix
  str    dupersid 9-16
  byte   panel 17-18
  int    varstr 4212-4215
  byte   varpsu 4216-4216
  double perwt17f 4138-4150
  long   totexp17 2590-2595
  long   totslf17 2596-2601
  byte   inscov17 2217-2217
  byte   povcat17 1499-1499
  byte   age31x 171-172
  byte   age42x 173-174
  byte   age53x 175-176
  byte   age17x 177-178
  byte   agelast 179-180
  byte   racethx 194-194
using h201.dat;

*define variable labels;
label variable dupersid "person id (duid + pid)";
label variable panel "panel number";
label variable age31x "age - r3/1 (edited/imputed)";
label variable age42x "age - r4/2 (edited/imputed)";
label variable age53x "age - r5/3 (edited/imputed)";
label variable age17x "age as of 12/31/17 (edited/imputed)";
label variable agelast "person s age last time eligible";
label variable racethx "race/ethnicity (edited/imputed)";
label variable totexp17 "total health care exp 17";
label variable totslf17 "total amt paid by self/family 17";
label variable varstr "variance estimation stratum - 2017";
label variable varpsu "variance estimation psu - 2017";
label variable perwt17f "final person weight, 2017";
label variable povcat17 "family inc as % of poverty line - catego";
label variable inscov17 "health insurance coverage indicator 2017";

*define value labels for reports;
label define h2010992x
         -1 "-1 inapplicable"
         1 "1 hispanic"
         2 "2 non-hispanic white only"
         3 "3 non-hispanic black only"
         4 "4 non-hispanic asian only"
         5 "5 non-hispanic other race or multiple race" ;
		 
label define h2010528x
         1 "1 any private"
         2 "2 public only"
         3 "3 uninsured" ;

label define h2010876x
         1 "1 poor/negative"
         2 "2 near poor"
         3 "3 low income"
         4 "4 middle income"
         5 "5 high income" ;

* associate variables with value label definitions;
label value racethx h2010992x;
label value povcat17 h2010876x;
label value inscov17 h2010528x;

*display a description of stata file;
describe;
save h201, replace;

/**************************************/
/* hc 192 2016 Full Year Person       */
/**************************************/
clear;
* input all variables;
infix
  str    dupersid 9-16
  byte   panel 17-18
  int    varstr 5570-5573
  byte   varpsu 5574-5574
  double perwt16f 5497-5508
  long   totexp16 2782-2787
  long   totslf16 2788-2793
  byte   inscov16 2394-2394
  byte   povcat16 1651-1651
  byte   age31x 171-172
  byte   age42x 173-174
  byte   age53x 175-176
  byte   age16x 177-178
  byte   agelast 179-180
  byte   racethx 194-194
using h192.dat;

*define variable labels;
label variable dupersid "person id (duid + pid)";
label variable panel "panel number";
label variable age31x "age - r3/1 (edited/imputed)";
label variable age42x "age - r4/2 (edited/imputed)";
label variable age53x "age - r5/3 (edited/imputed)";
label variable age16x "age as of 12/31/16 (edited/imputed)";
label variable agelast "person s age last time eligible";
label variable racethx "race/ethnicity (edited/imputed)";
label variable totexp16 "total health care exp 16";
label variable totslf16 "total amt paid by self/family 16";
label variable varstr "variance estimation stratum - 2016";
label variable varpsu "variance estimation psu - 2016";
label variable perwt16f "final person weight, 2016";
label variable povcat16 "family inc as % of poverty line - catego";
label variable inscov16 "health insurance coverage indicator 2016";

*define value labels for reports;
label define h2010992x
         -1 "-1 inapplicable"
         1 "1 hispanic"
         2 "2 non-hispanic white only"
         3 "3 non-hispanic black only"
         4 "4 non-hispanic asian only"
         5 "5 non-hispanic other race or multiple race" ;
		 
label define h2010528x
         1 "1 any private"
         2 "2 public only"
         3 "3 uninsured" ;

label define h2010876x
         1 "1 poor/negative"
         2 "2 near poor"
         3 "3 low income"
         4 "4 middle income"
         5 "5 high income" ;

* associate variables with value label definitions;
label value racethx h2010992x;
label value povcat16 h2010876x;
label value inscov16 h2010528x;

*display a description of stata file;
describe;//////
save h192, replace;


/**************************************/
/* hc 197A 2017 Rx Drug File          */
/**************************************/
clear;
* input all variables;
infix
  str    dupersid 9-16
  byte   panel 55-56
  double perwt17f 560-571
  int    varstr 572-575
  byte   varpsu 576-576
  str    rxrecidx 28-42
  str    linkidx 43-54
  int    tc1s1_1 422-424
  double rxxp17x 552-559
  double rxsf17x 462-468
using h197a.dat;

describe;
save h197a, replace;

/*********************************************************************/
/* hc 183, 193, 202: longitudinal files for panels 19, 20, and 21    */
/*********************************************************************/
clear;
* input all variables;
infix
  str    dupersid 9-16
  byte   panel 17-18
  byte   inscovy1 4167-4168
  byte   inscovy2 4169-4170
  byte   varpsu 10109-10109
  int    varstr 10110-10113
  double longwt 10114-10126
  byte   povcaty1 2645-2646
  byte   povcaty2 2647-2648
  byte   agey1x 334-335
  byte   agey2x 336-337
using h183.dat;
save h183, replace;
clear;

infix
  str    dupersid 9-16
  byte   panel 17-18
  byte   inscovy1 4368-4369
  byte   inscovy2 4370-4371
  byte   varpsu 10288-10288
  int    varstr 10289-10292
  double longwt 10293-10305
  byte   povcaty1 2843-2844
  byte   povcaty2 2845-2846
  byte   agey1x 334-335
  byte   agey2x 336-337
using h193.dat;
save h193, replace;
clear;

infix
  str    dupersid 9-16
  byte   panel 17-18
  byte   inscovy1 4416-4417
  byte   inscovy2 4418-4419
  byte   varpsu 9165-9165
  int    varstr 9166-9169
  double longwt 9170-9182
  byte   povcaty1 2916-2917
  byte   povcaty2 2918-2919
  byte   agey1x 334-335
  byte   agey2x 336-337
using h202.dat;
save h202, replace;
