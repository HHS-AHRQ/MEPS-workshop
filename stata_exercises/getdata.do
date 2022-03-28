cd c:\MEPS
* 2019 Full-Year Consolidated File 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h216/h216dta.zip" "h216dta.zip", replace
unzipfile "h216dta.zip", replace 
use h216, clear
rename *, lower
save h216, replace

* 2018 Full-Year Consolidated File 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h209/h209dta.zip" "h209dta.zip", replace
unzipfile "h209dta.zip", replace 
use h209, clear
rename *, lower
save h209, replace

* 2017 Full-Year Consolidated File
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h201/h201dta.zip" "h201dta.zip", replace
unzipfile "h201dta.zip", replace
use h201, clear
rename *, lower 
save h201, replace

* 2019 Prescription Drug File 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h213a/h213adta.zip" "h213adta.zip", replace
unzipfile "h213adta.zip", replace 
use h213a, clear
rename *, lower
save h213a, replace

* Pooled linkage file 
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h036/h36u19dta.zip" "h36u19dta.zip", replace
unzipfile "h36u19dta.zip", replace
use h36u19, clear
rename *, lower 
save h36u19, replace

* BRR weight file
copy "https://meps.ahrq.gov/mepsweb/data_files/pufs/h036brr/h36brr19dta.zip" "h36brr19.zip", replace
unzipfile "h36brr19.zip", replace 
use h36brr19, clear
rename *, lower
save h36brr19, replace





