# MEPS Workshop

This repository contains the agenda, presentation slides, and programming exercises for the latest MEPS workshop.

MEPS workshops are designed for health services researchers who have a background or interest in using national health surveys. For questions regarding MEPS workshops, please contact Anita Soni at [WorkshopInfo@ahrq.hhs.gov](mailto:WorkshopInfo@ahrq.hhs.gov). Information on upcoming workshops is posted on the [MEPS website](https://meps.ahrq.gov/about_meps/workshops_events.jsp). Check back regularly for updates.


More information about the Medical Expenditure Panel Survey (MEPS) and additional coding information and exercises can be found in the [MEPS repository](https://github.com/HHS-AHRQ/MEPS).


## Helper programs

To facilitate the programming exercises, the following programs can be used to automate the downloading, unzipping, and conversion of the MEPS data files into SAS or Stata:
* [sas_exercises/Automate_Load_Fall2020.sas](sas_exercises/Automate_Load_Fall2020.sas)
* [stata_exercises/data.do](stata_exercises/data.do)


## Programming exercises

The SAS, Stata, and R programming exercises are available in the [sas_exercises](sas_exercises),  [stata_exercises](stata_exercises) and [r_exercises](r_exercises) folders:

#### Exercise 1

**National healthcare expenses**, including:
1. Overall expenses
2. Percentage of persons with an expense
3. Mean expense per person with an expense


#### Exercise 2

Purchases and expenses for **narcotic analgesics or narcotic analgesic combos** including:
1. Expenditures
2. Number of fills
4. Out of pocket and third party payments

#### Exercise 3
This program illustrates how to **pool MEPS data files** from different years. The example calculates out-of-pocket payments for the MEPS population ages 26-30 who are uninsured but have high income.


#### Exercise 4
This program illustrates how to **pool MEPS longitudinal data files** from different panels. The example shows insurance coverage in the second year in MEPS, among the population ages 26-30 who are uninsured but have high income in the first year.
