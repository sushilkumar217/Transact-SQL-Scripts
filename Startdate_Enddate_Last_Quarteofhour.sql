DECLARE @from datetime,@to datetime
SET @From= CASE when datepart(MINUTE,getutcdate())/15  = 0 THEN cast(cast(format(dateadd(hour,-1,getdate()),'yyyy-MM-dd hh')  as varchar(15)) +':45' as datetime)
			WHEN datepart(MINUTE,getutcdate())/15  = 1 THEN cast(cast(format(getdate(),'yyyy-MM-dd hh')  as varchar(15)) +':00' as datetime)
			WHEN datepart(MINUTE,getutcdate())/15  = 2 THEN cast(cast(format(getdate(),'yyyy-MM-dd hh')  as varchar(15)) +':15' as datetime)
			WHEN datepart(MINUTE,getutcdate())/15  = 3 THEN cast(cast(format(getdate(),'yyyy-MM-dd hh')  as varchar(15)) +':30' as datetime) END 
SET @To =Dateadd(MINUTE,15,@From)
SELECT @From,@To
