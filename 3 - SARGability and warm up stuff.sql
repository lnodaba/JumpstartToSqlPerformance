SET STATISTICS IO, TIME ON;
GO

/*
Egy kis pelda a Index Match/ Scan vs Seek es a kulombsegek
*/

SELECT * FROM Users WHERE DisplayName LIKE '%Scott%'
GO


DROP INDEX IF EXISTS IX_DisplyayName ON dbo.Users;
CREATE INDEX IX_DisplyayName ON dbo.Users(DisplayName);
GO

SELECT * FROM Users WHERE DisplayName LIKE 'Scott%'
GO

/*
 SARGability stands for  Search Argument
*/



SELECT * FROM [dbo].[Posts] 
WHERE  YEAR(CreationDate) = 2010 AND MONTH(CreationDate) = 1
GO

SELECT * FROM [dbo].[Posts] 
WHERE  CreationDate BETWEEN CONVERT(datetime, '2010-01-01') AND CONVERT(datetime, '2010-02-01'); 


/*
 Egy index aki mindig kisegit.
*/

CREATE INDEX IX_CreationDate ON [dbo].Posts(CreationDate);
GO

/*
 Select * tobb rosszat csinal mint jot.
*/


SELECT Id FROM [dbo].[Posts] 
WHERE  CreationDate BETWEEN CONVERT(datetime, '2010-01-01') AND CONVERT(datetime, '2010-02-01'); 
GO





