USE [StackOverflow2010SSD]
GO
/****** Object:  StoredProcedure [dbo].[sapi_Example_5_NumberOfPostsAndVotesByUser]    Script Date: 2/5/2019 2:12:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROC [dbo].[sapi_Example_5_NumberOfPostsAndVotesByUser] AS
BEGIN
	SELECT Users.DisplayName
		,Users.CreationDate
		,COUNT(DISTINCT posts.Id) NrPosts
		,COUNT(DISTINCT Votes.Id) NrVotes
	FROM Users
	INNER JOIN Posts ON Users.Id = Posts.OwnerUserId
	INNER JOIN Votes ON Posts.id = Votes.PostId
	GROUP BY Users.DisplayName
		,Users.CreationDate
	ORDER BY Users.CreationDate DESC
	--OFFSET X ROWS 
	--FETCH NEXT Y ROWS ONLY;
END
