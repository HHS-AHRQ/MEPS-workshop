/************************************************************************************************/
/* This program downloads the data needed for all the exercises in ascii format and             */
/* converts it to Stata format (.dta)                                                           */
/*                                                                                              */                                            
/* PC Users should create a directory "C:\MEPS\DATA, or modify the stata program to change      */
/* the location to which the data will be written                                               */ 
/*                                                                                              */
/* Users of Macs or Linux computers must modify the code  to change the location because        */
/* local drives aren't referred to with letters (e.g. c:)                                       */
/*                                                                                              */
/************************************************************************************************/
set more off
capture log close
clear
cd c:\MEPS\DATA

/* 2017 & 2018 Full Year Consolidated Files */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h209dat.zip" "h209dat.zip"
unzipfile "h209dat.zip", replace 
do https://meps.ahrq.gov/data_stats/download_data/pufs/h209/h209stu.txt
rename *, lower
save h209, replace

copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h201dat.zip" "h201dat.zip"
unzipfile "h201dat.zip", replace 
do https://meps.ahrq.gov/data_stats/download_data/pufs/h201/h201stu.txt
rename *, lower
save h201, replace

/* 2018 Rx files */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h206adat.zip" "h206adat.zip"
unzipfile "h206adat.zip", replace 
do https://meps.ahrq.gov/data_stats/download_data/pufs/h206a/h206astu.txt
rename *, lower
save h206a, replace

/* BRR weights file */
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h36brr18dat.zip" h36brr18dat.zip
unzipfile "h36brr18dat.zip", replace 
do https://meps.ahrq.gov/mepsweb/data_stats/download_data/pufs/h36brr/h36brr18stu.txt
rename *, lower
save h36brr, replace

