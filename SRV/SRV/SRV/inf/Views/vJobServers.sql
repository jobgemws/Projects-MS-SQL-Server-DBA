
create view [inf].[vJobServers] as
SELECT [job_id]
      ,[server_id]
      ,[last_run_outcome]
      ,[last_outcome_message]
      ,[last_run_date]
      ,[last_run_time]
      ,[last_run_duration]
  FROM [msdb].[dbo].[sysjobservers];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Задания Агента экземпляра MS SQL Server по таблице [msdb].[dbo].[sysjobservers]', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJobServers';

