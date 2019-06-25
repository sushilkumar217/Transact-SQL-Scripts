SELECT jobs.name AS 'JobName',
Case when run_status = 0 THEN 'Failed'
	 WHEN run_status = 1 THEN 'Succeeded'
	 WHEN run_status = 2 THEN 'Retry'
	 WHEN run_status = 3 THEN 'Canceled'
	 WHEN run_status = 4 THEN 'In progress' ELSE  '' END as Jobstatus, Count(1) as JobCount
FROM msdb.dbo.sysjobs jobs
INNER JOIN msdb.dbo.sysjobhistory history
ON jobs.job_id = history.job_id
WHERE jobs.enabled = 1 AND run_date between '20190615' and '20190625' 
Group by jobs.name,run_status
Order by JobCount DESC