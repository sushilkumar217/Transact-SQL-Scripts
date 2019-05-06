SELECT 'ALL_' + CASE 
		WHEN T3.type = 'D'
			THEN 'FULL'
		ELSE 'LOG'
		END AS database_name
	,NULL AS backup_start_date
	,NULL AS backup_finish_date
	,'ALL' AS backup_type
	,sum(T3.backup_size / 1024 / 1024) backup_size_MB
	,sum(compressed_backup_size / 1024 / 1024) compressed_size_MB
	,datediff(second, min(backup_start_date), max(T3.backup_finish_date)) AS Duration_Seconds
	,NULL AS database_creation_date
	,NULL AS recovery_model
	,NULL AS physical_device_name
	,NULL AS user_name
FROM msdb.dbo.backupmediafamily T1
INNER JOIN msdb.dbo.backupmediaset T2 ON T1.media_set_id = T2.media_set_id
INNER JOIN msdb.dbo.backupset T3 ON T2.media_set_id = T3.media_set_id
WHERE T3.backup_start_date >= (
		SELECT max(backup_start_date)
		FROM msdb.dbo.backupset T4
		WHERE T4.database_name = T3.database_name
			AND type = 'D'
		)
	AND T3.type <> 'I'
GROUP BY T3.type

UNION ALL

SELECT 'ALL_FULL_LOG_Differential'
	,NULL AS backup_start_date
	,NULL AS backup_finish_date
	,'ALL' AS backup_type
	,sum(T3.backup_size / 1024 / 1024) backup_size_MB
	,sum(compressed_backup_size / 1024 / 1024) compressed_size_MB
	,datediff(second, min(backup_start_date), max(T3.backup_finish_date)) AS Duration_Seconds
	,NULL AS database_creation_date
	,NULL AS recovery_model
	,NULL AS physical_device_name
	,NULL AS user_name
FROM msdb.dbo.backupmediafamily T1
INNER JOIN msdb.dbo.backupmediaset T2 ON T1.media_set_id = T2.media_set_id
INNER JOIN msdb.dbo.backupset T3 ON T2.media_set_id = T3.media_set_id
WHERE T3.backup_start_date >= (
		SELECT max(backup_start_date)
		FROM msdb.dbo.backupset T4
		WHERE T4.database_name = T3.database_name
			AND type = 'D'
		)

UNION ALL

SELECT T3.database_name
	,T3.backup_start_date
	,T3.backup_finish_date
	,CASE 
		WHEN T3.type = 'D'
			THEN 'FULL'
		WHEN T3.type = 'I'
			THEN 'DIFFERENTIA'
		ELSE 'LOG'
		END AS backup_type
	,sum(T3.backup_size / 1024 / 1024) backup_size_MB
	,sum(compressed_backup_size / 1024 / 1024) compressed_size_MB
	,datediff(second, backup_start_date, T3.backup_finish_date) AS Duration_Seconds
	,T3.database_creation_date
	,T3.recovery_model
	,T1.physical_device_name
	,T3.user_name
FROM msdb.dbo.backupmediafamily T1
INNER JOIN msdb.dbo.backupmediaset T2 ON T1.media_set_id = T2.media_set_id
INNER JOIN msdb.dbo.backupset T3 ON T2.media_set_id = T3.media_set_id
WHERE T3.backup_start_date >= (
		SELECT max(backup_start_date)
		FROM msdb.dbo.backupset T4
		WHERE T4.database_name = T3.database_name
			AND type = 'D'
		)
GROUP BY T3.database_name
	,T3.backup_start_date
	,T3.backup_finish_date
	,T3.type
	,T3.database_creation_date
	,T3.recovery_model
	,T1.physical_device_name
	,T3.user_name
