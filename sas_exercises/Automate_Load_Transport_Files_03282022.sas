
/***********************************************************************
The program automates downloading a handful of XPORT engine- and
PROC CPORT-created zip SAS transport files from the 
Medical Expenditure Panel Survey (MEPS) website and converting 
them into SAS data sets in pre-created computer folders.
By Pradip Muhuri (Revised 3/28/2022)
************************************************************************/
options symbolgen mprint mlogic;

/* Create four global macro variables, assigning a folder name */

%let zip_folder = c:\data\zip_folder; 
%let xpt_folder = c:\data\xpt_folder; 
%let cpt_folder = c:\data\cpt_folder; 
%let sds_folder = c:\data\sds_folder; 

/****************************************************************************
Create three global macro variable arrays 
     - XPORT engine (with PROC COPY)-created SAS transport file names 
     - PROC CPORT-created SAS transport file names 
(Either of the two macro  variables (Xpt_files and Cpt_files) could have a null value.)
     - both types of SAS transport file names
***************************************************************************/
%let xpt_files = h129 h138 h147 h155 h163 h171 h181 h192 ;
%let cpt_files = h201 h209;
%let total_files = &xpt_files &cpt_files; 

%macro load_meps / minoperator; /* begins the macro definition */
%local j;
%do j=1 %to %sysfunc(countw(&total_files));

/*******************************************************************   
  Step 1: Download zipped SAS transport files to a pre-created folder.
 **********************************************************************/
filename inzip1 "&zip_folder.\%scan(&total_files, &j)ssp.zip";
proc http 
url="https://meps.ahrq.gov/data_files/pufs/%scan(&total_files, &j)ssp.zip"  
	 out=inzip1;
run;

 /**************************************************************************
Step 2: Retrieve the member file's name from the ZIP file.
        Code adapted from Chris Hemedinger, 2015
***************************************************************************/
filename inzip2 zip "&zip_folder.\%scan(&total_files, &j)ssp.zip"; 
	data _null_ ;
	 length fname $200 ;
	 fid=dopen("inzip2");
	 if fid=0 then stop; 
	 fname=dread(fid,1);
	 rc=dclose(fid);
     call symputx('memname',fname);
	 run;
    %put &=memname;

/**************************************************************************
Step 2 (Continued) Unzip SAS transport files using the FTLENAME ZIP Access method and save them in desired folders. Code obtained from Chris Hemedinger, 2015
**************************************************************************/

      %if &xpt_files ne %then %do;
        %if %eval(%scan(&total_files, &j) # &xpt_files) %then %do; 
           filename sit "&xpt_folder.\&memname" ;
         %end; 
      %end;
      %if &cpt_files ne %then %do;
	   %if %eval(%scan(&total_files, &j)  # &cpt_files) %then %do;
	       filename sit "&cpt_folder.\&memname" ;
	   %end;     
      %end;

	/* hat tip: "data _null_" on sas-l */
	data _null_;
infile inzip2(&memname.) lrecl=256 recfm=f length=length eof=eof unbuf; 
      file sit lrecl=256 recfm=n;
	   input;
	   put _infile_ $varying256. length;
	   return;
	 eof:
	   stop;
	run;

/*******************************************************************	 
Step 3: Restore SAS data sets from XPORT engine	(with PROC COPY)-
created SAS transport files  	
**********************************************************************/
%if &xpt_files ne %then %do;
  %if %eval(%scan(&total_files, &j)  # &xpt_files) %then %do;
 	 libname xpt xport "&xpt_folder.\%scan(&total_files, &j).ssp";
 	 libname sds "&sds_folder";  
     		proc copy in=xpt out=sds; 
    		run;
   %end;
  %end;
/*************************************************************************
Step 3 (continued): Restore SAS data sets from PROC CPORT-created from SAS transport files.
*************************************************************************/
 %if &cpt_files ne %then %do;
   %if %eval(%scan(&total_files, &j) #  &cpt_files) %then %do;
     filename cpt "&cpt_folder.\%scan(&total_files, &j).ssp";
     libname sds base "&sds_folder"; 
    	 proc cimport infile=cpt library=sds;
    	 run;
   %end; 
  %end;
 %end;
%mend load_meps; /* ends the macro definition */
%load_meps    /* macro call */

/***************************************************************************
Step 4: Query dictionary tables for information about restored SAS data sets.                
***************************************************************************/
proc sql;
select memname, nobs format =comma9. ,nvar format =comma9.
 from dictionary.tables
 where libname='SDS' and memname like 'H%';
 quit;

