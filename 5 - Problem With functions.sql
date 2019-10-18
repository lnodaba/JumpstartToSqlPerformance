SET STATISTICS IO ON
GO

/* 
First, let's set expectations:
How long does it take to get the top 1000 users? */
SELECT TOP 1000 u.DisplayName
FROM dbo.Users AS u;

/* How long does it take to scan the entire Badges table? */
SELECT COUNT(*)
FROM dbo.Badges;
GO

/* Create a scalar function to check someone's badge count: */
CREATE OR ALTER FUNCTION dbo.ScalarFunction (@uid INT)
RETURNS BIGINT
	WITH
RETURNS NULL ON NULL INPUT
	,SCHEMABINDING AS

BEGIN
	DECLARE @BCount BIGINT;

	SELECT @BCount = COUNT_BIG(*)
	FROM dbo.Badges AS b
	WHERE b.UserId = @uid
	GROUP BY b.UserId;

	RETURN @BCount;
END;
GO

/* Now get the first 1000 users - any order - and their number of badges.
Look at the estimated plan first.
How long will it take?
How many times will this function be executed?
How can we measure those two things?
*/
SELECT TOP 1000 u.DisplayName
	,dbo.ScalarFunction(u.Id)
FROM dbo.Users AS u;
GO

/* Let's try a Multi-Statement Table Valued Function (MSTVF) instead. */
CREATE OR ALTER FUNCTION dbo.MultiStatementTVF (@uid INT)
RETURNS @Out TABLE (BadgeCount BIGINT)
	WITH SCHEMABINDING
AS
BEGIN
	INSERT INTO @Out (BadgeCount)
	SELECT COUNT_BIG(*) AS BadgeCount
	FROM dbo.Badges AS b
	WHERE b.UserId = @uid
	GROUP BY b.UserId;

	RETURN;
END;
GO

/* How long will this take? How will we measure its impact? */
SELECT TOP 1000 u.DisplayName
	,mi.BadgeCount
FROM dbo.Users AS u
CROSS APPLY dbo.MultiStatementTVF(u.Id) AS mi;
GO

/* Instead of a multi-statement function, what if
   our function only had one statement?
*/
CREATE OR ALTER FUNCTION dbo.InlineTVF (@uid INT)
RETURNS TABLE
	WITH SCHEMABINDING
AS
RETURN

SELECT COUNT_BIG(*) AS BadgeCount
FROM dbo.Badges AS b
WHERE b.UserId = @uid
GROUP BY b.UserId;
GO

SELECT TOP 1000 u.DisplayName
	,bi.BadgeCount
FROM dbo.Users AS u
CROSS APPLY dbo.InlineTVF(u.Id) AS bi;
GO

/* You can also disregard the function entirely,
   and copy/paste the code directly into a CROSS APPLY:
*/
SELECT TOP 1000 u.DisplayName
	,bca.BadgeCount
FROM dbo.Users AS u
CROSS APPLY (
	SELECT b.UserId
		,COUNT_BIG(*) AS BadgeCount
	FROM dbo.Badges AS b
	WHERE u.Id = b.UserId
	GROUP BY b.UserId
	) bca;

/* Or use a CTE: */
WITH BadgeAggregate
AS (
	SELECT b.UserId
		,COUNT_BIG(*) AS BadgeCount
	FROM dbo.Badges AS b
	GROUP BY b.UserId
	)
SELECT TOP 1000 u.DisplayName
	,ba.BadgeCount
FROM dbo.Users AS u
JOIN BadgeAggregate AS ba ON ba.UserId = u.Id;
