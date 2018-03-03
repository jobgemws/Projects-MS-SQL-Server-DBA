
create view [inf].[vJobSteps] as
SELECT [job_id]
      ,[step_id]
      ,[step_name]
      ,[subsystem]
      ,[command]
      ,[flags]
      ,[additional_parameters]
      ,[cmdexec_success_code]
      ,[on_success_action]
      ,[on_success_step_id]
      ,[on_fail_action]
      ,[on_fail_step_id]
      ,[server]
      ,[database_name]
      ,[database_user_name]
      ,[retry_attempts]
      ,[retry_interval]
      ,[os_run_priority]
      ,[output_file_name]
      ,[last_run_outcome]
      ,[last_run_duration]
      ,[last_run_retries]
      ,[last_run_date]
      ,[last_run_time]
      ,[proxy_id]
      ,[step_uid]
  FROM [msdb].[dbo].[sysjobsteps];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Шаги заданий Агента экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJobSteps';

