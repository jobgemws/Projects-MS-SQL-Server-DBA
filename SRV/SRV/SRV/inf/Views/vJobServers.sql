

CREATE view [inf].[vJobServers] as
SELECT jobser.[job_id]
      ,jobser.[server_id]
      ,jobser.[last_run_outcome]
      ,jobser.[last_outcome_message]
      ,jobser.[last_run_date]
      ,jobser.[last_run_time]
      ,jobser.[last_run_duration]
	  ,serv.[name] as [trg_server]
  FROM [msdb].[dbo].[sysjobservers] as jobser
  left outer join [sys].[servers] as serv on jobser.[server_id]=serv.[server_id]


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Задания Агента экземпляра MS SQL Server по таблице [msdb].[dbo].[sysjobservers]', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJobServers';

