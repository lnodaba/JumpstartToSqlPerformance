SET STATISTICS IO
	,TIME ON;
GO

/*
1 - Pivot and Recursive CTE
	Nezuk meg a tabla strukturat.

*/
DECLARE @start DATE = CONVERT(DATE, '2014-10-1');--start of the 4th quarter of the year for which we're having data
DECLARE @ForYears INT = 2;

WITH Dates
AS (
	/*Lista Fej a kezdesnel*/
	SELECT @start AS [Date] 
	
	UNION ALL
	
	SELECT DATEADD(MONTH, - 3, [Date]) AS [Date]
	FROM Dates /*Self Referencia a CTE-re*/
	WHERE YEAR(DATEADD(MONTH, - 3, [Date])) > YEAR(DATEADD(YEAR, - 1 * @ForYears, @start)) /*Zaro Feltetel*/
	)
	,Quarters /*Lehet tobbet is csinalni ezzel is strukturalni egy esetleges komplexebb queriet.*/
AS (
	SELECT YEAR([Date]) AS [Year]
		,DATEPART(QUARTER, [Date]) AS [Quarter]
	FROM Dates
	)
SELECT PivotTable.*
FROM (
	SELECT Brands.Brand AS Brand
		,Quarters.[Year] AS [Year]
		,Quarters.[Quarter] AS [Quarter]
		,SUM(Value) AS VALUE
	FROM Quarters
	CROSS JOIN (
		SELECT DISTINCT Brand AS Brand
		FROM DashboardNestle
		) Brands
	LEFT JOIN DashboardNestle ON Quarters.[Year] = DashboardNestle.[Year]
		AND Quarters.[Quarter] = CEILING(CAST([MONTH] AS DECIMAL) / 3)
		AND DashboardNestle.Brand = Brands.Brand
	GROUP BY Brands.Brand
		,Quarters.[Year]
		,Quarters.[Quarter]
	) SourceTable
PIVOT(SUM(VALUE) FOR Brand IN (
			Maggi
			,Honig
			,Knorr
			,Conimex
			,Unox
			,AH
			)) AS PivotTable
ORDER BY PivotTable.[Year]
	,PivotTable.[Quarter]
GO

/*
2 - Unpivot and Window Function Lag.
*/

SELECT [year]
	,[month]
	,[Name]
	,[Score]
	,LAG([Score], 1, 0) OVER (
		PARTITION BY [Name] ORDER BY [month]
		) AS PreviousScore
FROM (
	SELECT [year]
		,[month]
		,SUM([Awareness]) AS [Awareness]
		,SUM([BrandUsage]) AS [BrandUsage]
		,SUM([NPS]) AS [NPS]
	FROM Asics
	WHERE [year] = 2017
		AND [month] IN (1,2,3)
	GROUP BY [year]
		,[month]
	) Source
UNPIVOT([Score] FOR [Name] IN (
			[Awareness]
			,[BrandUsage]
			,[NPS]
			)) UnpivotTable
GO

/*
3 - Dynamic Sql
 */
CREATE OR ALTER PROCEDURE [dbo].[CreateColumn] (
	@TableName NVARCHAR(MAX)
	,@ColumnName NVARCHAR(MAX)
	,@ColumnDataType NVARCHAR(MAX)
	,@ColumnType NVARCHAR(MAX)
	,@DefaultValue NVARCHAR(100) = N'-1'
	,@Debug INT = 0
	)
AS
BEGIN
	DECLARE @DynamicSQL NVARCHAR(MAX)
	DECLARE @CleanedColumnName NVARCHAR(MAX)
	DECLARE @Retval AS INTEGER

	SET @Retval = 0
	SET @CleanedColumnName = REPLACE(REPLACE(@ColumnName, ' ', ''), '-', '');

	IF OBJECT_ID(N'[dbo].[' + @TableName + ']') IS NOT NULL
		AND COLUMNPROPERTY(OBJECT_ID(N'[dbo].[' + @TableName + ']'), REPLACE(@CleanedColumnName, ' ', ''), 'ColumnId') IS NULL
	BEGIN
		SET @DynamicSQL = 'ALTER TABLE ' + @TableName + ' ADD [' + REPLACE(@CleanedColumnName, ' ', '') + '] ' + @ColumnDataType

		IF @DefaultValue <> N'-1'
			SET @DynamicSQl = @DynamicSQL + ' DEFAULT(' + @DefaultValue + '); '
		ELSE
			SET @DynamicSQl = @DynamicSQL + '; '

		IF @ColumnType = 'FILTER'
		BEGIN
			SET @DynamicSQL = @DynamicSQL + ' CREATE INDEX Index' + REPLACE(@CleanedColumnName, ' ', '') + '  ON ' + @TableName + '([' + REPLACE(@CleanedColumnName, ' ', '') + ']);'
		END

		IF @Debug <> 1
			EXEC (@DynamicSQL);
		ELSE 
			PRINT (@DynamicSQL);
		
		SET @Retval = 1
	END
	ELSE
	BEGIN
		SET @Retval = 0
	END

	SELECT @Retval AS RetVal
END

GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[CreateColumn]
		@TableName = N'Asics',
		@ColumnName = N'GreatColumn',
		@ColumnDataType = N'INT',
		@ColumnType = N'FILTER',
		@DefaultValue = N'1',
		@Debug = 1

SELECT	'Return Value' = @return_value

GO



