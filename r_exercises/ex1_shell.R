# -----------------------------------------------------------------------------
# This program generates the following estimates on national health care for 
# the U.S. civilian non-institutionalized population, 2020:
#  - Overall expenses (National totals)
#  - Percentage of persons with an expense
#  - Mean expense per person
#  - Mean/median expense per person with an expense:
#    - Mean expense per person with an expense
#    - Mean expense per person with an expense, by age group
#    - Median expense per person with an expense, by age group
#
# Input file:
#  - C:/MEPS/h224.dta (2020 Full-year file - Stata format)
#
# -----------------------------------------------------------------------------

# Install and load packages ---------------------------------------------------

# Can skip this part if already installed


  

# Run this part each time you re-start R




# Set options to deal with lonely psu





# Read in data from FYC file --------------------------------------------------
 
# Option 1: use 'MEPS' package



# Option 2: Use Stata format (recommended for Data Year 2017 and later)



# View data


 

# Keep only needed variables --------------------------------------------------
# - codebook: https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_codebook.jsp?PUFId=h224

# Using tidyverse syntax. The '%>%' is a pipe operator, which inverts
# the order of the function call. For example, mean(x) becomes x %>% mean
  





  
# Add variables for persons with any expense and persons under 65 -------------

 





# QC check on new variables
  
 






# Define the survey design ----------------------------------------------------
    
 





  
# Calculate estimates ---------------------------------------------------------
#  - Overall expenses (National totals)
#  - Percentage of persons with an expense
#  - Mean expense per person
#  - Mean/median expense per person with an expense:
#    - Mean expense per person with an expense
#    - Mean expense per person with an expense, by age group
#    - Median expense per person with an expense, by age group

# Overall expenses (National totals)




# Percentage of persons with an expense




# Mean expense per person



  
  
# Mean/median expense per person with an expense --------------------

# Subset design object to people with expense:



  
# Mean expense per person with an expense




# Mean expense per person with an expense, by age category




# Median expense per person with an expense, by age category



