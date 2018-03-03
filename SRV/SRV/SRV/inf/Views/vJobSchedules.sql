
create view [inf].[vJobSchedules] as
SELECT [schedule_id]
      ,[job_id]
      ,[next_run_date]
      ,[next_run_time]
  FROM [msdb].[dbo].[sysjobschedules];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расписания заданий Агента экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJobSchedules';

