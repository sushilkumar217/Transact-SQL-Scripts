SELECT NAME, 
       0 AS status 
INTO   #temp 
FROM   sys.databases 
WHERE  database_id > 4 

WHILE EXISTS(SELECT 1 
             FROM   #temp 
             WHERE  status = 0) 
  BEGIN 
      DECLARE @text   VARCHAR(max), 
              @dbname VARCHAR(55) 

      SELECT TOP 1 @dbname = NAME 
      FROM   #temp 
      WHERE  status = 0 

      SET @text=' use [' + @dbname + '] Query Text' 

      --Exec (@text) 
      PRINT @text 

      UPDATE #temp 
      SET    status = 1 
      WHERE  NAME = @dbname 
  END 

DROP TABLE #temp 