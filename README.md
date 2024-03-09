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

### 7. Cleaning the Height and Weight Columns
The 'height' column displays inconsistent values, with measurements recorded in both "cm" and "foot-inches." To standardize the data, all measurements will be converted to centimeters.

This query begins by validating that the value in the "Height" column adheres to a pattern of two numbers separated by a foot mark (') and potentially followed by an optional double quote ("). It utilizes the CHARINDEX function to determine the positions of the foot mark and double quote, and the SUBSTRING function to extract the values representing feet and inches as substrings. Subsequently, the CONVERT function is employed to convert the extracted values from feet and inches to centimeters. It accomplishes this by multiplying the feet portion by 30.48 (since there are 30.48 cm in a foot), the inches portion by 2.54 (as there are 2.54 cm in an inch), and the decimal portion (if present) by 0.0254 (to convert inches to cm).
```sql
UPDATE [dbo].[fifa21 raw data v2]
SET [Height] =
    CASE 
        WHEN CHARINDEX('''', [Height]) > 0 AND CHARINDEX('"', [Height]) > CHARINDEX('''', [Height]) THEN
            CONVERT(FLOAT, SUBSTRING([Height], 1, CHARINDEX('''', [Height]) - 1)) * 30.48 +
            CONVERT(FLOAT, SUBSTRING([Height], CHARINDEX('''', [Height]) + 1, CHARINDEX('"', [Height]) - CHARINDEX('''', [Height]) - 1)) * 2.54 
        WHEN CHARINDEX('''', [Height]) > 0 THEN
            CONVERT(FLOAT, SUBSTRING([Height], 1, CHARINDEX('''', [Height]) - 1)) * 30.48
        WHEN CHARINDEX('.', [Height]) > 0 THEN
            CONVERT(FLOAT, [Height]) * 2.54
        ELSE
            NULL -- Handle other cases gracefully
    END
WHERE 
    [Height] LIKE '[0-9]''[0-9]%"' AND CHARINDEX('"', [Height]) > 0;
```

In the 'weight' column, some measurements are indicated in kilograms (kg), while others are in pounds (lbs). To maintain consistency within our dataset, all values will be converted to kilograms.

This query initially verifies the weight unit, determining whether it is indicated in kilograms or pounds by examining the last two characters in the "Weight" column, specifically "kg" or "lbs." It then converts the weight value to a float and adjusts it if necessary. If the weight unit is in pounds, the query converts the value to kilograms by dividing it by 2.20462. Conversely, if the weight unit is already in kilograms, no conversion is needed.
```sql
UPDATE [dbo].[fifa21 raw data v2]
SET [Weight] = 
 CASE 
  WHEN RIGHT([Weight], 2) = 'lbs' THEN CAST(SUBSTRING([Weight], 1, LEN([Weight]) - 3) AS FLOAT) / 2.20462 
  ELSE CAST(SUBSTRING([Weight], 1, LEN([Weight]) - 2) AS FLOAT) 
 END 
WHERE RIGHT([Weight], 2) IN ('kg', 'lbs');
```

### 8.  Cleaning the Value, Wage, and Release_clause columns
All three columns exhibit issues, as evident from the previous descriptions. Hence, to enable aggregation, we remove the decimal places also it's necessary to convert the values to float data type, eliminate the currency sign, and substitute the letters "M" and "K" with their respective equivalents denoting millions and thousands. we also remove all spaces.
Removing the decimal places.
```sql
UPDATE [dbo].[fifa21 raw data v2]
SET Value = REPLACE(Value, '.', ' ');

UPDATE [dbo].[fifa21 raw data v2]
SET Wage = REPLACE(Wage, '.', ' ');

UPDATE [dbo].[fifa21 raw data v2]
SET Release_Clause = REPLACE(Release_Clause, '.', ' ');
```
Replacing the "K" and "M" with the respective zeros and Removing spaces
```sql
UPDATE [dbo].[fifa21 raw data v2]
SET Value = 
    CASE
        WHEN Value LIKE '% %' THEN REPLACE(REPLACE(Value, 'M', '00000'), ' ', '')
        WHEN Value LIKE '%K' THEN REPLACE(REPLACE(Value, 'K', '000'), ' ', '')
        WHEN Value LIKE '%M' THEN REPLACE(REPLACE(Value, 'M', '000000'), ' ', '')
        ELSE REPLACE(Value, ' ', '')
    END;

UPDATE [dbo].[fifa21 raw data v2]
SET Wage = 
    CASE
        WHEN Wage LIKE '% %' THEN REPLACE(REPLACE(Wage, 'M', '00000'), ' ', '')
        WHEN Wage LIKE '%K' THEN REPLACE(REPLACE(Wage, 'K', '000'), ' ', '')
        WHEN Wage LIKE '%M' THEN REPLACE(REPLACE(Wage, 'M', '000000'), ' ', '')
        ELSE REPLACE(Wage, ' ', '')
    END;

UPDATE [dbo].[fifa21 raw data v2]
SET Release_Clause = 
    CASE
        WHEN Release_Clause LIKE '% %' THEN REPLACE(REPLACE(Release_Clause, 'M', '00000'), ' ', '')
        WHEN Release_Clause LIKE '%K' THEN REPLACE(REPLACE(Release_Clause, 'K', '000'), ' ', '')
        WHEN Release_Clause LIKE '%M' THEN REPLACE(REPLACE(Release_Clause, 'M', '000000'), ' ', '')
        ELSE REPLACE(Release_Clause, ' ', '')
    END;
```
