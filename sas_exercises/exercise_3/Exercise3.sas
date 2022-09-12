
/******************************************************************************************
program:      exercise3.sas

 this program pools 2018, 2019 and 2020 MEPS data and calculates  
  - proportion of persons diagnosed with bladder cancer
  - average expenditures and amount paid by self/family per person 
     by bladder cancer diagnosis status 
  - standard errors by specifying common variance structure.

 input files:
  - 2018 full-year consolidated file
  - 2019 full-year consolidated file
  - 2020 full-year consolidated file
  - 1996-2020 pooled linkage variance estimation (PLVE) file
**********************************************************************/

/* clear log, output, and odsresults from the previous run automatically */
dm "log; clear; output; clear; odsresults; clear";
proc datasets nolist lib=work kill; quit; /* delete  all files */

options nocenter ls=132 ps=79 nodate formchar="|----|+|---+=|-/\<>*" pageno=1;
options varlenchk = nowarn;

/*********************************************************************************
 uncomment the next 5 lines of code, only if you want sas to create 
    separate files for log and output 
***********************************************************************************/
/*
%let rootfolder= c:\SASHandsOnSep2022\sas_exercises\exercise_3;
filename mylog "&rootfolder\exercise3_log.txt";
filename myprint "&rootfolder\exercise3_output.txt";
proc printto log=mylog print=myprint new;
run;
*/
/* create use-defined formats and store them in a catalog called formats in the work folde */

%let datafolder = c:\meps_data;  /* adjust the folder name, if needed */
libname new "&datafolder"; 

/* create 3 macro variables, assigning a list of variables to each */
%let kept_vars_2018 =  dupersid panel  perwt18f cancerdx cabladdr totexp18 totslf18;
%let kept_vars_2019 =  dupersid panel  perwt19f cancerdx cabladdr totexp19 totslf19;
%let kept_vars_2020 =  dupersid panel  perwt20f cancerdx cabladdr totexp20 totslf20;

/************************************************************************************************ 
concatenate 2018, 2019 and 2020 full year consolidated files 
use keep= and rename= data set options on the set statement for effeciency
*************************************************************************************************/
data meps_181920;
 set new.h209v9 (keep= &kept_vars_2018
                 rename=(totexp18=totexp
                         totslf18=totslf) in=a)
     new.h216 (keep= &kept_vars_2019
                 rename=(totexp19=totexp
                         totslf19=totslf) in=b)
     new.h224 (keep= &kept_vars_2020
                 rename=(totexp20=totexp
                         totslf20=totslf) in=c);

  /* create new variable (year) for data-checks */
      if a =1 then year=2018;
      else if b=1 then year=2019;
	  else if c=1 then year=2020;

  /* create a new weight variable by dividing the original weight by 3 for the pooled data set */
      if year = 2018 then perwtf = perwt18f/3;
      else if year = 2019 then perwtf = perwt19f/3;
      else if year = 2020 then perwtf = perwt20f/3;

    /* create a new variable: bladder_cancer */
        if cabladdr = 1 then bladder_cancer = 1; 
        else if cabladdr = 2 | cancerdx = 2 then bladder_cancer = 0;
		else if cabladdr < 0 then bladder_cancer = .;
    
     label totexp = 'total health care expenses 2018-2020'
         totslf='amount paid by self/family 2018-2020';
 run;

/* sort the pooled 2018-2020 meps file by dupersid before merging with the PLVE file */

proc sort data=meps_181920;
  by dupersid panel;
run;
/***********************************************************************
- change the 8-character dupersid to 10-character dupersid 
by adding the panel number to DUPERSIDs of panel 22 year 2017 
and panels 1-21 in the PLVE file 
- there is no year variable in the PLVE file 
- implement this change by using the LENGTH and STRIP functions as folows
*************************************************************************/

  data vsfile ;
    length dupersid $10;
    set new.h36u20 (rename=(dupersid=t_dupersid));
		if length(strip(t_dupersid))=8 then 
          dupersid=cats(put(panel,z2.), t_dupersid);
  	    else dupersid = t_dupersid;   
  drop t_dupersid;
run;

/* sort the PLVE file for panels 22-25 by dupersid before match-merging ...*/
proc sort data= vsfile (where = (panel in (22,23,24,25))) nodupkey
   out=sorted_vsfile ;
 by dupersid panel;
 run;


/* merge the pooled 2018-2020 meps data file with the PLVE file for panels 22-25 */

data meps_181920_m;
 merge meps_181920 (in=a) sorted_vsfile ;
   by dupersid panel;
 if a;
run;

ods graphics off;
title 'meps pooled files, 2018-2020';
title2 'proportion of persons diagnosed with bladder cancer';
proc surveymeans data=meps_181920_m  nobs mean stderr sum;
    var bladder_cancer;
    stratum stra9620;
	cluster psu9620;
    weight perwtf;
run;
ods select summary domain;
title2 'average expenditures and amount paid by self/family per person';
proc surveymeans data=meps_181920_m  nobs mean stderr sum;
    var totexp totslf;
    stratum stra9620;
	cluster psu9620;
    weight perwtf;
	domain bladder_cancer;
run;
ods select all; /* clear the SELECT lists for all destinations*/
title;  /* cancel the TITLE and TITLE2 statements */


/* uncomment the next 2 lines of code to close the proc printto if used earlier */
/*
proc printto;
run;
*/
