



	CREATE view [inf].[vBlockRequest] as
/*
	ГЕМ: Сведения о заблокированных запросах
	blocking_session_id<>0 - точно заблокированный
*/
SELECT session_id
	  ,status
	  ,blocking_session_id
	  ,database_id
	  ,DB_NAME(database_id) as DBName
	  ,(select top(1) text from sys.dm_exec_sql_text([sql_handle])) as [TSQL]
	  ,[sql_handle]
	   ,[statement_start_offset]
	   ,[statement_end_offset]
	   ,[plan_handle]
	   ,[user_id]
	   ,[connection_id]
	   ,[wait_type]
	   ,[wait_time]
	   ,[last_wait_type]
	   ,[wait_resource]
	   ,[open_transaction_count]
	   ,[open_resultset_count]
	   ,[transaction_id]
	   ,[context_info]
	   ,[percent_complete]
	   ,[estimated_completion_time]
	   ,[cpu_time]
	   ,[total_elapsed_time]
	   ,[scheduler_id]
	   ,[task_address]
	   ,[reads]
	   ,[writes]
	   ,[logical_reads]
	   ,[text_size]
	   ,[language]
	   ,[date_format]
	   ,[date_first]
	   ,[quoted_identifier]
	   ,[arithabort]
	   ,[ansi_null_dflt_on]
	   ,[ansi_defaults]
	   ,[ansi_warnings]
	   ,[ansi_padding]
	   ,[ansi_nulls]
	   ,[concat_null_yields_null]
	   ,[transaction_isolation_level]
	   ,[lock_timeout]
	   ,[deadlock_priority]
	   ,[row_count]
	   ,[prev_error]
	   ,[nest_level]
	   ,[granted_query_memory]
	   ,[executing_managed_code]
	   ,[group_id]
	   ,[query_hash]
	   ,[query_plan_hash]
FROM sys.dm_exec_requests
where blocking_session_id<>0
--WHERE status = N'suspended' --приостановлен сеанс;




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сведения о заблокированных запросах (поверхностный способ) экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vBlockRequest';

