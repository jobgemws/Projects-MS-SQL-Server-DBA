
CREATE   view [inf].[vRequests] as
/*
	ГЕМ: Сведения о запросах
*/
select ES.[session_id]
	      ,ER.[blocking_session_id]
		  ,ER.[request_id]
	      ,ER.[start_time]
		  ,DateDiff(second, ER.[start_time], GetDate()) as [date_diffSec] --Сколько в сек прошло времени от момента поступления запроса
		  , COALESCE(
						CAST(NULLIF(ER.[total_elapsed_time] / 1000, 0) as BIGINT)
					   ,CASE WHEN (ES.[status] <> 'running' and isnull(ER.[status], '')  <> 'running') 
								THEN  DATEDIFF(ss,0,getdate() - nullif(ES.[last_request_end_time], '1900-01-01T00:00:00.000'))
						END
					) as [total_time, sec] --Время всей работы запроса в сек
		  , CAST(NULLIF((CAST(ER.[total_elapsed_time] as BIGINT) - CAST(ER.[wait_time] AS BIGINT)) / 1000, 0 ) as bigint) as [work_time, sec] --Время работы запроса в сек без учета времени ожиданий
		  , CASE WHEN (ER.[status] <> 'running' AND ISNULL(ER.[status],'') <> 'running') 
		  			THEN  DATEDIFF(ss,0,getdate() - nullif(ES.[last_request_end_time], '1900-01-01T00:00:00.000'))
			END as [sleep_time, sec] --Время сна в сек
		  , NULLIF( CAST((ER.[logical_reads] + ER.[writes]) * 8 / 1024 as numeric(38,2)), 0) as [IO, MB] --операций чтения и записи в МБ
		  , CASE  ER.transaction_isolation_level
			WHEN 0 THEN 'Unspecified'
			WHEN 1 THEN 'ReadUncommited'
			WHEN 2 THEN 'ReadCommited'
			WHEN 3 THEN 'Repetable'
			WHEN 4 THEN 'Serializable'
			WHEN 5 THEN 'Snapshot'
			END as [transaction_isolation_level_desc] --уровень изоляции транзакции (расшифровка)
	      ,ER.[status]
		  ,ES.[status] as [status_session]
	      ,ER.[command]
		  ,ER.[percent_complete]
		  ,DB_Name(coalesce(ER.[database_id], ES.[database_id])) as [DBName]
		  , SUBSTRING(
						(select top(1) [text] from sys.dm_exec_sql_text(ER.[sql_handle]))
					  , ER.[statement_start_offset]/2+1
					  ,	(
							CASE WHEN ((ER.[statement_start_offset]<0) OR (ER.[statement_end_offset]<0))
									THEN DATALENGTH ((select top(1) [text] from sys.dm_exec_sql_text(ER.[sql_handle])))
								 ELSE ER.[statement_end_offset]
							END
							- ER.[statement_start_offset]
						)/2 +1
					 ) as [CURRENT_REQUEST] --Текущий выполняемый запрос в пакете
	      ,(select top(1) [text] from sys.dm_exec_sql_text(ER.[sql_handle])) as [TSQL]
		  ,(select top(1) [objectid] from sys.dm_exec_sql_text(ER.[sql_handle])) as [objectid]
		  ,(select top(1) [query_plan] from sys.dm_exec_query_plan(ER.[plan_handle])) as [QueryPlan]
		  ,NULL as [event_info]--(select top(1) [event_info] from sys.dm_exec_input_buffer(ES.[session_id], ER.[request_id])) as [event_info]
	      ,ER.[wait_type]
	      ,ES.[login_time]
		  ,ES.[host_name]
		  ,ES.[program_name]
		  ,cast(ER.[wait_time]/1000 as decimal(18,3)) as [wait_timeSec] --Если запрос в настоящий момент блокирован, в столбце содержится продолжительность текущего ожидания (в секундах)
	      ,ER.[wait_time]
	      ,ER.[last_wait_type]
	      ,ER.[wait_resource]
	      ,ER.[open_transaction_count]
	      ,ER.[open_resultset_count]
	      ,ER.[transaction_id]
	      ,ER.[context_info]
	      ,ER.[estimated_completion_time]
	      ,ER.[cpu_time]
	      ,ER.[total_elapsed_time]
	      ,ER.[scheduler_id]
	      ,ER.[task_address]
	      ,ER.[reads]
	      ,ER.[writes]
	      ,ER.[logical_reads]
	      ,ER.[text_size]
	      ,ER.[language]
	      ,ER.[date_format]
	      ,ER.[date_first]
	      ,ER.[quoted_identifier]
	      ,ER.[arithabort]
	      ,ER.[ansi_null_dflt_on]
	      ,ER.[ansi_defaults]
	      ,ER.[ansi_warnings]
	      ,ER.[ansi_padding]
	      ,ER.[ansi_nulls]
	      ,ER.[concat_null_yields_null]
	      ,ER.[transaction_isolation_level]
	      ,ER.[lock_timeout]
	      ,ER.[deadlock_priority]
	      ,ER.[row_count]
	      ,ER.[prev_error]
	      ,ER.[nest_level]
	      ,ER.[granted_query_memory]
	      ,ER.[executing_managed_code]
	      ,ER.[group_id]
	      ,ER.[query_hash]
	      ,ER.[query_plan_hash]
		  ,EC.[most_recent_session_id]
	      ,EC.[connect_time]
	      ,EC.[net_transport]
	      ,EC.[protocol_type]
	      ,EC.[protocol_version]
	      ,EC.[endpoint_id]
	      ,EC.[encrypt_option]
	      ,EC.[auth_scheme]
	      ,EC.[node_affinity]
	      ,EC.[num_reads]
	      ,EC.[num_writes]
	      ,EC.[last_read]
	      ,EC.[last_write]
	      ,EC.[net_packet_size]
	      ,EC.[client_net_address]
	      ,EC.[client_tcp_port]
	      ,EC.[local_net_address]
	      ,EC.[local_tcp_port]
	      ,EC.[parent_connection_id]
	      ,EC.[most_recent_sql_handle]
		  ,ES.[host_process_id]
		  ,ES.[client_version]
		  ,ES.[client_interface_name]
		  ,ES.[security_id]
		  ,ES.[login_name]
		  ,ES.[nt_domain]
		  ,ES.[nt_user_name]
		  ,ES.[memory_usage]
		  ,ES.[total_scheduled_time]
		  ,ES.[last_request_start_time]
		  ,ES.[last_request_end_time]
		  ,ES.[is_user_process]
		  ,ES.[original_security_id]
		  ,ES.[original_login_name]
		  ,ES.[last_successful_logon]
		  ,ES.[last_unsuccessful_logon]
		  ,ES.[unsuccessful_logons]
		  ,ES.[authenticating_database_id]
		  ,ER.[sql_handle]
	      ,ER.[statement_start_offset]
	      ,ER.[statement_end_offset]
	      ,ER.[plan_handle]
		  ,NULL as [dop]--ER.[dop]
	      ,coalesce(ER.[database_id], ES.[database_id]) as [database_id]
	      ,ER.[user_id]
	      ,ER.[connection_id]
	from sys.dm_exec_requests ER with(readuncommitted)
	right join sys.dm_exec_sessions ES with(readuncommitted)
	on ES.session_id = ER.session_id 
	left join sys.dm_exec_connections EC  with(readuncommitted)
	on EC.session_id = ES.session_id
	where ER.[status] in ('suspended', 'running', 'runnable')
	or exists (select top(1) 1 from sys.dm_exec_requests as ER0 where ER0.[blocking_session_id]=ES.[session_id])







GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сведения о запросах экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vRequests';

