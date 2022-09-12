/*********************************************************************
program: 	exercise2.sas

this program generates national totals and per-person averages for narcotic
 analgesics and narcotic analgesic combos care for the u.s. civilian 
 non-institutionalized population (2020), including:
  - number of purchases (fills)  
  - total expenditures 
    (sums all the expenditures from the various sources of payment
     for the prescribed medicine event) 
  - out-of-pocket payments for the prescribed medicine event    
  - third-party payments for the prescribed medicine event    

 input files:
    - 2020 prescribed medicines file
    - 2020 full-year consolidated file

 ************************************************************************************/
/* clear log, output, and odsresults from the previous run automatically */
dm "log; clear; output; clear; odsresults; clear";
proc datasets nolist lib=work  kill; quit; /* delete  all files in the work library */

options nocenter ls=132 ps=79 nodate formchar="|----|+|---+=|-/\<>*" pageno=1;

/*********************************************************************************
 uncomment the next 5 lines of code, only if you want sas to create 
 separate files for log and output   
***********************************************************************************/
/*
%let rootfolder= c:\SASHandsOnSep2022\sas_exercises\exercise_2;
filename mylog "&rootfolder\exercise2_log.txt";
filename myprint "&rootfolder\exercise2_output.txt";
proc printto log=mylog print=myprint new;
run;
*/
/* create use-defined formats and store them in the work folder */
proc format;
   value subpop    
      1 = 'oneplusnacroticetc'
	  2 = 'others';
run;

/***************************************************************************** 
keep the specified variables when reading the input data set and
restrict to observations having therapeutic classification (tc) 
codes for narcotic analgesics or narcotic analgesic combos 
*******************************************************************************/

%let datafolder = c:\meps_data;  /* adjust the folder name if needed */
libname cdata "&datafolder"; 

data work.drug;
  set cdata.h220a (keep=dupersid rxrecidx linkidx tc1s1_1 rxxp20x rxsf20x
                   where=(tc1s1_1 in (60, 191))); 
run;

ods html close; /* this will make the default html output no longer active,
                  and the output will not be displayed in the results viewer.*/
title 'sample dump for pmed records with narcotic analgesics or narcotic analgesic combos, 2020';
proc print data=work.drug (obs=12) noobs;
   var dupersid rxrecidx linkidx tc1s1_1 rxxp20x rxsf20x;
run;


/* sum "rxxp20x and rxsf20x" data to person-level */

proc summary data=work.drug nway;
  class dupersid;
  var rxxp20x rxsf20x;
  output out=work.perdrug (drop = _type_ rename=(_freq_ = n_phrchase))
                  /*# of purchases per person */
             sum=tot_exp oop_exp;
run;

title 'sample dump for person-level expenditures for narcotic analgesics or narcotic analgesic combos';
proc print data=perdrug (obs=3);
sum n_phrchase;
run;

data work.perdrug;
 set perdrug; 
 /* create a new variable for expenses excluding out-of-pocket expenses */
 third_payer   = tot_exp- oop_exp; 
 run;
proc sort data=work.perdrug; by dupersid; run;

/*sort the full-year(fy) consolidated file*/
proc sort data=cdata.h224 (keep=dupersid varstr varpsu perwt20f) out=work.h224;
by dupersid; run;

/*merge the person-level expenditures to the fy puf*/
data  work.personrxlinked;
merge work.h224 (in=person) 
      work.perdrug  (in=rx keep=dupersid n_phrchase tot_exp oop_exp third_payer);
   by dupersid;
   if person and rx then subpop = 1; /*persons with 1+ narcotic analgesics or narcotic analgesic combos */

   else if person ne rx then do;   
         subpop         = 2 ;  /*persons without any purchase of narcotic analgesics or narcotic analgesic combos*/
         n_phrchase  = 0 ;  /*# of purchases per person */
         third_payer = 0 ;
         tot_exp = 0 ;
         oop_exp = 0 ;
    end;
    if person; 
	label   tot_exp= 'total expenses for nacrotic etc'
	        oop_exp = 'out-of-pocket expenses'
            third_payer = 'total expenses minus out-of-pocket expenses'
            n_phrchase  = '# of purchases per person';
run;

/* calculate estimates on use and expenditures*/
ods graphics off; /*suppress the graphics */
ods listing; /* open the listing destination*/
ods exclude statistics /* not to generate output for the overall population */
title 'person-level estimates on expenditures and use for narcotic analgesics or narcotic combos, 2020';
/* when you request sum in proc surveymeans, the procedure computes std by default.*/
proc surveymeans data=work.personrxlinked nobs sumwgt mean stderr sum;
  var  n_phrchase tot_exp oop_exp third_payer ;
  strata  varstr ;
  cluster varpsu;
  weight  perwt20f;
  domain  subpop("oneplusnacroticetc");
  format subpop subpop.;
 run;
title; /* cancel the TITLE and TITLE2 statements */

/* uncomment the next 2 lines of code to close the proc printto if used earlier */
/*
proc printto;
run;
*/
