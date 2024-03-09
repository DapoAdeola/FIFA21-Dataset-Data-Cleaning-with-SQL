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
### 1. Checking for duplicates.
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

### 2. Checking for NULL values.
We look for null values using NULL and IS NULL function.
The query shows that there are no null data in the most relevant columns.
```sql
SELECT COUNT(*) AS COUNT
FROM [dbo].[fifa21 raw data v2]
WHERE Name IS NULL
  OR LongName IS NULL
  OR Age IS NULL
  OR Nationality IS NULL
  OR Club IS NULL
  OR photoUrl IS NULL
  OR playerUrl IS NULL;
```

### 3. Removing Unnecessary Columns.
We can move forward by eliminating columns that are not essential for our analysis.
Since the photoUrl link and the playerUrl doesn’t function, it's prudent to remove both to streamline our workflow.
```sql
ALTER TABLE [dbo].[fifa21 raw data v2]
DROP COLUMN photoUrl;

ALTER TABLE [dbo].[fifa21 raw data v2]
DROP COLUMN playerUrl;
```

### 4. Changing the column name LongName. 
Renaming the 'LongName' column to 'Full_Name' was accomplished using the SP_RENAME stored procedure. This method was chosen for its simplicity and efficiency in modifying the database schema. Stored procedures offer pre-compiled code blocks that can be executed in the database, providing a reusable solution without the need for rewriting code.
Additionally, employing stored procedures can enhance database security by controlling access to specific operations and improve performance by reducing network traffic for executing SQL statements. Overall, leveraging stored procedures is a powerful strategy for enhancing database functionality and performance.
```sql
SP_RENAME '[dbo].[fifa21 raw data v2].LongName', 'Full_Name', 'COLUMN';
```
Further we make naming nomenclature uniform by capitalism the first letter
```sql
--Replace first letter of each name with a capital letter
UPDATE [dbo].[fifa21 raw data v2]
SET Full_Name = UPPER(LEFT(Full_Name, 1)) + SUBSTRING(Full_Name, 2, CHARINDEX(' ', Full_Name + ' ', 2) - 2) +
           ' ' + UPPER(LEFT(SUBSTRING(Full_Name, CHARINDEX(' ', Full_Name + ' ', 2) + 1, LEN(Full_Name)), 1)) +
           SUBSTRING(SUBSTRING(Full_Name, CHARINDEX(' ', Full_Name + ' ', 2) + 1, LEN(Full_Name)), 2, LEN(Full_Name));
```

### 5. Cleaning leading and trailing spaces in the Club column
Checking the distinct clubs in the column.
```sql
SELECT DISTINCT Club
FROM [dbo].[fifa21 raw data v2]
ORDER BY Club ASC;
```
Cleaning leading and trailing spaces
UPDATE [dbo].[fifa21 raw data v2]
SET Club = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(Club, CHAR(9), ' '), CHAR(10), ' '), CHAR(13), ' ')));

### 6. The Contract Column
Checking the distinct values
```sql
SELECT DISTINCT(Contract)
FROM [dbo].[fifa21 raw data v2];
```
The column exhibits non-native characters, as evident from the above. These characters will be replaced with hyphens. 
```sql
UPDATE [dbo].[fifa21 raw data v2]
SET Contract = REPLACE(Contract, '~', '-');

UPDATE [dbo].[fifa21 raw data v2]
SET Contract = SUBSTRING(Contract, 9, 4)
WHERE Contract LIKE '%on%';
```
Furthermore, executing the following query will generate two new columns named "contract start" and "contract end," utilizing the data available in the Contract column.
```sql
ALTER TABLE [dbo].[fifa21 raw data v2]
ADD Contract_Start VARCHAR(20);

ALTER TABLE [dbo].[fifa21 raw data v2]
ADD Contract_End VARCHAR(20);

UPDATE [dbo].[fifa21 raw data v2]
SET Contract_Start = SUBSTRING(Contract, 1, 4);

UPDATE [dbo].[fifa21 raw data v2]
SET Contract_End = RIGHT(Contract, 4);
```
Viewing the columns
```sql
SELECT Contract, Contract_Start, Contract_End
FROM [dbo].[fifa21 raw data v2];
```
