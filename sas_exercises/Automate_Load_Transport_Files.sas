
/***********************************************************************
Automate_Load_Transport_Files.sas
The program automates the following tasks: 
1) downloading zip SAS transport files, 
2) unzipping files, 
3) restoring SAS data sets from transport files, and 
4) retrieving information from restored SAS data sets for 
   MEPS data years 2009-2018 from the AHRQ website.
************************************************************************/
options symbolgen mprint mlogic;

/* Create 4 global macro variable, each is assigned folder a path (value) */

%LET Zip_folder = C:\Data\Zip_folder; /* Folder for ZIP files */
%LET Xpt_folder = C:\Data\Xpt_folder; /* Folder for XPORT transport files */
%LET Cpt_folder = C:\Data\Cpt_folder; /* Folder for CPORT transport files */
%LET SDS_folder = C:\Data\SDS_folder; /* Folder for SAS data sets */

/****************************************************************************
Create 3 global macro variables containing 
	- a list of XPORT engine (with PROC COPY)-created transport file names 
 	- a list of PROC CPORT-created transport file names 
      - a list of all transport file names to iterate over
Either of the first two macro variables could have a null value.      ****************************************************************************/
%LET Xpt_files = h192 h181 h171 h163 h155 h147 h138 h129; /* XPORT engine (with PROC COPY)-created transport files */
%LET Cpt_files = h201 h209; /* PROC CPORT-created files */
%LET Total_files = &Xpt_files &Cpt_files; /* resolves to 10 files’ names */

%macro Load_MEPS / minoperator; /* begins the macro definition */
%local j;
%do j=1 %to %sysfunc(countw(&total_files));

/*******************************************************************   
  Task 1: Download “ZIP SAS transport files” using PROC HTTP.
  Notice the macro variable and/or macro variable value in the 
  the FILENAME statement and the URL= argument (query string) 
**********************************************************************/
/* Create a name for the downloaded ZIP file saved on the local computer */ 

Filename inzip1 "&Zip_folder.\%scan(&total_files, &j)ssp.zip";
proc http 
url="https://meps.ahrq.gov/data_files/pufs/%scan(&total_files, &j)ssp.zip"  
	 out=inzip1;
run;

 /**************************************************************************
  Task 2, Part 1 (DATA step): Unzip files using the FILENAME ZIP method and
  create reports of the zip content. 
  Reference: Chris Hemedinger on The SAS Dummy (May 11, 2015)
***************************************************************************/

/* Assign a fileref with the ZIP method */  
Filename inzip2 zip "&Zip_folder.\%scan(&total_files, &j)ssp.zip"; 
	Data contents(keep=memname isFolder);
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

     /* this could be automated if more than 1 file is expected in a zip */
	 call symputx('memname',memname);
	run;
	 %PUT &=MEMNAME;
	/* create a report of the ZIP contents */
	title "Files in the ZIP file";
	proc print data=contents noobs N;
	run;
      title; /* Removes all existing titles for the output */

/**************************************************************************
  Task 2, Part 2 (DATA _NULL_ step): 
1) Save the “unzip transport file”.  
2) Write CONDITIONAL macro statements to specify the physical file name 
associated with the fileref on the FILENAME statement. 
3) Transport file: XPORT engine/PROC COPY- or PROC CPORT-created. 
4) Check whether &xpt_files is not null.
5) Check whether the individual item (macro variable) is in the target
list (also a macro variable) using %IF %EVAL …. # Operator.
**************************************************************************/

	%if &xpt_files ne %then %do; 
	   %if %eval(%scan(&total_files, &j) # &xpt_files) %then  %do;
                  filename sit "&Xpt_folder.\&memname" ;
         %end;
      %end;

	%if &cpt_files ne %then %do; 
	   %IF %eval(%scan(&total_files, &j)  # &cpt_files) %then %do;
	       filename sit "&Cpt_folder.\&memname" ;
	    %end;
       %end;

	/* hat tip: "data _null_" on SAS-L */
	Data _null_;
	   /* using member syntax here */
	   infile inzip2(&memname.) 
           lrecl=256 recfm=F length=length eof=eof unbuf; 

/* reference the zip file content as a member of the INZIP2 fileref */
    	   file sit lrecl=256 recfm=N;
	   input;
	   put _infile_ $varying256. length;
	   return;
	 eof:
	   stop;
	run;

/*******************************************************************	 
Task 3, Part 1: Restore XPORT engine (with PROC COPY)-created transport 
Files into SAS data sets
1) Use conditional macro statements to specify SAS Library associated with
libref on the LIBNAME 
statement.
2) Check whether &xpt_files is not null.
3) Check whether the individual item (macro variable) is in the target
list (also a macro variable) using %IF %EVAL …. # Operator.
**********************************************************************/

%if &xpt_files ne %then %do; 
 %IF %eval(%scan(&total_files, &j)  # &xpt_files) %then %do;
 	 libname xpt xport "&Xpt_folder.\%scan(&total_files, &j).ssp";
	 libname sds "&SDS_folder";  
      proc copy in=xpt out=sds; run;
  %end;
 %end;

/*************************************************************************
Task 3, Part 2: Restore PROC CPORT-created transport files into SAS data sets
1) Use conditional macro statements to specify the physical file name 
associated with the fileref for the transport file 
2) Check whether &cpt_files is not null.
3) Check whether the individual item (macro variable) is in the target
list (also a macro variable) using %IF %EVAL …. # Operator.
*************************************************************************/


%if &cpt_files ne %then %do; 
  %if %eval(%scan(&total_files, &j) #  &cpt_files) %then %do;
  	 Filename cpt "&Cpt_folder.\%scan(&total_files, &j).ssp"; 
     libname sds base "&SDS_folder"; 
         PROC CIMPORT INFILE=cpt LIBRARY=sds;
     RUN;
   %end;
 %end;
%end;

%mend Load_MEPS; /* ends the macro definition */

%Load_MEPS    /* Macro call */


/***************************************************************************
Task 4: Query dictionary tables for information about SAS data sets
restored from transport files.                
***************************************************************************/
proc sql;
select memname, nobs format =comma9. ,nvar format =comma9.
 from dictionary.tables
 where libname='SDS' and memname like "H%";
 quit;

