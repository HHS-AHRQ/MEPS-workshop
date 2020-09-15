/************************************************************************************************/
/* This program downloads the data needed for all the exercises in ascii format and             */
/* converts it to Stata format (.dta)                                                           */
/*                                                                                              */
/*                                                                                              */
/* Users of Stata MP should create a directory "C:\MEPS\DATA" and can run the code as-is        */ 
/*                                                                                              */
/* Users of Macs or Linux computers will need to modify the code downloaded from the MEPS       */
/* webpage to point to the location where the data files will be downloaded, read and written   */
/*                                                                                              */
/* Users of Stata IC, which limits the number of variables that can be read into a single       */
/* data set, will need to execute the alternative code provided to read in the subset of        */
/* variables used in the excercises.                                                            */
/************************************************************************************************/
cd "c:\MEPS\DATA"
capture log close
clear

*********************************************
/* download zip files containing ascii data */
*********************************************
/* 2017 & 2018 Full Year Consolidated Files */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h209dat.zip" "h209dat.zip"
unzipfile "h209dat.zip", replace 
do https://meps.ahrq.gov/data_stats/download_data/pufs/h209/h209stu.txt
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h201dat.zip" "h201dat.zip"
unzipfile "h201dat.zip", replace 
do https://meps.ahrq.gov/data_stats/download_data/pufs/h201/h201stu.txt

/* 2017 & 2018 Rx files */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h197adat.zip" "h197adat.zip"
unzipfile "h197adat.zip", replace 
do https://meps.ahrq.gov/data_stats/download_data/pufs/h197a/h197astu.txt
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h206adat.zip" "h206adat.zip"
unzipfile "h206adat.zip", replace 
do https://meps.ahrq.gov/data_stats/download_data/pufs/h206a/h206astu.txt

************************************************************************
/* Longitudinal files for panels 19, 20 and 21---- FOR STATA MP USERS */
************************************************************************
/*
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h202dat.zip" "h202dat.zip"
unzipfile "h202dat.zip", replace
do https://meps.ahrq.gov/data_stats/download_data/pufs/h202/h202stu.txt
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h193dat.zip" "h193dat.zip"
unzipfile "h193dat.zip", replace 
do https://meps.ahrq.gov/data_stats/download_data/pufs/h193/h193stu.txt
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h183dat.zip" "h183dat.zip"
unzipfile "h183dat.zip", replace 
do https://meps.ahrq.gov/data_stats/download_data/pufs/h183/h183stu.txt
*/
************************************************************************
/* Longitudinal files for panels 19, 20 and 21---- FOR STATA IC USERS */
************************************************************************
#delimit ;
clear;
/**************************************/
/* hc 202 Panel 19                    */
/**************************************/
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h202dat.zip" "h202dat.zip";
unzipfile "h202dat.zip", replace;

infix
  long   DUID 1-5
  int    PID 6-8
  str    DUPERSID 9-16
  byte   PANEL 17-18
  byte   VARPSU 9165-9165
  int    VARSTR 9166-9169
  double LONGWT 9170-9182
  byte   INSCOVY1 4416-4417
  byte   INSCOVY2 4418-4419
  byte   AGEY1X 334-335
  byte   AGEY2X 336-337
  byte   POVCATY1 2916-2917
  byte   POVCATY2 2918-2919
using H202.dat;

label variable AGEY1X "Age at the end of year 1 (EDITED/IMPUTED)";
label variable AGEY2X "Age at the end of year 2 (EDITED/IMPUTED)";
label variable INSCOVY1 "HEALTH INSURANCE COVERAGE INDICATOR YEAR 1";
label variable INSCOVY2 "HEALTH INSURANCE COVERAGE INDICATOR YEAR 2";

label define H2020125X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H2020126X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;
		 label define H2021398X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 ANY PRIVATE"
         2 "2 PUBLIC ONLY"
         3 "3 UNINSURED" ;

label define H2021399X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 ANY PRIVATE"
         2 "2 PUBLIC ONLY"
         3 "3 UNINSURED" ;
label define H2022578X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 POOR/NEGATIVE"
         2 "2 NEAR POOR"
         3 "3 LOW INCOME"
         4 "4 MIDDLE INCOME"
         5 "5 HIGH INCOME" ;

label define H2022579X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 POOR/NEGATIVE"
         2 "2 NEAR POOR"
         3 "3 LOW INCOME"
         4 "4 MIDDLE INCOME"
         5 "5 HIGH INCOME" ;

