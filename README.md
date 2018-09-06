# MEPS Workshop

This repository contains the agenda, presentation slides, and programming exercises for the latest MEPS workshop.

MEPS workshops are designed for health services researchers who have a background or interest in using national health surveys. For questions regarding MEPS workshops, please contact Anita Soni at [WorkshopInfo@ahrq.hhs.gov](mailto:WorkshopInfo@ahrq.hhs.gov). Information on upcoming workshops is posted on the [MEPS website](https://meps.ahrq.gov/about_meps/workshops_events.jsp). Check back regularly for updates.


More information about the Medical Expenditure Panel Survey (MEPS) and additional coding information and exercises can be found in the [MEPS repository](https://github.com/HHS-AHRQ/MEPS).

## Programming exercises

The SAS and Stata programming exercises are available in the [sas_exercises](sas_exercises) and [stata_exercises](stata_exercises) folders:

#### Exercise 1

National healthcare expenses for 2016, including:
1. Overall expenses
2. Percentage of persons with an expense
3. Mean expense per person with an expense

Data files needed:
[FYC 2016 (h192)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-192)


#### Exercise 2

Purchases and expenses for narcotic analgesics or narcotic analgesic combos for 2016 including:
1. Total expense for narcotic analgesics or narcotic analgesic combos
2. Total number of purchases of narcotic analgesics or narcotic analgesic combos
3. Total number of persons purchasing one or more narcotic analgesics or narcotic analgesic combos
4. Average total out of pocket and third party payer expense for narcotic analgesics or narcotic analgesic combos per person

Data files needed:
[FYC 2016 (h192)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-192) and
[RX 2016 (h188a)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-188A)

#### Exercise 3
This program illustrates how to pool MEPS data files from different years (2015 and 2016). The example used is population age 26 30 who are uninsured but have high income.

Variables with year-specific names must be renamed before combining files in this program the insurance coverage variables INSCOV15 and INSCOV16 are renamed to INSCOV.

Data files needed:
[FYC 2016 (h192)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-192) and
[FYC 2015 (h181)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-181)

#### Exercise 4
This program illustrates how to pool MEPS longitudinal data files from different panels. The example used is panels 17-19 population age 26-30 who are uninsured but have high income in the first year.

Longitudinal data files needed:
[Panel 19 (h183)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-183),
[Panel 18 (h172)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-172), and
[Panel 17 (h164)](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-164)
