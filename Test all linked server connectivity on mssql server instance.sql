---------------------TSQL Check if all linked servers are working-------------------------- 
DECLARE @linkedserver VARCHAR(30) 
DECLARE @testlinkedserver NVARCHAR(255) 
IF OBJECT_ID('tempdb..#testlinkedserver') IS NOT NULL 
	DROP TABLE #testlinkedserver

CREATE TABLE #testlinkedserver 
  ( 
     NAME        VARCHAR(30), 
     test_status VARCHAR(10) 
  ) 

INSERT INTO #testlinkedserver (NAME) 
SELECT name 
FROM   sys.servers 
WHERE  name <> @@SERVERNAME 

WHILE EXISTS(SELECT 1 
             FROM   #testlinkedserver 
             WHERE  test_status IS NULL) 
  BEGIN 
      SELECT TOP 1 @linkedserver = NAME 
      FROM   #testlinkedserver 
      WHERE  test_status IS NULL 

      SELECT @testlinkedserver = 'EXEC sp_testlinkedserver ' + @linkedserver 

      BEGIN try 
			PRINT @testlinkedserver
          EXEC sp_executesql @testlinkedserver

          UPDATE #testlinkedserver 
          SET    test_status = 'SUCCESS' 
          WHERE  NAME = @linkedserver 
      END try 

      BEGIN catch 
	  PRINT 'Failed'
          UPDATE #testlinkedserver 
          SET    test_status = 'FAILED' 
          WHERE  NAME = @linkedserver 
      END catch 
  END 
  SELECT * FROM #testlinkedserver


  DROP TABLE #testlinkedserver

