--Check Always on DELAY

SELECT CAST(DB_NAME(database_id)as VARCHAR(40)) database_name,
Convert(VARCHAR(20),last_commit_time,22) last_commit_time
,CAST(CAST(((DATEDIFF(s,last_commit_time,GetDate()))/3600) as varchar) + ' hour(s), '
+ CAST((DATEDIFF(s,last_commit_time,GetDate())%3600)/60 as varchar) + ' min, '
+ CAST((DATEDIFF(s,last_commit_time,GetDate())%60) as varchar) + ' sec' as VARCHAR(30)) time_behind_primary
,redo_queue_size
,redo_rate
,CONVERT(VARCHAR(20),DATEADD(mi,(redo_queue_size/redo_rate/60.0),GETDATE()),22) estimated_completion_time
,CAST((redo_queue_size/redo_rate/60.0) as decimal(10,2)) [estimated_recovery_time_minutes]
,(redo_queue_size/redo_rate) [estimated_recovery_time_seconds]
,CONVERT(VARCHAR(20),GETDATE(),22) [current_time]
FROM sys.dm_hadr_database_replica_states
WHERE last_redone_time is not null 
ORDER BY 3 DESC

--Check Automatic Seeding progress
select local_database_name
, remote_machine_name,role_desc ,internal_state_desc 
,transfer_rate_bytes_per_second/1024/1024 as transfer_rate_MB_per_second ,transferred_size_bytes/1024/1024 as transferred_size_MB
,database_size_bytes/1024/1024/1024/1024 as Database_Size_TB,
is_compression_enabled     from sys.dm_hadr_physical_seeding_stats

SELECT r.session_id, r.status, r.command, r.wait_type , r.percent_complete, r.estimated_completion_time
FROM sys.dm_exec_requests r JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id WHERE r.session_id <> @@SPID
AND s.is_user_process = 0 and wait_type ='BACKUPTHREAD'
