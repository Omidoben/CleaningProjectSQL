
# Nashville Housing Data Cleaning Project
## 

![HouseImage](https://github.com/Omidoben/CleaningProjectSQL/blob/master/pexels-House-pic.jpg?raw=true)




# Overview
This project focuses on cleaning and preparing a raw dataset related to home values in the bustling Nashville real estate market. The goal is to transform the messy data into a structured and usable format for analysis. The dataset was obtained from Kaggle and contains information about housing prices, features, and other relevant factors.
# Tools

PostgrelSQL
# Steps Followed


## 1. Data Extraction

I obtained the raw dataset from Kaggle.com and loaded it into my local folder. The dataset contains 56,448 rows and 19 columns.

## 2. Data Exploration
  - Imported the data into Postgrel Sql
  - Checked for null values, most columns had null values
  - Checked for duplicates


## 3. Data Cleaning

- Standardized the saledate column from a timestamp into a date column
- Populated the null values in propertyaddress column using a self join
- Split the propertyaddress column into address and city
- Split the owneraddress column into three columns; address_split, city_split, and state_split
- Transformed the soldasvacant column (Changed Y to Yes and N to No)
- Removed duplicates from the dataset
- Replaced null values in ownername to "Unkown"
- Feature Engineering: created year, month, and day columns from the Standardizeddate




