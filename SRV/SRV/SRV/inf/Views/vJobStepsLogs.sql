
create view [inf].[vJobStepsLogs] as
SELECT [log_id]
      ,[log]
      ,[date_created]
      ,[date_modified]
      ,[log_size]
      ,[step_uid]
  FROM [msdb].[dbo].[sysjobstepslogs];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логирование шагов заданий Агента экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJobStepsLogs';

