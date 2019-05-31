

CREATE view [inf].[vJobActivity] as
SELECT sja.[session_id]
      ,sja.[job_id]
	  ,sv.[name]
      ,sja.[run_requested_date]
      ,sja.[run_requested_source]
      ,sja.[queued_date]
      ,sja.[start_execution_date]
      ,sja.[last_executed_step_id]
      ,sja.[last_executed_step_date]
      ,sja.[stop_execution_date]
      ,sja.[job_history_id]
      ,sja.[next_scheduled_run_date]
	  --,serv.[name] as [trg_server]
	  --,serv.[server_id]
  FROM [msdb].[dbo].[sysjobactivity] as sja
  inner join [msdb].[dbo].[sysjobs_view] as sv on sja.[job_id]=sv.[job_id]
  inner join [msdb].[dbo].[sysjobservers] as jobser on sja.[job_id]=jobser.[job_id]
  left outer join [sys].[servers] as serv on jobser.[server_id]=serv.[server_id]
  where sja.[start_execution_date] is not null
	and sja.[stop_execution_date] is null
	and sja.[session_id] = (SELECT MAX([session_id]) FROM [msdb].[dbo].[sysjobactivity] as t)
    and jobser.[server_id]=0;


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Активные задания Агента экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJobActivity';

