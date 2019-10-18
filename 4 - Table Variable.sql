USE StackOverflow2010SSD;
GO

SET STATISTICS TIME, IO ON;
GO
/*
	Check the Estimated vs actual plans.
*/
DECLARE @TableVariable TABLE (PostId INT)
DECLARE @UserId INT = 26837;

INSERT @TableVariable
SELECT Id
FROM Posts
WHERE OwnerUserId = @UserId


SELECT * FROM @TableVariable


/*
Let's create a table variable with 500k rows.
*/
DECLARE @SortTable TABLE (
	OrderID INT IDENTITY,
	CustomerID INT,
	OrderDate DATETIME,
	[Value] NUMERIC(18,2),
	ColChar CHAR(500)
	)

PRINT 'INSERT INTO TEMP TABLE VARIABLE!';

INSERT @SortTable
SELECT TOP 600000 ABS(CHECKSUM(NEWID()) / 10000000) AS CustomerID
	,CONVERT(DATETIME, GETDATE() - (CHECKSUM(NEWID()) / 1000000)) AS OrderDate
	,ISNULL(ABS(CONVERT(NUMERIC(18, 2), (CHECKSUM(NEWID()) / 1000000.5))), 0) AS Value
	,CONVERT(CHAR(500), NEWID()) AS ColChar
FROM sysobjects A
CROSS JOIN sysobjects B
CROSS JOIN sysobjects C
CROSS JOIN sysobjects D

PRINT 'SELECT WITH THE TEMP TABLE VARIABLE.';

SELECT DISTINCT DisplayName FROM Users 
INNER JOIN @SortTable ON Users.Id = CustomerID



/*
The same with a temp table
*/

PRINT 'INSERT INTO TEMP TABLE!';

SELECT TOP 600000 IDENTITY(INT, 1, 1) AS OrderID
	,ABS(CHECKSUM(NEWID()) / 10000000) AS CustomerID
	,CONVERT(DATETIME, GETDATE() - (CHECKSUM(NEWID()) / 1000000)) AS OrderDate
	,ISNULL(ABS(CONVERT(NUMERIC(18, 2), (CHECKSUM(NEWID()) / 1000000.5))), 0) AS Value
	,CONVERT(CHAR(500), NEWID()) AS ColChar
INTO #SortTable
FROM sysobjects A
CROSS JOIN sysobjects B
CROSS JOIN sysobjects C
CROSS JOIN sysobjects D


PRINT 'SELECT WITH THE TEMP TABLE!';

SELECT DISTINCT DisplayName FROM Users 
INNER JOIN #SortTable ON Users.Id = CustomerID

DROP TABLE #SortTable


