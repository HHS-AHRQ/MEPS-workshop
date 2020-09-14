*Automate_Load_rev.sas;
/***********************************************************************
This program automates the following process:
- downloading of zipped SAS Trasport files from the MEPS website
- unzipping of those files
- restoring of them to SAS data sets
	PROC COPY (SAS XPORT Engine) vs. PROC CIMPORT
Written by: Pradip Muhuri - Revised 8/25/2020  
Acknowledgements: Thanks to SAS(R) Institute for providing technical support 
to the revision/expansion of the original program.
************************************************************************/
options  nosymbolgen nomlogic nomprint; /* Options may be turned on when needed */


/* Create 4 global macro variables for naming folders that were already created  */

%let zipfiles = C:\Data\zipfiles ;  /* Save downloaded zipped files */
%let xptfiles = C:\Data\xptfiles;   /* Save extracted PROC COPY/XPORT-created transport files */
%let cptfiles = C:\Data\cptfiles;   /* Save extracted PROC CIMPORT-created transport files */
%let MySDS = C:\Data\MySDS;         /* Save SAS data sets restored from transport files */

/****************************************************************************
* Create 2 global macro variables containing 
*	- a list of data set names (for 2017 and prior year files )
*	- another list of data set names (for 2018 and later year files)
*****************************************************************************/

%let ds17_and_prior = h201 h183 h193 h202;
%let ds18_and_later = h209 h206a ;

%put &=ds17_and_prior;
%put &=ds18_and_later;



%macro load_MEPS(filename) / minoperator ;

   /*******************************************************************   
   ** Task 1: Download zipped SAS transport files from the MEPS web site
   ** using PROC HTTP
   **********************************************************************/
	filename inzip1 "&zipfiles.\%qlowcase(&filename..ssp.zip)";
	proc http 
	 url="https://meps.ahrq.gov/data_files/pufs/&filename.ssp.zip"  
	 out=inzip1;
	run;

    /*****************************************************************************
	* Task 2: Unzip them into the folder of your choice 
	* (defined by a macro variable - created earlier)
	* Using the FILENAME ZIP method
    ******************************************************************************/
	/*
	From: https://blogs.sas.com/content/sasdummy/2015/05/11/using-filename-zip-to-unzip-and-read-data-files-in-sas/ 
	*/
	
	
    /* Read the "members" (files) from the ZIP file */
	filename inzip2 zip "&zipfiles.\&filename..ssp.zip"; 
	data contents(keep=memname isFolder);
	 length memname $200 isFolder 8;
	 fid=dopen("inzip2");
	 if fid=0 then
	  stop;
	 memcount=dnum(fid);
	 do i=1 to memcount;
	  memname=dread(fid,i);
	  /* check for trailing / in folder name */
	  isFolder = (first(reverse(trim(memname)))='/');
	  output;
	 end;
	 rc=dclose(fid);
	 /* this could be automated if more than one file is expected in a zip */
	 call symputx('memname',memname);
	run;
	 %PUT &=MEMNAME;
	/* create a report of the ZIP contents */
	title "Files in the ZIP file";
	proc print data=contents noobs N;
	run;

   %IF %eval(&filename  # &ds18_and_later) %then %do;
	  filename sit "&cptfiles.\%qlowcase(&memname)" ;
	  %end;

	%else %if %eval(&filename # &ds17_and_prior) %then  %do;
	  filename sit "&xptfiles.\%qlowcase(&memname)" ;
     %end;


	/* hat tip: "data _null_" on SAS-L */
	data _null_;
	   /* using member syntax here */
	   infile inzip2(&memname.) 
	       lrecl=256 recfm=F length=length eof=eof unbuf;
    	   file sit lrecl=256 recfm=N;
	   input;
	   put _infile_ $varying256. length;
	   return;
	 eof:
	   stop;
	run;
	
  /*******************************************************************	 
  * Task 3: Restore the files in the original form as SAS data sets
  ********************************************************************/

 /* Use PROC COPY to restore the SAS Transport files for 2017 or prior years */
 %IF %eval(&filename  # &ds17_and_prior) %then %do;
 	 libname xpt xport "&xptfiles.\&memname";
	 libname sds "&MySDS";  
      proc copy in=xpt out=sds; run;
  %end;
  /* Use PROC CIMPORT to restore the SAS Transport files for 2018 or later years */
  %else %if %eval(&filename #  &ds18_and_later) %then %do;
  	 Filename cpt "&cptfiles.\&memname"; 
     libname sds base "&MySds"; 
         PROC CIMPORT INFILE=cpt LIBRARY=sds;
     RUN;
  %end;
%mend;
%load_MEPS(h201)

%load_MEPS(h183)
%load_MEPS(h193)
%load_MEPS(h202)

%load_MEPS(h206a)
%load_MEPS(h209)


/*********************************************************
* Create a summary table for all the SAS data sets restored 
* from Transport files (outside of the above macro (optional)               
***********************************************************/
proc sql;
select memname,
       nobs format =comma9.
       ,nvar format =comma9.
from dictionary.tables
 where libname='SDS' and memname like "H%";
 quit;



