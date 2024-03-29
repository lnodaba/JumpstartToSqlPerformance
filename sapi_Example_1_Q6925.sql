USE [StackOverflow2010SSD]
GO
/****** Object:  StoredProcedure [dbo].[sapi_Example_1_Q6925]    Script Date: 2/5/2019 2:12:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[sapi_Example_1_Q6925] @UserId INT = 26837 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/6925/newer-users-with-more-reputation-than-me */


SELECT u.Id as [User Link], u.Reputation, u.Reputation - me.Reputation as Difference
FROM dbo.Users me 
INNER JOIN dbo.Users u 
	ON u.CreationDate > me.CreationDate
	AND u.Reputation > me.Reputation
WHERE me.Id = @UserId
	--OR me.DisplayName LIKE '%Lorand%'

END
