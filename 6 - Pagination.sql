/*
	Newer version of SQL supports this easy syntax.
*/
SELECT * 
FROM Users
ORDER BY Id
OFFSET 10 ROWS 
FETCH NEXT 10 ROWS ONLY;

/*
	Old Version just for presentation purpose.
	=> egy szikrat masabb a szintaxis es nehezebb is. De az Offsetes megoldas egy syntactic sugar ezen a megoldason.
*/

WITH CTE
AS (
	SELECT *
		,ROW_NUMBER() over (order by Id ) rowNr
	FROM Users
)
SELECT * FROM CTE
WHERE rowNr BETWEEN 11 AND 20;
