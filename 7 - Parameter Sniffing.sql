CREATE INDEX IX_Reputation ON dbo.Users(Reputation)
GO
DBCC SHOW_STATISTICS('dbo.Users', 'IX_Reputation')
GO

/* Turn on actual execution plans and: */
SET STATISTICS IO, TIME ON;
GO
SELECT TOP 10000 * 
FROM dbo.Users
WHERE Reputation=1
ORDER BY DisplayName;
GO

SELECT TOP 10000 *
FROM dbo.Users
WHERE Reputation=2
ORDER BY DisplayName;
GO


CREATE OR ALTER PROCEDURE dbo.usp_UsersByReputation
  @Reputation int
AS
SELECT TOP 10000 *
FROM dbo.Users
WHERE Reputation=@Reputation
ORDER BY DisplayName;
GO

EXEC dbo.usp_UsersByReputation @Reputation =1;
GO
EXEC dbo.usp_UsersByReputation @Reputation =2;
GO

DBCC FREEPROCCACHE
GO
EXEC dbo.usp_UsersByReputation @Reputation =2;
GO
EXEC dbo.usp_UsersByReputation @Reputation =1;
GO
sp_BlitzCache




DECLARE @Reputation INT = 2

--CREATE PROCEDURE dbo.usp_UsersByReputation
--  @Reputation int
--AS
SELECT TOP 10000 *
FROM dbo.Users
WHERE Reputation=@Reputation
ORDER BY DisplayName;
GO

DBCC SHOW_STATISTICS('dbo.Users', 'IX_Reputation')




CREATE PROCEDURE #usp_UsersByReputation @Reputation int AS
SELECT * FROM dbo.Users
WHERE Reputation= @Reputation
GO

EXEC #usp_UsersByReputation 2
GO