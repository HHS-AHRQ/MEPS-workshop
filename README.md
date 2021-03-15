# MEPS Workshop

This repository contains the agenda, presentation slides, and programming exercises for the latest MEPS workshop.

MEPS workshops are designed for health services researchers who have a background or interest in using national health surveys. For questions regarding MEPS workshops, please contact Anita Soni at [WorkshopInfo@ahrq.hhs.gov](mailto:WorkshopInfo@ahrq.hhs.gov). Information on upcoming workshops is posted on the [MEPS website](https://meps.ahrq.gov/about_meps/workshops_events.jsp). Check back regularly for updates.


More information about the Medical Expenditure Panel Survey (MEPS) and additional coding information and exercises can be found in the [MEPS repository](https://github.com/HHS-AHRQ/MEPS).


## Helper programs

To facilitate the programming exercises, the following programs can be used to automate the downloading, unzipping, and conversion of the MEPS data files into SAS or Stata:
* [sas_exercises/Automate_Load_Oct_06_2020.sas](sas_exercises/Automate_Load_Oct_06_2020.sas)
* [stata_exercises/get_data.do](stata_exercises/get_data.do)


## Programming exercises

The SAS, Stata, and R programming exercises are available in the [sas_exercises](sas_exercises),  [stata_exercises](stata_exercises) and [r_exercises](r_exercises) folders:

#### Exercise 1

**National healthcare expenses**, including:
1. Overall expenses (National totals)
2. Percentage of persons with an expense
3. Mean expense per person
4. Mean/median expense per person with an expense, by age group


#### Exercise 2

Purchases and expenses for **narcotic analgesics or narcotic analgesic combos** including:
1. Number of purchases (fills)
2. Total expenditures
3. Out-of-pocket payments
4. Third-party payments

#### Exercise 3
This program illustrates how to **pool MEPS data files** from different years. The example calculates:
1. Percentage of people with Joint Pain / Arthritis (JTPAIN**, ARTHDX)
2. Average expenditures per person, by Joint Pain status (TOTEXP, TOTSLF)


#### Exercise 4
This program includes a **regression example** for persons receiving a flu shot in the last 12 months, including:
1. Percentage of people with a flu shot
2. Logistic regression: to identify demographic factors associated with receiving a flu shot
