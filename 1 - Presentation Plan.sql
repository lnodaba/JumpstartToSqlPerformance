/*
1)Bemutatom az adatbazist.
 To get to known your DB ;-)
*/
SELECT OBJECT_SCHEMA_NAME(p.object_id) AS [Schema]
	,OBJECT_NAME(p.object_id) AS [Table]
	,i.name AS [Index]
	,p.partition_number
	,CAST(p.rows AS DECIMAL) / 1000000 AS [Row Count]
	,i.type_desc AS [Index Type]
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id
	AND p.index_id = i.index_id
WHERE OBJECT_SCHEMA_NAME(p.object_id) != 'sys'
ORDER BY [Schema]
	,[Table]
	,[Index]


/*
2) Hogyan is fogunk eljarni.
	* A queriek innen jonnek : https://data.stackexchange.com/stackoverflow/queries?fbclid=IwAR27jwy985QCwcfRfnSS_YHPwa_1q-dR34b70owl8KFZg4sBe7kP898EZ24
	* aki akar tanulni itt kap lassu queriet sokat
*/
	
/*
3) Hogyan kovetem a queriek futasat SQL Management Studioban
	* SET STATISTICS IO, TIME ON; 
	* Estimate Execution plan
	* Actual Execution plan
   Fontos hogy az estimated kozel legyen az actualhoz, mert sokszor ott indul el a gebasz.
	* Live Query Statistics
	* Profiler
	* Extended events - ezt nem erintjuk.
3 db query amin demonstralni a planeket.
*/

EXEC sapi_Example_1_Q6925;
EXEC sapi_Example_2_Q466;
EXEC sapi_Example_3_Q3160;

/*
4) Query tuning esetek:
	* Queriek ahol nem szabad a queriet modositani.
		○ Index Tuning 
		○ Server Tunning -> ezzel nem fogunk foglalkozni csak megemlite es megmutatom hogy HDD vs SSD nel mi a kulombseg System Performance.
	• Queriek ahol nem szabad az indexeket modositani => ritkabb
	• Queriek ahol barmit lehet modositani.
 Ezekbol nezunk egy egy peldat, es kozosen fogjuk kijavitani a queriket.
 
 Egy par hiba eset ami az esetek 90%-ban segit, nem annyira konnyu felismerni oket de jo kiindulasi pontok.
	* Missing INDEX
	* SARGability
	* Implicit Conversion
	* Forced Serialization
	* Table Variable
	* Expensive Sort
	* Expensive Key Lookup
	* Problem with the UDFs (User Defined Functions) => megoldas altalaban CTE/APPLY operatorokkal.
	* Blocking
	* Parameter Sniffing
	* Deadlock => Deadlock Graph

*/


/* 
	Storage Comparison 
	Amig fut a lassu query bemutatom a sebessegeket a keppel (System Performance).
*/
SELECT COUNT(*)
  FROM [StackOverflow2010HDD].[dbo].Posts

SELECT COUNT(*)
  FROM [StackOverflow2010SSD].[dbo].Posts


/*
5) A missing indexen kivul harom esetet fogunk megnezni peldakkal majd nezunk real life queriket amiket tuningolhatunk.
   * Sargability => example to create. 3 - SARGability and warm up stuff
   * Expensive Sort => file : 3b - Expensive Sort.sql
   * table variables problema => kulon file step by step bemutatva a problemat.(4 - Table Variable.sql)
   * Problem with funciton => kulon file step by step itt is erre a problemara.(5- Problem With functions.sql)
   * Pagination => file (6 - Pagination.sql)
   * Parameter Sniffing => egy file a demoval (7 - Parameter Sniffing.sql)
   Miutan Ezek megvannak real word examplet csinalni.
*/

/* Missing Index, Table Variable */
EXEC [dbo].[sapi_Example_2_Q466]

/* Forced Serialization, problem with user defined function.*/
EXEC [dbo].[sapi_Example_4_FindInterestingPostsForUser]

/* Pagination */
EXEC [dbo].[sapi_Example_5_NumberOfPostsAndVotesByUser]

/*
6) Awesome features I really like in T-SQL 
   * CTE 
   * Pivot
   * Windowing Functions
   * Dynamic SQL 
   Egy egy pelda ezekre a dolgokra, amennyire lesz ido.
*/