label value AGEY1X H2020125X;
label value AGEY2X H2020126X;
label value INSCOVY1 H2021398X;
label value INSCOVY2 H2021399X;
label value POVCATY1 H2022578X;
label value POVCATY2 H2022579X;

rename *, lower;
save h202, replace;
clear;

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h193dat.zip" "h193dat.zip";
unzipfile "h193dat.zip", replace;
infix
  long   DUID 1-5
  int    PID 6-8
  str    DUPERSID 9-16
  byte   PANEL 17-18
  byte   VARPSU 10288-10288
  int    VARSTR 10289-10292
  double LONGWT 10293-10305
  byte   INSCOVY1 4368-4369
  byte   INSCOVY2 4370-4371
  byte   AGEY1X 334-335
  byte   AGEY2X 336-337
  byte   POVCATY1 2843-2844
  byte   POVCATY2 2845-2846
using H193.dat;

label variable AGEY1X "Age at the end of year 1 (EDITED/IMPUTED)";
label variable AGEY2X "Age at the end of year 2 (EDITED/IMPUTED)";
label variable INSCOVY1 "HEALTH INSURANCE COVERAGE INDICATOR YEAR 1";
label variable INSCOVY2 "HEALTH INSURANCE COVERAGE INDICATOR YEAR 2";

label define H2020125X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H2020126X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;
label define H2021398X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 ANY PRIVATE"
         2 "2 PUBLIC ONLY"
         3 "3 UNINSURED" ;

label define H2021399X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 ANY PRIVATE"
         2 "2 PUBLIC ONLY"
         3 "3 UNINSURED" ;
label define H2022578X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 POOR/NEGATIVE"
         2 "2 NEAR POOR"
         3 "3 LOW INCOME"
         4 "4 MIDDLE INCOME"
         5 "5 HIGH INCOME" ;
label define H2022579X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 POOR/NEGATIVE"
         2 "2 NEAR POOR"
         3 "3 LOW INCOME"
         4 "4 MIDDLE INCOME"
         5 "5 HIGH INCOME" ;

label value AGEY1X H2020125X;
label value AGEY2X H2020126X;
label value INSCOVY1 H2021398X;
label value INSCOVY2 H2021399X;
label value POVCATY1 H2022578X;
label value POVCATY2 H2022579X;

rename *, lower;
save h193, replace;
clear; 

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h183dat.zip" "h183dat.zip";
unzipfile "h183dat.zip", replace; 

infix
  long   DUID 1-5
  int    PID 6-8
  str    DUPERSID 9-16
  byte   PANEL 17-18
  byte   VARPSU 10109-10109
  int    VARSTR 10110-10113
  double LONGWT 10114-10126  
  byte   INSCOVY1 4167-4168
  byte   INSCOVY2 4169-4170
  byte   AGEY1X 334-335
  byte   AGEY2X 336-337
  byte   POVCATY1 2645-2646
  byte   POVCATY2 2647-2648
using H183.dat;

label variable AGEY1X "Age at the end of year 1 (EDITED/IMPUTED)";
label variable AGEY2X "Age at the end of year 2 (EDITED/IMPUTED)";
label variable INSCOVY1 "HEALTH INSURANCE COVERAGE INDICATOR YEAR 1";
label variable INSCOVY2 "HEALTH INSURANCE COVERAGE INDICATOR YEAR 2";

label define H2020125X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H2020126X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;
label define H2021398X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 ANY PRIVATE"
         2 "2 PUBLIC ONLY"
         3 "3 UNINSURED" ;
label define H2021399X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 ANY PRIVATE"
         2 "2 PUBLIC ONLY"
         3 "3 UNINSURED" ;
label define H2022578X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 POOR/NEGATIVE"
         2 "2 NEAR POOR"
         3 "3 LOW INCOME"
         4 "4 MIDDLE INCOME"
         5 "5 HIGH INCOME" ;
label define H2022579X
         -1 "-1 INAPPLICABLE"
         -2 "-2 DETERMINED IN PREVIOUS ROUND"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 POOR/NEGATIVE"
         2 "2 NEAR POOR"
         3 "3 LOW INCOME"
         4 "4 MIDDLE INCOME"
         5 "5 HIGH INCOME" ;

label value AGEY1X H2020125X;
label value AGEY2X H2020126X;
label value INSCOVY1 H2021398X;
label value INSCOVY2 H2021399X;
label value POVCATY1 H2022578X;
label value POVCATY2 H2022579X;

rename *, lower;
save h183, replace;
