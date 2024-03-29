USE [StackOverflow2010SSD]
GO
/****** Object:  StoredProcedure [dbo].[sapi_Example_4_FindInterestingPostsForUser]    Script Date: 2/5/2019 2:12:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROC [dbo].[sapi_Example_4_FindInterestingPostsForUser]
	@UserId INT,
	@SinceDate DATETIME = NULL AS
BEGIN
SET NOCOUNT ON
/* If they didn't pass in a date, find the last vote they cast, and use 7 days before that */
IF @SinceDate IS NULL
	SELECT @SinceDate = DATEADD(DD, -7, CreationDate)
		FROM dbo.Votes v
		WHERE v.UserId = @UserId
		ORDER BY CreationDate DESC;

SELECT p.*
FROM dbo.Posts p
WHERE PostTypeId = 1 /* Question */
  AND dbo.fn_UserHasVoted(@UserId, p.Id) = 0 /* Only want to show posts they haven't voted on yet */
  AND p.CreationDate >= @SinceDate
ORDER BY p.CreationDate DESC; /* Show the newest stuff first */
END
