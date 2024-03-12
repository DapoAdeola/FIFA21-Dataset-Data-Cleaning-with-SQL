--View of Data
SELECT TOP 100 *
FROM [dbo].[fifa21 raw data v2];

--Shape and Content of the Dataset
EXEC sp_help '[dbo].[fifa21 raw data v2]';

--Checking for accurate row count
SELECT COUNT(*) AS Row_Count
FROM [dbo].[fifa21 raw data v2];

--Checking for Duplicates
SELECT LongName, Age, Club, Nationality, COUNT(*) AS Count
FROM [dbo].[fifa21 raw data v2]
GROUP BY LongName, Age, Club, Nationality
HAVING COUNT(*) > 1;

SELECT LongName, Age, Club, Nationality, Contract
FROM [dbo].[fifa21 raw data v2]
WHERE LongName = 'Peng Wang' AND Age = 27;

--Checking for NULL values in the most relevant Columns
SELECT COUNT(*) AS COUNT
FROM [dbo].[fifa21 raw data v2]
WHERE Name IS NULL
  OR LongName IS NULL
  OR Age IS NULL
  OR Nationality IS NULL
  OR Club IS NULL
  OR photoUrl IS NULL
  OR playerUrl IS NULL;

--Drop unnecessary columns and those with excessive NULL values
ALTER TABLE [dbo].[fifa21 raw data v2]
DROP COLUMN photoUrl;

ALTER TABLE [dbo].[fifa21 raw data v2]
DROP COLUMN playerUrl;

--Rename important columns
SP_RENAME '[dbo].[fifa21 raw data v2].LongName', 'Full_Name', 'COLUMN';

--Replace first letter of each name with a capital letter
UPDATE [dbo].[fifa21 raw data v2]
SET Full_Name = UPPER(LEFT(Full_Name, 1)) + SUBSTRING(Full_Name, 2, CHARINDEX(' ', Full_Name + ' ', 2) - 2) +
           ' ' + UPPER(LEFT(SUBSTRING(Full_Name, CHARINDEX(' ', Full_Name + ' ', 2) + 1, LEN(Full_Name)), 1)) +
           SUBSTRING(SUBSTRING(Full_Name, CHARINDEX(' ', Full_Name + ' ', 2) + 1, LEN(Full_Name)), 2, LEN(Full_Name));

SELECT DISTINCT Club
FROM [dbo].[fifa21 raw data v2]
ORDER BY Club ASC;

--Trailing spaces
UPDATE [dbo].[fifa21 raw data v2]
SET Club = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(Club, CHAR(9), ' '), CHAR(10), ' '), CHAR(13), ' ')));

--Cleaning the Contract column
SELECT DISTINCT(Contract)
FROM [dbo].[fifa21 raw data v2];

UPDATE [dbo].[fifa21 raw data v2]
SET Contract = REPLACE(Contract, '~', '-');

UPDATE [dbo].[fifa21 raw data v2]
SET Contract = SUBSTRING(Contract, 9, 4)
WHERE Contract LIKE '%on%';

--Creating new contract_start and contract_end columns
ALTER TABLE [dbo].[fifa21 raw data v2]
ADD Contract_Start VARCHAR(20);

ALTER TABLE [dbo].[fifa21 raw data v2]
ADD Contract_End VARCHAR(20);

--Get Contract start year
UPDATE [dbo].[fifa21 raw data v2]
SET Contract_Start = SUBSTRING(Contract, 1, 4);

--Get Contract end year
UPDATE [dbo].[fifa21 raw data v2]
SET Contract_End = RIGHT(Contract, 4);

--View Output
SELECT Contract, Contract_Start, Contract_End
FROM [dbo].[fifa21 raw data v2];

--Cleaning the Height column
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

--Cleaning the Weight column
SELECT DISTINCT(Weight)
FROM [dbo].[fifa21 raw data v2]

UPDATE [dbo].[fifa21 raw data v2]
SET [Weight] = 
 CASE 
  WHEN RIGHT([Weight], 2) = 'lbs' THEN CAST(SUBSTRING([Weight], 1, LEN([Weight]) - 3) AS FLOAT) / 2.20462 
  ELSE CAST(SUBSTRING([Weight], 1, LEN([Weight]) - 2) AS FLOAT) 
 END 
WHERE RIGHT([Weight], 2) IN ('kg', 'lbs')

--Removing decimal places
UPDATE [dbo].[fifa21 raw data v2]
SET Value = REPLACE(Value, '.', ' ');

UPDATE [dbo].[fifa21 raw data v2]
SET Wage = REPLACE(Wage, '.', ' ');

UPDATE [dbo].[fifa21 raw data v2]
SET Release_Clause = REPLACE(Release_Clause, '.', ' ');

--replace the "K" and "M" with the respective zeros and Removing spaces
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


--Remove currency type 
SELECT Value, Wage, Release_Clause
FROM [dbo].[fifa21 raw data v2];

UPDATE [dbo].[fifa21 raw data v2]
SET Value = SUBSTRING(Value, 2, LEN(Value)-1);

UPDATE [dbo].[fifa21 raw data v2]
SET Wage = SUBSTRING(Wage, 2, LEN(Wage)-1);

UPDATE [dbo].[fifa21 raw data v2]
SET Release_Clause = SUBSTRING(Release_Clause, 2, LEN(Release_Clause)-1);

--Convert columns to bigint datatype
ALTER TABLE [dbo].[fifa21 raw data v2]
ALTER COLUMN Value BIGINT;

ALTER TABLE [dbo].[fifa21 raw data v2]
ALTER COLUMN Wage BIGINT;

ALTER TABLE [dbo].[fifa21 raw data v2]
ALTER COLUMN Release_Clause BIGINT;


--Cleaning the W_F, SM and IR columns.
SELECT W_F, SM, A_W, D_W, IR
FROM [dbo].[fifa21 raw data v2]

UPDATE [dbo].[fifa21 raw data v2]
SET W_F = SUBSTRING(W_F, 1, 1);

UPDATE [dbo].[fifa21 raw data v2]
SET SM = SUBSTRING(SM, 1, 1);

UPDATE [dbo].[fifa21 raw data v2]
SET IR = SUBSTRING(IR, 1, 1);

--Convert columns to INT
ALTER TABLE [dbo].[fifa21 raw data v2]
ALTER COLUMN W_F INT;

ALTER TABLE [dbo].[fifa21 raw data v2]
ALTER COLUMN SM INT;

ALTER TABLE [dbo].[fifa21 raw data v2]
ALTER COLUMN IR INT;
