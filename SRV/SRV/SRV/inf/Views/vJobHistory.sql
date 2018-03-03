
create view [inf].[vJobHistory] as
SELECT [instance_id]
      ,[job_id]
      ,[step_id]
      ,[step_name]
      ,[sql_message_id]
      ,[sql_severity]
      ,[message]
      ,[run_status]
      ,[run_date]
      ,[run_time]
      ,[run_duration]
      ,[operator_id_emailed]
      ,[operator_id_netsent]
      ,[operator_id_paged]
      ,[retries_attempted]
      ,[server]
  FROM [msdb].[dbo].[sysjobhistory];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'История выполнения заданий Агента экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJobHistory';

