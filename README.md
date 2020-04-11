# MEPS Workshop

This repository contains the agenda, presentation slides, and programming exercises for the latest MEPS workshop.

MEPS workshops are designed for health services researchers who have a background or interest in using national health surveys. For questions regarding MEPS workshops, please contact Anita Soni at [WorkshopInfo@ahrq.hhs.gov](mailto:WorkshopInfo@ahrq.hhs.gov). Information on upcoming workshops is posted on the [MEPS website](https://meps.ahrq.gov/about_meps/workshops_events.jsp). Check back regularly for updates.


More information about the Medical Expenditure Panel Survey (MEPS) and additional coding information and exercises can be found in the [MEPS repository](https://github.com/HHS-AHRQ/MEPS).


## Helper programs

To facilitate the programming exercises, the following programs can be used to automate the downloading, unzipping, and conversion of the SAS transport files into SAS or Stata:
* [sas_exercises/Download_Data_from_MEPS_Site_rev.sas](sas_exercises/Download_Data_from_MEPS_Site_rev.sas)
* [stata_exercises/download_PUF.do](stata_exercises/download_PUF.do)


## Programming exercises

The SAS and Stata programming exercises are available in the [sas_exercises](sas_exercises) and [stata_exercises](stata_exercises) folders:

#### Exercise 1

National healthcare expenses for 2017, including:
1. Overall expenses
2. Percentage of persons with an expense
3. Mean expense per person with an expense

Data files needed:
[FYC 2017 (h201)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-201)


#### Exercise 2

Purchases and expenses for narcotic analgesics or narcotic analgesic combos for 2017 including:
1. Total expense for narcotic analgesics or narcotic analgesic combos
2. Total number of purchases of narcotic analgesics or narcotic analgesic combos
3. Total number of persons purchasing one or more narcotic analgesics or narcotic analgesic combos
4. Average total out of pocket and third party payer expense for narcotic analgesics or narcotic analgesic combos per person

Data files needed:
[FYC 2017 (h201)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-201) and
[PMED 2017 (h197a)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-197A)

#### Exercise 3
This program illustrates how to pool MEPS data files from different years. The example used is the MEPS population ages 26-30 who are uninsured but have high income.

Data files needed:
[FYC 2017 (h201)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-201) and
[FYC 2016 (h192)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-192)

#### Exercise 4
This program illustrates how to pool MEPS longitudinal data files from different panels. The example used is panels 18-20, population ages 26-30 who are uninsured but have high income in the first year.

Longitudinal data files needed:
[Panel 20 (h193)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-193),
[Panel 19 (h183)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-183), and
[Panel 18 (h172)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-172)

#### BRR example (Stata only)
This program compares standard error estimates calculated by:
1. Balanced Repeated Replicates (BRR) - using explicit loop
2. Balanced Repeated Replicates (BRR) - using Stata's internal commands
3. Taylor Series Linearization (Stata default)

Data files needed:
[FYC 2017 (h201)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-201)


