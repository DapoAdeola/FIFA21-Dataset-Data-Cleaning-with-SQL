# FIFA21-Dataset-Data-Cleaning-with-SQL

## Introduction

The FIFA 21 video game boasts an extensive dataset of player and team statistics, commonly referred to as the FIFA 21 dataset. While this dataset holds valuable insights into player performance and team strategies, it often suffers from data quality issues that must be addressed before meaningful analysis can take place.

Data cleaning, the process of identifying and rectifying flaws, inconsistencies, and inaccuracies in a dataset, is essential for ensuring the accuracy, completeness, and reliability of data in any analysis project. However, tackling data cleaning in large datasets like FIFA 21's can be daunting and time-consuming.

Fortunately, SQL (Structured Query Language) offers an efficient solution for cleaning and transforming data. With its diverse set of functions and operations designed for data manipulation in relational databases, SQL is widely recognized for its effectiveness in data cleaning tasks.

In this article, we will explore how SQL can be employed to enhance the quality of the FIFA 21 dataset. We'll outline common data quality issues encountered in the dataset and demonstrate how SQL queries can effectively address them. Additionally, we'll provide SQL code samples to illustrate cleaning techniques and best practices. By the end of this article, readers will gain a solid understanding of leveraging SQL for efficient data cleaning and transformation.

## Understanding the FIFA 21 Dataset

The FIFA 21 dataset comprises comprehensive information on top football players worldwide, encompassing their biographical details, performance metrics, and in-game attributes. This dataset facilitates assessments of player valuations, analysis of player and team performance, and predictions of future outcomes.

However, the FIFA 21 dataset is plagued by significant data quality challenges, including duplicate entries, missing data, inconsistent values, and outliers. Moreover, certain attributes are represented in various units, complicating analysis and interpretation.

Cleaning the FIFA 21 dataset presents a formidable task, requiring effective identification and resolution of data quality issues. Moreover, with over 18,000 entries, manual cleaning approaches may prove impractical. Therefore, leveraging SQL to automate data cleaning processes and streamline data transformation emerges as an efficient strategy for preparing the dataset for analysis.

The dataset [FIFA21](https://www.kaggle.com/datasets/yagunnersya/fifa-21-messy-raw-dataset-for-cleaning-exploring)

## The Dataset
Taking a look at the dataset

```sql
SELECT TOP 100 *
FROM [dbo].[fifa21 raw data v2];
```
To check further
```sql
EXEC sp_help '[dbo].[fifa21 raw data v2]';
```
We have 77 Columns with different data types.
```sql
SELECT COUNT(*) AS Row_Count
FROM [dbo].[fifa21 raw data v2];
```
There are 18,979 rows in our dataset.

## Data Cleaning Process
### 1. Checking for duplicates
The initial step in the data cleaning process involves checking for duplicates in our dataset. Duplicate values can distort results, introduce errors, and undermine the accuracy and reliability of our data.
```sql
SELECT LongName, Age, Club, Nationality, COUNT(*) AS Count
FROM [dbo].[fifa21 raw data v2]
GROUP BY LongName, Age, Club, Nationality
HAVING COUNT(*) > 1;
```
Checking further using the where clause we realise the player PENG WANG went out on a loan why the multiple entries.
```sql
SELECT LongName, Age, Club, Nationality, Contract
FROM [dbo].[fifa21 raw data v2]
WHERE LongName = 'Peng Wang' AND Age = 27;
```
