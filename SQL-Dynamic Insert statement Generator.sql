SET NOCOUNT ON
GO

-----Source Server name
DECLARE @sourcedb VARCHAR(6) = 'source'
-----------Destination Server name
DECLARE @destinationdb VARCHAR(11) = 'destination'
--As Schema is same on both source and destination
DECLARE @schema VARCHAR(6) = 'test'
DECLARE @table VARCHAR(20)
DECLARE @script VARCHAR(MAX)

--------------Get the table which has row count is 0 to exclude them in copy operation
SELECT DISTINCT os.name
	,0
FROM sys.dm_db_partition_stats ps
INNER JOIN sys.objects os ON ps.object_id = os.object_id
WHERE type = 'U'
	AND row_count = 0

-------------------Load the tables information into temp variable------------
DECLARE @tab TABLE (
	table_name VARCHAR(20) NOT NULL
	,orders INT
	,flag BIT NOT NULL
	)
	------Get the relationship between tables
	;

WITH cte
AS (
	SELECT DISTINCT Parents
	FROM (
		SELECT OBJECT_NAME(f.parent_object_id) AS Parent
			,OBJECT_NAME(f.referenced_object_id) AS Child
		FROM sys.foreign_keys AS f
		INNER JOIN sys.foreign_key_columns AS fc ON f.OBJECT_ID = fc.constraint_object_id
		INNER JOIN sys.objects AS o ON o.OBJECT_ID = fc.referenced_object_id
		) a
	CROSS APPLY (
		VALUES (Parent)
			,(Child)
		) d(Parents)
	)
INSERT INTO @tab (
	table_name
	,orders
	,flag
	)
SELECT Parents Tab
	,ROW_NUMBER() OVER (
		ORDER BY Parent
		) AS t_order
	,0 AS flag
FROM cte t
LEFT JOIN (
	SELECT OBJECT_NAME(f.parent_object_id) AS Parent
		,OBJECT_NAME(f.referenced_object_id) AS Child
	FROM sys.foreign_keys AS f
	INNER JOIN sys.foreign_key_columns AS fc ON f.OBJECT_ID = fc.constraint_object_id
	INNER JOIN sys.objects AS o ON o.OBJECT_ID = fc.referenced_object_id
	) m ON t.Parents = m.Parent
	AND Parents NOT IN (
		SELECT DISTINCT os.name
		FROM sys.dm_db_partition_stats ps
		INNER JOIN sys.objects os ON ps.object_id = os.object_id
		WHERE type = 'U'
			AND row_count = 0
		) ---excluding tables which has row count 0

WHILE EXISTS (
		SELECT 1
		FROM @tab
		WHERE flag = 0
		)
BEGIN
	SELECT TOP 1 @table = table_name
	FROM @tab
	WHERE flag = 0

	SELECT @script = '
IF OBJECTPROPERTY(OBJECT_ID(''' + @schema + '.' + @table + '''' + '),' + '''' + 'TableHasIdentity' + '''' + ')=1
SET IDENTITY_INSERT ' + '[' + @destinationdb + '].[' + @schema + '].[' + TABLE_NAME + ']' + 'ON
GO
INSERT INTO [' + @destinationdb + '].[' + @schema + '].[' + TABLE_NAME + '](' + COLUMN_NAME + ') 
SELECT ' + COLUMN_NAME + ' FROM [' + @sourcedb + '].[' + @schema + '].[' + @table + '];
IF OBJECTPROPERTY(OBJECT_ID(''' + @schema + '.' + @table + '''' + '),' + '''' + 'TableHasIdentity' + '''' + ')=1
SET IDENTITY_INSERT ' + '[' + @destinationdb + '].[' + @schema + '].[' + TABLE_NAME + ']' + 'OFF
GO


'
	FROM (
		SELECT B.TABLE_NAME
			,LEFT(Columns, LEN(Columns) - 1) AS COLUMN_NAME
		FROM (
			SELECT TABLE_NAME
				,(
					SELECT COLUMN_NAME + ','
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = @table
					FOR XML PATH('')
					) AS Columns
			FROM INFORMATION_SCHEMA.COLUMNS A
			WHERE TABLE_NAME = @table
			GROUP BY TABLE_NAME
			) B
		) c

	UPDATE @tab
	SET flag = 1
	WHERE table_name = @table

	PRINT @script
END
