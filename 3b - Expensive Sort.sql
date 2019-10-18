USE StackOverflow2010SSD
GO

SET STATISTICS TIME,IO ON;
GO

/*Tabla letrehozas*/
/* 100K soros tabla */

IF OBJECT_ID('SortTable') IS NOT NULL
	DROP TABLE SortTable
GO

DROP INDEX IF EXISTS IX_ColChar ON SortTable
GO

SELECT TOP 100000 IDENTITY(INT, 1, 1) AS OrderID
	,ABS(CHECKSUM(NEWID()) / 10000000) AS CustomerID
	,CONVERT(DATETIME, GETDATE() - (CHECKSUM(NEWID()) / 1000000)) AS OrderDate
	,ISNULL(ABS(CONVERT(NUMERIC(18, 2), (CHECKSUM(NEWID()) / 1000000.5))), 0) AS Value
	,CONVERT(CHAR(500), NEWID()) AS ColChar
INTO SortTable
FROM sysobjects A
CROSS JOIN sysobjects B
CROSS JOIN sysobjects C
CROSS JOIN sysobjects D
GO

CREATE CLUSTERED INDEX IX_OrderID ON SortTable (OrderID)
GO


/*Elso Pelda ahol in memory fog futni a sort.*/

DECLARE @v1 CHAR(500)
	,@v2 INT

SELECT @v1 = ColChar
	,@v2 = OrderID
FROM SortTable
ORDER BY ColChar --not enough memory spilled on disk
OPTION (MAXDOP 1,RECOMPILE)

SELECT @v1 ,@v2
GO

/*Masodik pelda egy trukk atverni egy picit a rendszert hogy adjon tobb memoriat.*/

DECLARE @v1 CHAR(500)
	,@v2 INT

SELECT @v1 = ColChar
	,@v2 = OrderID
FROM SortTable
ORDER BY CONVERT(VarChar(5000), ColChar) + '' --enough memory, tricked with the CONVERT operation
OPTION (MAXDOP 1,RECOMPILE)

SELECT @v1 ,@v2
GO


/*Egy index ami segit!*/
CREATE INDEX IX_ColChar ON SortTable(ColChar) 
GO

DECLARE @v1 CHAR(500)
	,@v2 INT

SELECT @v1 = ColChar
	,@v2 = OrderID
FROM SortTable
ORDER BY ColChar
OPTION (MAXDOP 1,RECOMPILE)
