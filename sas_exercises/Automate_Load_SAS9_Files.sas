

/***********************************************************************
*Automate_Load_SAS9_Files.sas;

This program:
- downloads zipped SAS 9 files into the work folder from the AHRQ website
- creates metadata file based on the downloaded zip file 
- unzips the files into a permanent SAS data set in the desired folder

Written by Pradip Muhuri - 8/19/2021
************************************************************************/

/* Clear log, output, and ODSRESULTS from the previous run automatically */
DM "Log; clear; output; clear; odsresults; clear";
proc datasets lib=work nolist kill; quit; /* Delete  all files in the WORK library */

options symbolgen mprint mlogic;

* Create a global macro variable containing zip filenames of interest;
%LET Total_files = h209v9 h201v9 h206av9;
%let Path=C:\SAS_Tech_Support;
%*let Path=C:\MEPS_Data;
*** STEP 1: Download zip SAS dataset;
%macro Load_MEPS; 
%local j;
%do j=1 %to %sysfunc(countw(&total_files));
filename GoThere "%sysfunc(getoption(work))/%scan(&total_files, &j).zip" ;
%put %sysfunc(pathname(work));
 proc http 
   %if %scan(&total_files, &j)=h209v9 %then %do;
     url="https://meps.ahrq.gov/data_files/pufs/%scan(&total_files, &j).zip"
   %end;

   %else %if %scan(&total_files, &j)=h201v9 %then %do;
     url="https://meps.ahrq.gov/data_files/pufs/h201/%scan(&total_files, &j).zip"
   %end;

   %else %if %scan(&total_files, &j)=h206av9 %then %do;
     url="https://meps.ahrq.gov/data_files/pufs/h206a/%scan(&total_files, &j).zip"
   %end;
   out=GoThere;
debug level=2;
run;

/*************************************************************************************** 
Nonmacro codes in STEPS 2 and 3 have been adapated 
from SAS Blogs by Chris Hemedinger
https://blogs.sas.com/content/sasdummy/2015/05/11/using-filename-zip-to-unzip-and-read-data-files-in-sas/*/
*****************************************************************************************/

*** STEP 2: Create a metadata file based on the downloaded zip file;
Filename inzip zip "%sysfunc(getoption(work))/%scan(&total_files, &j).zip";
data content_%scan(&total_files, &j)(keep=memname);
 length memname $200;
 fid=dopen("inzip");
 if fid=0 then
  stop;
 memcount=dnum(fid);
 do i=1 to memcount;
  memname=dread(fid,i);
  output;
 end;
 rc=dclose(fid);
 call symputx ('memname', memname);
run;
 %put &=memname;
/* create a report of the ZIP contents */
title "Files in the ZIP file";
proc print data=content_%scan(&total_files, &j) noobs N;
run;

*** STEP 3: Unzip the file into a SAS data set;
 filename ds "&Path\%scan(&total_files, &j).sas7bdat" ;
data _null_;
   /* reference the member name WITH folder path */
   infile inzip(&memname) 
	  lrecl=256 recfm=F length=length eof=eof unbuf;
   file   ds lrecl=256 recfm=N;
   input;
   put _infile_ $varying256. length;
   return;
 eof:
   stop;
run;
%end;
%mend Load_MEPS; /* ends the macro definition */
%Load_MEPS    /* Macro call */


/***************************************************************************
*Step 4: Query dictionary tables for information about SAS data sets
* restored from zip files.                
***************************************************************************/
Libname Perma "&Path";
proc sql;
select memname
       ,nobs format =comma9.
       ,nvar format =comma9.
 from dictionary.tables
 where libname='PERMA' and memname like "H%";
 quit;

