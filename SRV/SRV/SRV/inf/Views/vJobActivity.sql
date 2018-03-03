
create view [inf].[vJobActivity] as
SELECT [session_id]
      ,[job_id]
      ,[run_requested_date]
      ,[run_requested_source]
      ,[queued_date]
      ,[start_execution_date]
      ,[last_executed_step_id]
      ,[last_executed_step_date]
      ,[stop_execution_date]
      ,[job_history_id]
      ,[next_scheduled_run_date]
  FROM [msdb].[dbo].[sysjobactivity];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Активные задания Агента экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJobActivity';

