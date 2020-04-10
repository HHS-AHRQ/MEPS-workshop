cd "C:\work\MEPS_workshop"
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h201ssp.zip" "h201ssp.zip"
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h197assp.zip" "h197assp.zip"
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h192ssp.zip" "h192ssp.zip"
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h202dat.zip" "h202dat.zip"
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h193dat.zip" "h193dat.zip"
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h183dat.zip" "h183dat.zip"

unzipfile "h201ssp.zip", replace 
unzipfile "h197assp.zip", replace
unzipfile "h192ssp.zip", replace
unzipfile "h202dat.zip", replace
unzipfile "h193dat.zip", replace
unzipfile "h183dat.zip", replace

