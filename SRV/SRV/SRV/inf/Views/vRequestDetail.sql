




CREATE view [inf].[vRequestDetail] as
/*Активные, готовые к выполнению и ожидающие запросы, а также те, что явно блокируют другие сеансы*/
with tbl0 as (
	select ES.[session_id]
	      ,ER.[blocking_session_id]
		  ,ER.[request_id]
	      ,ER.[start_time]
	      ,ER.[status]
		  ,ES.[status] as [status_session]
	      ,ER.[command]
		  ,ER.[percent_complete]
		  ,DB_Name(coalesce(ER.[database_id], ES.[database_id])) as [DBName]
	      ,(select top(1) [text] from sys.dm_exec_sql_text(ER.[sql_handle])) as [TSQL]
		  ,(select top(1) [objectid] from sys.dm_exec_sql_text(ER.[sql_handle])) as [objectid]
		  ,(select top(1) [query_plan] from sys.dm_exec_query_plan(ER.[plan_handle])) as [QueryPlan]
		  ,(select top(1) [event_info] from sys.dm_exec_input_buffer(ES.[session_id], ER.[request_id])) as [event_info]
	      ,ER.[wait_type]
	      ,ES.[login_time]
		  ,ES.[host_name]
		  ,ES.[program_name]
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
		  ,ER.[dop]
	      ,coalesce(ER.[database_id], ES.[database_id]) as [database_id]
	      ,ER.[user_id]
	      ,ER.[connection_id]
	from sys.dm_exec_requests ER with(readuncommitted)
	right join sys.dm_exec_sessions ES with(readuncommitted)
	on ES.session_id = ER.session_id 
	left join sys.dm_exec_connections EC  with(readuncommitted)
	on EC.session_id = ES.session_id
)
, tbl as (
	select [session_id]
	      ,[blocking_session_id]
		  ,[request_id]
	      ,[start_time]
	      ,[status]
		  ,[status_session]
	      ,[command]
		  ,[percent_complete]
		  ,[DBName]
		  ,OBJECT_name([objectid], [database_id]) as [object]
	      ,[TSQL]
		  ,[QueryPlan]
		  ,[event_info]
	      ,[wait_type]
	      ,[login_time]
		  ,[host_name]
		  ,[program_name]
	      ,[wait_time]
	      ,[last_wait_type]
	      ,[wait_resource]
	      ,[open_transaction_count]
	      ,[open_resultset_count]
	      ,[transaction_id]
	      ,[context_info]
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
		  ,[most_recent_session_id]
	      ,[connect_time]
	      ,[net_transport]
	      ,[protocol_type]
	      ,[protocol_version]
	      ,[endpoint_id]
	      ,[encrypt_option]
	      ,[auth_scheme]
	      ,[node_affinity]
	      ,[num_reads]
	      ,[num_writes]
	      ,[last_read]
	      ,[last_write]
	      ,[net_packet_size]
	      ,[client_net_address]
	      ,[client_tcp_port]
	      ,[local_net_address]
	      ,[local_tcp_port]
	      ,[parent_connection_id]
	      ,[most_recent_sql_handle]
		  ,[host_process_id]
		  ,[client_version]
		  ,[client_interface_name]
		  ,[security_id]
		  ,[login_name]
		  ,[nt_domain]
		  ,[nt_user_name]
		  ,[memory_usage]
		  ,[total_scheduled_time]
		  ,[last_request_start_time]
		  ,[last_request_end_time]
		  ,[is_user_process]
		  ,[original_security_id]
		  ,[original_login_name]
		  ,[last_successful_logon]
		  ,[last_unsuccessful_logon]
		  ,[unsuccessful_logons]
		  ,[authenticating_database_id]
		  ,[sql_handle]
	      ,[statement_start_offset]
	      ,[statement_end_offset]
	      ,[plan_handle]
		  ,[dop]
	      ,[database_id]
	      ,[user_id]
	      ,[connection_id]
	from tbl0
	where [status] in ('suspended', 'running', 'runnable')
)
, tbl_group as (
	select [blocking_session_id]
	from tbl
	where [blocking_session_id]<>0
	group by [blocking_session_id]
)
, tbl_res_rec as (
	select [session_id]
	      ,[blocking_session_id]
		  ,[request_id]
	      ,[start_time]
	      ,[status]
		  ,[status_session]
	      ,[command]
		  ,[percent_complete]
		  ,[DBName]
		  ,[object]
	      ,[TSQL]
		  ,[QueryPlan]
		  ,[event_info]
	      ,[wait_type]
	      ,[login_time]
		  ,[host_name]
		  ,[program_name]
	      ,[wait_time]
	      ,[last_wait_type]
	      ,[wait_resource]
	      ,[open_transaction_count]
	      ,[open_resultset_count]
	      ,[transaction_id]
	      ,[context_info]
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
		  ,[most_recent_session_id]
	      ,[connect_time]
	      ,[net_transport]
	      ,[protocol_type]
	      ,[protocol_version]
	      ,[endpoint_id]
	      ,[encrypt_option]
	      ,[auth_scheme]
	      ,[node_affinity]
	      ,[num_reads]
	      ,[num_writes]
	      ,[last_read]
	      ,[last_write]
	      ,[net_packet_size]
	      ,[client_net_address]
	      ,[client_tcp_port]
	      ,[local_net_address]
	      ,[local_tcp_port]
	      ,[parent_connection_id]
	      ,[most_recent_sql_handle]
		  ,[host_process_id]
		  ,[client_version]
		  ,[client_interface_name]
		  ,[security_id]
		  ,[login_name]
		  ,[nt_domain]
		  ,[nt_user_name]
		  ,[memory_usage]
		  ,[total_scheduled_time]
		  ,[last_request_start_time]
		  ,[last_request_end_time]
		  ,[is_user_process]
		  ,[original_security_id]
		  ,[original_login_name]
		  ,[last_successful_logon]
		  ,[last_unsuccessful_logon]
		  ,[unsuccessful_logons]
		  ,[authenticating_database_id]
		  ,[sql_handle]
	      ,[statement_start_offset]
	      ,[statement_end_offset]
	      ,[plan_handle]
		  ,[dop]
	      ,[database_id]
	      ,[user_id]
	      ,[connection_id]
		  , 0 as [is_blocking_other_session]
from tbl
union all
select tbl0.[session_id]
	      ,tbl0.[blocking_session_id]
		  ,tbl0.[request_id]
	      ,tbl0.[start_time]
	      ,tbl0.[status]
		  ,tbl0.[status_session]
	      ,tbl0.[command]
		  ,tbl0.[percent_complete]
		  ,tbl0.[DBName]
		  ,OBJECT_name(tbl0.[objectid], tbl0.[database_id]) as [object]
	      ,tbl0.[TSQL]
		  ,tbl0.[QueryPlan]
		  ,tbl0.[event_info]
	      ,tbl0.[wait_type]
	      ,tbl0.[login_time]
		  ,tbl0.[host_name]
		  ,tbl0.[program_name]
	      ,tbl0.[wait_time]
	      ,tbl0.[last_wait_type]
	      ,tbl0.[wait_resource]
	      ,tbl0.[open_transaction_count]
	      ,tbl0.[open_resultset_count]
	      ,tbl0.[transaction_id]
	      ,tbl0.[context_info]
	      ,tbl0.[estimated_completion_time]
	      ,tbl0.[cpu_time]
	      ,tbl0.[total_elapsed_time]
	      ,tbl0.[scheduler_id]
	      ,tbl0.[task_address]
	      ,tbl0.[reads]
	      ,tbl0.[writes]
	      ,tbl0.[logical_reads]
	      ,tbl0.[text_size]
	      ,tbl0.[language]
	      ,tbl0.[date_format]
	      ,tbl0.[date_first]
	      ,tbl0.[quoted_identifier]
	      ,tbl0.[arithabort]
	      ,tbl0.[ansi_null_dflt_on]
	      ,tbl0.[ansi_defaults]
	      ,tbl0.[ansi_warnings]
	      ,tbl0.[ansi_padding]
	      ,tbl0.[ansi_nulls]
	      ,tbl0.[concat_null_yields_null]
	      ,tbl0.[transaction_isolation_level]
	      ,tbl0.[lock_timeout]
	      ,tbl0.[deadlock_priority]
	      ,tbl0.[row_count]
	      ,tbl0.[prev_error]
	      ,tbl0.[nest_level]
	      ,tbl0.[granted_query_memory]
	      ,tbl0.[executing_managed_code]
	      ,tbl0.[group_id]
	      ,tbl0.[query_hash]
	      ,tbl0.[query_plan_hash]
		  ,tbl0.[most_recent_session_id]
	      ,tbl0.[connect_time]
	      ,tbl0.[net_transport]
	      ,tbl0.[protocol_type]
	      ,tbl0.[protocol_version]
	      ,tbl0.[endpoint_id]
	      ,tbl0.[encrypt_option]
	      ,tbl0.[auth_scheme]
	      ,tbl0.[node_affinity]
	      ,tbl0.[num_reads]
	      ,tbl0.[num_writes]
	      ,tbl0.[last_read]
	      ,tbl0.[last_write]
	      ,tbl0.[net_packet_size]
	      ,tbl0.[client_net_address]
	      ,tbl0.[client_tcp_port]
	      ,tbl0.[local_net_address]
	      ,tbl0.[local_tcp_port]
	      ,tbl0.[parent_connection_id]
	      ,tbl0.[most_recent_sql_handle]
		  ,tbl0.[host_process_id]
		  ,tbl0.[client_version]
		  ,tbl0.[client_interface_name]
		  ,tbl0.[security_id]
		  ,tbl0.[login_name]
		  ,tbl0.[nt_domain]
		  ,tbl0.[nt_user_name]
		  ,tbl0.[memory_usage]
		  ,tbl0.[total_scheduled_time]
		  ,tbl0.[last_request_start_time]
		  ,tbl0.[last_request_end_time]
		  ,tbl0.[is_user_process]
		  ,tbl0.[original_security_id]
		  ,tbl0.[original_login_name]
		  ,tbl0.[last_successful_logon]
		  ,tbl0.[last_unsuccessful_logon]
		  ,tbl0.[unsuccessful_logons]
		  ,tbl0.[authenticating_database_id]
		  ,tbl0.[sql_handle]
	      ,tbl0.[statement_start_offset]
	      ,tbl0.[statement_end_offset]
	      ,tbl0.[plan_handle]
		  ,tbl0.[dop]
	      ,tbl0.[database_id]
	      ,tbl0.[user_id]
	      ,tbl0.[connection_id]
		  , 1 as [is_blocking_other_session]
	from tbl_group as tg
	inner join tbl0 on tg.blocking_session_id=tbl0.session_id
)
,tbl_res_rec_g as (
	select [plan_handle],
		   [sql_handle],
		   cast([start_time] as date) as [start_time]
	from tbl_res_rec
	group by [plan_handle],
			 [sql_handle],
			 cast([start_time] as date)
)
,tbl_rec_stat_g as (
	select qs.[plan_handle]
		  ,qs.[sql_handle]
		  --,cast(qs.[last_execution_time] as date)	as [last_execution_time]
		  ,min(qs.[creation_time])					as [creation_time]
		  ,max(qs.[execution_count])				as [execution_count]
		  ,max(qs.[total_worker_time])				as [total_worker_time]
		  ,min(qs.[last_worker_time])				as [min_last_worker_time]
		  ,max(qs.[last_worker_time])				as [max_last_worker_time]
		  ,min(qs.[min_worker_time])				as [min_worker_time]
		  ,max(qs.[max_worker_time])				as [max_worker_time]
		  ,max(qs.[total_physical_reads])			as [total_physical_reads]
		  ,min(qs.[last_physical_reads])			as [min_last_physical_reads]
		  ,max(qs.[last_physical_reads])			as [max_last_physical_reads]
		  ,min(qs.[min_physical_reads])				as [min_physical_reads]
		  ,max(qs.[max_physical_reads])				as [max_physical_reads]
		  ,max(qs.[total_logical_writes])			as [total_logical_writes]
		  ,min(qs.[last_logical_writes])			as [min_last_logical_writes]
		  ,max(qs.[last_logical_writes])			as [max_last_logical_writes]
		  ,min(qs.[min_logical_writes])				as [min_logical_writes]
		  ,max(qs.[max_logical_writes])				as [max_logical_writes]
		  ,max(qs.[total_logical_reads])			as [total_logical_reads]
		  ,min(qs.[last_logical_reads])				as [min_last_logical_reads]
		  ,max(qs.[last_logical_reads])				as [max_last_logical_reads]
		  ,min(qs.[min_logical_reads])				as [min_logical_reads]
		  ,max(qs.[max_logical_reads])				as [max_logical_reads]
		  ,max(qs.[total_clr_time])					as [total_clr_time]
		  ,min(qs.[last_clr_time])					as [min_last_clr_time]
		  ,max(qs.[last_clr_time])					as [max_last_clr_time]
		  ,min(qs.[min_clr_time])					as [min_clr_time]
		  ,max(qs.[max_clr_time])					as [max_clr_time]
		  ,max(qs.[total_elapsed_time])				as [total_elapsed_time]
		  ,min(qs.[last_elapsed_time])				as [min_last_elapsed_time]
		  ,max(qs.[last_elapsed_time])				as [max_last_elapsed_time]
		  ,min(qs.[min_elapsed_time])				as [min_elapsed_time]
		  ,max(qs.[max_elapsed_time])				as [max_elapsed_time]
		  ,max(qs.[total_rows])						as [total_rows]
		  ,min(qs.[last_rows])						as [min_last_rows]
		  ,max(qs.[last_rows])						as [max_last_rows]
		  ,min(qs.[min_rows])						as [min_rows]
		  ,max(qs.[max_rows])						as [max_rows]
		  ,max(qs.[total_dop])						as [total_dop]
		  ,min(qs.[last_dop])						as [min_last_dop]
		  ,max(qs.[last_dop])						as [max_last_dop]
		  ,min(qs.[min_dop])						as [min_dop]
		  ,max(qs.[max_dop])						as [max_dop]
		  ,max(qs.[total_grant_kb])					as [total_grant_kb]
		  ,min(qs.[last_grant_kb])					as [min_last_grant_kb]
		  ,max(qs.[last_grant_kb])					as [max_last_grant_kb]
		  ,min(qs.[min_grant_kb])					as [min_grant_kb]
		  ,max(qs.[max_grant_kb])					as [max_grant_kb]
		  ,max(qs.[total_used_grant_kb])			as [total_used_grant_kb]
		  ,min(qs.[last_used_grant_kb])				as [min_last_used_grant_kb]
		  ,max(qs.[last_used_grant_kb])				as [max_last_used_grant_kb]
		  ,min(qs.[min_used_grant_kb])				as [min_used_grant_kb]
		  ,max(qs.[max_used_grant_kb])				as [max_used_grant_kb]
		  ,max(qs.[total_ideal_grant_kb])			as [total_ideal_grant_kb]
		  ,min(qs.[last_ideal_grant_kb])			as [min_last_ideal_grant_kb]
		  ,max(qs.[last_ideal_grant_kb])			as [max_last_ideal_grant_kb]
		  ,min(qs.[min_ideal_grant_kb])				as [min_ideal_grant_kb]
		  ,max(qs.[max_ideal_grant_kb])				as [max_ideal_grant_kb]
		  ,max(qs.[total_reserved_threads])			as [total_reserved_threads]
		  ,min(qs.[last_reserved_threads])			as [min_last_reserved_threads]
		  ,max(qs.[last_reserved_threads])			as [max_last_reserved_threads]
		  ,min(qs.[min_reserved_threads])			as [min_reserved_threads]
		  ,max(qs.[max_reserved_threads])			as [max_reserved_threads]
		  ,max(qs.[total_used_threads])				as [total_used_threads]
		  ,min(qs.[last_used_threads])				as [min_last_used_threads]
		  ,max(qs.[last_used_threads])				as [max_last_used_threads]
		  ,min(qs.[min_used_threads])				as [min_used_threads]
		  ,max(qs.[max_used_threads])				as [max_used_threads]
	from tbl_res_rec_g as t
	inner join sys.dm_exec_query_stats as qs with(readuncommitted) on t.[plan_handle]=qs.[plan_handle] 
																  and t.[sql_handle]=qs.[sql_handle] 
																  and t.[start_time]=cast(qs.[last_execution_time] as date)
	group by qs.[plan_handle]
			,qs.[sql_handle]
			--,qs.[last_execution_time]
)
select t.[session_id] --Сессия
	      ,t.[blocking_session_id] --Сессия, которая явно блокирует сессию [session_id]
		  ,t.[request_id] --Идентификатор запроса. Уникален в контексте сеанса
	      ,t.[start_time] --Метка времени поступления запроса
		  ,DateDiff(second, t.[start_time], GetDate()) as [date_diffSec] --Сколько в сек прошло времени от момента поступления запроса
	      ,t.[status] --Состояние запроса
		  ,t.[status_session] --Состояние сессии
	      ,t.[command] --Тип выполняемой в данный момент команды
		  , COALESCE(
						CAST(NULLIF(t.[total_elapsed_time] / 1000, 0) as BIGINT)
					   ,CASE WHEN (t.[status_session] <> 'running' and isnull(t.[status], '')  <> 'running') 
								THEN  DATEDIFF(ss,0,getdate() - nullif(t.[last_request_end_time], '1900-01-01T00:00:00.000'))
						END
					) as [total_time, sec] --Время всей работы запроса в сек
		  , CAST(NULLIF((CAST(t.[total_elapsed_time] as BIGINT) - CAST(t.[wait_time] AS BIGINT)) / 1000, 0 ) as bigint) as [work_time, sec] --Время работы запроса в сек без учета времени ожиданий
		  , CASE WHEN (t.[status_session] <> 'running' AND ISNULL(t.[status],'') <> 'running') 
		  			THEN  DATEDIFF(ss,0,getdate() - nullif(t.[last_request_end_time], '1900-01-01T00:00:00.000'))
			END as [sleep_time, sec] --Время сна в сек
		  , NULLIF( CAST((t.[logical_reads] + t.[writes]) * 8 / 1024 as numeric(38,2)), 0) as [IO, MB] --операций чтения и записи в МБ
		  , CASE  t.transaction_isolation_level
			WHEN 0 THEN 'Unspecified'
			WHEN 1 THEN 'ReadUncommited'
			WHEN 2 THEN 'ReadCommited'
			WHEN 3 THEN 'Repetable'
			WHEN 4 THEN 'Serializable'
			WHEN 5 THEN 'Snapshot'
			END as [transaction_isolation_level_desc] --уровень изоляции транзакции (расшифровка)
		  ,t.[percent_complete] --Процент завершения работы для следующих команд
		  ,t.[DBName] --БД
		  ,t.[object] --Объект
		  , SUBSTRING(
						t.[TSQL]
					  , t.[statement_start_offset]/2+1
					  ,	(
							CASE WHEN ((t.[statement_start_offset]<0) OR (t.[statement_end_offset]<0))
									THEN DATALENGTH (t.[TSQL])
								 ELSE t.[statement_end_offset]
							END
							- t.[statement_start_offset]
						)/2 +1
					 ) as [CURRENT_REQUEST] --Текущий выполняемый запрос в пакете
	      ,t.[TSQL] --Запрос всего пакета
		  ,t.[QueryPlan] --План всего пакета
		  ,t.[event_info] --Текст инструкции из входного буфера для данным идентификатором spid
	      ,t.[wait_type] --Если запрос в настоящий момент блокирован, в столбце содержится тип ожидания (sys.dm_os_wait_stats)
	      ,t.[login_time] --Время подключения сеанса
		  ,t.[host_name] --Имя клиентской рабочей станции, указанное в сеансе. Для внутреннего сеанса это значение равно NULL
		  ,t.[program_name] --Имя клиентской программы, которая инициировала сеанс. Для внутреннего сеанса это значение равно NULL
		  ,cast(t.[wait_time]/1000 as decimal(18,3)) as [wait_timeSec] --Если запрос в настоящий момент блокирован, в столбце содержится продолжительность текущего ожидания (в секундах)
	      ,t.[wait_time] --Если запрос в настоящий момент блокирован, в столбце содержится продолжительность текущего ожидания (в миллисекундах)
	      ,t.[last_wait_type] --Если запрос был блокирован ранее, в столбце содержится тип последнего ожидания
	      ,t.[wait_resource] --Если запрос в настоящий момент блокирован, в столбце указан ресурс, освобождения которого ожидает запрос
	      ,t.[open_transaction_count] --Число транзакций, открытых для данного запроса
	      ,t.[open_resultset_count] --Число результирующих наборов, открытых для данного запроса
	      ,t.[transaction_id] --Идентификатор транзакции, в которой выполняется запрос
	      ,t.[context_info] --Значение CONTEXT_INFO сеанса
		  ,cast(t.[estimated_completion_time]/1000 as decimal(18,3)) as [estimated_completion_timeSec] --Только для внутреннего использования. Не допускает значение NULL
	      ,t.[estimated_completion_time] --Только для внутреннего использования. Не допускает значение NULL
		  ,cast(t.[cpu_time]/1000 as decimal(18,3)) as [cpu_timeSec] --Время ЦП (в секундах), затраченное на выполнение запроса
	      ,t.[cpu_time] --Время ЦП (в миллисекундах), затраченное на выполнение запроса
		  ,cast(t.[total_elapsed_time]/1000 as decimal(18,3)) as [total_elapsed_timeSec] --Общее время, истекшее с момента поступления запроса (в секундах)
	      ,t.[total_elapsed_time] --Общее время, истекшее с момента поступления запроса (в миллисекундах)
	      ,t.[scheduler_id] --Идентификатор планировщика, который планирует данный запрос
	      ,t.[task_address] --Адрес блока памяти, выделенного для задачи, связанной с этим запросом
	      ,t.[reads] --Число операций чтения, выполненных данным запросом
	      ,t.[writes] --Число операций записи, выполненных данным запросом
	      ,t.[logical_reads] --Число логических операций чтения, выполненных данным запросом
	      ,t.[text_size] --Установка параметра TEXTSIZE для данного запроса
	      ,t.[language] --Установка языка для данного запроса
	      ,t.[date_format] --Установка параметра DATEFORMAT для данного запроса
	      ,t.[date_first] --Установка параметра DATEFIRST для данного запроса
	      ,t.[quoted_identifier] --1 = Параметр QUOTED_IDENTIFIER для запроса включен (ON). В противном случае — 0
	      ,t.[arithabort] --1 = Параметр ARITHABORT для запроса включен (ON). В противном случае — 0
	      ,t.[ansi_null_dflt_on] --1 = Параметр ANSI_NULL_DFLT_ON для запроса включен (ON). В противном случае — 0
	      ,t.[ansi_defaults] --1 = Параметр ANSI_DEFAULTS для запроса включен (ON). В противном случае — 0
	      ,t.[ansi_warnings] --1 = Параметр ANSI_WARNINGS для запроса включен (ON). В противном случае — 0
	      ,t.[ansi_padding] --1 = Параметр ANSI_PADDING для запроса включен (ON)
	      ,t.[ansi_nulls] --1 = Параметр ANSI_NULLS для запроса включен (ON). В противном случае — 0
	      ,t.[concat_null_yields_null] --1 = Параметр CONCAT_NULL_YIELDS_NULL для запроса включен (ON). В противном случае — 0
	      ,t.[transaction_isolation_level] --Уровень изоляции, с которым создана транзакция для данного запроса
		  ,cast(t.[lock_timeout]/1000 as decimal(18,3)) as [lock_timeoutSec] --Время ожидания блокировки для данного запроса (в секундах)
		  ,t.[lock_timeout] --Время ожидания блокировки для данного запроса (в миллисекундах)
	      ,t.[deadlock_priority] --Значение параметра DEADLOCK_PRIORITY для данного запроса
	      ,t.[row_count] --Число строк, возвращенных клиенту по данному запросу
	      ,t.[prev_error] --Последняя ошибка, происшедшая при выполнении запроса
	      ,t.[nest_level] --Текущий уровень вложенности кода, выполняемого для данного запроса
	      ,t.[granted_query_memory] --Число страниц, выделенных для выполнения поступившего запроса (1 страница-это примерно 8 КБ)
	      ,t.[executing_managed_code] --Указывает, выполняет ли данный запрос в настоящее время код объекта среды CLR (например, процедуры, типа или триггера).
									  --Этот флаг установлен в течение всего времени, когда объект среды CLR находится в стеке, даже когда из среды вызывается код Transact-SQL
	      
		  ,t.[group_id]	--Идентификатор группы рабочей нагрузки, которой принадлежит этот запрос
	      ,t.[query_hash] --Двоичное хэш-значение рассчитывается для запроса и используется для идентификации запросов с аналогичной логикой.
						  --Можно использовать хэш запроса для определения использования статистических ресурсов для запросов, которые отличаются только своими литеральными значениями
	      
		  ,t.[query_plan_hash] --Двоичное хэш-значение рассчитывается для плана выполнения запроса и используется для идентификации аналогичных планов выполнения запросов.
							   --Можно использовать хэш плана запроса для нахождения совокупной стоимости запросов со схожими планами выполнения
		  
		  ,t.[most_recent_session_id] --Представляет собой идентификатор сеанса самого последнего запроса, связанного с данным соединением
	      ,t.[connect_time] --Отметка времени установления соединения
	      ,t.[net_transport] --Содержит описание физического транспортного протокола, используемого данным соединением
	      ,t.[protocol_type] --Указывает тип протокола передачи полезных данных
	      ,t.[protocol_version] --Версия протокола доступа к данным, связанного с данным соединением
	      ,t.[endpoint_id] --Идентификатор, описывающий тип соединения. Этот идентификатор endpoint_id может использоваться для запросов к представлению sys.endpoints
	      ,t.[encrypt_option] --Логическое значение, указывающее, разрешено ли шифрование для данного соединения
	      ,t.[auth_scheme] --Указывает схему проверки подлинности (SQL Server или Windows), используемую с данным соединением
	      ,t.[node_affinity] --Идентифицирует узел памяти, которому соответствует данное соединение
	      ,t.[num_reads] --Число пакетов, принятых посредством данного соединения
	      ,t.[num_writes] --Число пакетов, переданных посредством данного соединения
	      ,t.[last_read] --Отметка времени о последнем полученном пакете данных
	      ,t.[last_write] --Отметка времени о последнем отправленном пакете данных
	      ,t.[net_packet_size] --Размер сетевого пакета, используемый для передачи данных
	      ,t.[client_net_address] --Сетевой адрес удаленного клиента
	      ,t.[client_tcp_port] --Номер порта на клиентском компьютере, который используется при осуществлении соединения
	      ,t.[local_net_address] --IP-адрес сервера, с которым установлено данное соединение. Доступен только для соединений, которые в качестве транспорта данных используют протокол TCP
	      ,t.[local_tcp_port] --TCP-порт сервера, если соединение использует протокол TCP
	      ,t.[parent_connection_id] --Идентифицирует первичное соединение, используемое в сеансе MARS
	      ,t.[most_recent_sql_handle] --Дескриптор последнего запроса SQL, выполненного с помощью данного соединения. Постоянно проводится синхронизация между столбцом most_recent_sql_handle и столбцом most_recent_session_id
		  ,t.[host_process_id] --Идентификатор процесса клиентской программы, которая инициировала сеанс. Для внутреннего сеанса это значение равно NULL
		  ,t.[client_version] --Версия TDS-протокола интерфейса, который используется клиентом для подключения к серверу. Для внутреннего сеанса это значение равно NULL
		  ,t.[client_interface_name] --Имя библиотеки или драйвер, используемый клиентом для обмена данными с сервером. Для внутреннего сеанса это значение равно NULL
		  ,t.[security_id] --Идентификатор безопасности Microsoft Windows, связанный с именем входа
		  ,t.[login_name] --SQL Server Имя входа, под которой выполняется текущий сеанс.
						  --Чтобы узнать первоначальное имя входа, с помощью которого был создан сеанс, см. параметр original_login_name.
						  --Может быть SQL Server проверка подлинности имени входа или имени пользователя домена, прошедшего проверку подлинности Windows
		  
		  ,t.[nt_domain] --Домен Windows для клиента, если во время сеанса применяется проверка подлинности Windows или доверительное соединение.
						 --Для внутренних сеансов и пользователей, не принадлежащих к домену, это значение равно NULL
		  
		  ,t.[nt_user_name] --Имя пользователя Windows для клиента, если во время сеанса используется проверка подлинности Windows или доверительное соединение.
							--Для внутренних сеансов и пользователей, не принадлежащих к домену, это значение равно NULL
		  
		  ,t.[memory_usage] --Количество 8-килобайтовых страниц памяти, используемых данным сеансом
		  ,t.[total_scheduled_time] --Общее время, назначенное данному сеансу (включая его вложенные запросы) для исполнения, в миллисекундах
		  ,t.[last_request_start_time] --Время, когда начался последний запрос данного сеанса. Это может быть запрос, выполняющийся в данный момент
		  ,t.[last_request_end_time] --Время завершения последнего запроса в рамках данного сеанса
		  ,t.[is_user_process] --0, если сеанс является системным. В противном случае значение равно 1
		  ,t.[original_security_id] --Microsoft Идентификатор безопасности Windows, связанный с параметром original_login_name
		  ,t.[original_login_name] --SQL Server Имя входа, которую использует клиент создал данный сеанс.
								   --Это может быть имя входа SQL Server, прошедшее проверку подлинности, имя пользователя домена Windows, 
								   --прошедшее проверку подлинности, или пользователь автономной базы данных.
								   --Обратите внимание, что после первоначального соединения для сеанса может быть выполнено много неявных или явных переключений контекста.
								   --Например если EXECUTE AS используется
		  
		  ,t.[last_successful_logon] --Время последнего успешного входа в систему для имени original_login_name до запуска текущего сеанса
		  ,t.[last_unsuccessful_logon] --Время последнего неуспешного входа в систему для имени original_login_name до запуска текущего сеанса
		  ,t.[unsuccessful_logons] --Число неуспешных попыток входа в систему для имени original_login_name между временем last_successful_logon и временем login_time
		  ,t.[authenticating_database_id] --Идентификатор базы данных, выполняющей проверку подлинности участника.
										  --Для имен входа это значение будет равно 0.
										  --Для пользователей автономной базы данных это значение будет содержать идентификатор автономной базы данных
		  
		  ,t.[sql_handle] --Хэш-карта текста SQL-запроса
	      ,t.[statement_start_offset] --Количество символов в выполняемом в настоящий момент пакете или хранимой процедуре, в которой запущена текущая инструкция.
									  --Может применяться вместе с функциями динамического управления sql_handle, statement_end_offset и sys.dm_exec_sql_text
									  --для извлечения исполняемой в настоящий момент инструкции по запросу
	      
		  ,t.[statement_end_offset] --Количество символов в выполняемом в настоящий момент пакете или хранимой процедуре, в которой завершилась текущая инструкция.
									--Может применяться вместе с функциями динамического управления sql_handle, statement_end_offset и sys.dm_exec_sql_text
									--для извлечения исполняемой в настоящий момент инструкции по запросу
	      
		  ,t.[plan_handle] --Хэш-карта плана выполнения SQL
	      ,t.[database_id] --Идентификатор базы данных, к которой выполняется запрос
	      ,t.[user_id] --Идентификатор пользователя, отправившего данный запрос
	      ,t.[connection_id] --Идентификатор соединения, по которому поступил запрос
		  ,t.[is_blocking_other_session] --1-сессия явно блокирует другие сессии, 0-сессия явно не блокирует другие сессии
		  ,coalesce(t.[dop], mg.[dop]) as [dop] --Степень параллелизма запроса
		  ,mg.[request_time] --Дата и время обращения запроса за предоставлением памяти
		  ,mg.[grant_time] --Дата и время, когда запросу была предоставлена память. Возвращает значение NULL, если память еще не была предоставлена
		  ,mg.[requested_memory_kb] --Общий объем запрошенной памяти в килобайтах
		  ,mg.[granted_memory_kb] --Общий объем фактически предоставленной памяти в килобайтах.
								  --Может быть значение NULL, если память еще не была предоставлена.
								  --Обычно это значение должно быть одинаковым с requested_memory_kb.
								  --Для создания индекса сервер может разрешить дополнительное предоставление по требованию памяти,
								  --объем которой выходит за рамки изначально предоставленной памяти
		  
		  ,mg.[required_memory_kb] --Минимальный объем памяти в килобайтах (КБ), необходимый для выполнения данного запроса.
								   --Значение requested_memory_kb равно этому объему или больше его
		  
		  ,mg.[used_memory_kb] --Используемый в данный момент объем физической памяти (в килобайтах)
		  ,mg.[max_used_memory_kb] --Максимальный объем используемой до данного момента физической памяти в килобайтах
		  ,mg.[query_cost] --Ожидаемая стоимость запроса
		  ,mg.[timeout_sec] --Время ожидания данного запроса в секундах до отказа от обращения за предоставлением памяти
		  ,mg.[resource_semaphore_id] --Неуникальный идентификатор семафора ресурса, которого ожидает данный запрос
		  ,mg.[queue_id] --Идентификатор ожидающей очереди, в которой данный запрос ожидает предоставления памяти.
						 --Значение NULL, если память уже предоставлена
		  
		  ,mg.[wait_order] --Последовательный порядок ожидающих запросов в указанной очереди queue_id.
						   --Это значение может изменяться для заданного запроса, если другие запросы отказываются от предоставления памяти или получают ее.
						   --Значение NULL, если память уже предоставлена
		  
		  ,mg.[is_next_candidate] --Является следующим кандидатом на предоставление памяти (1 = да, 0 = нет, NULL = память уже предоставлена)
		  ,mg.[wait_time_ms] --Время ожидания в миллисекундах. Значение NULL, если память уже предоставлена
		  ,mg.[pool_id] --Идентификатор пула ресурсов, к которому принадлежит данная группа рабочей нагрузки
		  ,mg.[is_small] --Значение 1 означает, что для данной операции предоставления памяти используется малый семафор ресурса.
						 --Значение 0 означает использование обычного семафора
		  
		  ,mg.[ideal_memory_kb] --Объем, в килобайтах (КБ), предоставленной памяти, необходимый для размещения всех данных в физической памяти.
								--Основывается на оценке количества элементов
		  
		  ,mg.[reserved_worker_count] --Число рабочих процессов, зарезервированной с помощью параллельных запросов, а также число основных рабочих процессов, используемых всеми запросами
		  ,mg.[used_worker_count] --Число рабочих процессов, используемых параллельных запросов
		  ,mg.[max_used_worker_count] --???
		  ,mg.[reserved_node_bitmap] --???
		  ,pl.[bucketid] --Идентификатор сегмента хэша, в который кэшируется запись.
						 --Значение указывает диапазон от 0 до значения размера хэш-таблицы для типа кэша.
						 --Для кэшей SQL Plans и Object Plans размер хэш-таблицы может достигать 10007 на 32-разрядных версиях систем и 40009 — на 64-разрядных.
						 --Для кэша Bound Trees размер хэш-таблицы может достигать 1009 на 32-разрядных версиях систем и 4001 на 64-разрядных.
						 --Для кэша расширенных хранимых процедур размер хэш-таблицы может достигать 127 на 32-разрядных и 64-разрядных версиях систем
		  
		  ,pl.[refcounts] --Число объектов кэша, ссылающихся на данный объект кэша.
						  --Значение refcounts для записи должно быть не меньше 1, чтобы размещаться в кэше
		  
		  ,pl.[usecounts] --Количество повторений поиска объекта кэша.
						  --Остается без увеличения, если параметризованные запросы обнаруживают план в кэше.
						  --Может быть увеличен несколько раз при использовании инструкции showplan
		  
		  ,pl.[size_in_bytes] --Число байтов, занимаемых объектом кэша
		  ,pl.[memory_object_address] --Адрес памяти кэшированной записи.
									  --Это значение можно использовать с представлением sys.dm_os_memory_objects,
									  --чтобы проанализировать распределение памяти кэшированного плана, 
									  --и с представлением sys.dm_os_memory_cache_entries для определения затрат на кэширование записи
		  
		  ,pl.[cacheobjtype] --Тип объекта в кэше. Значение может быть одним из следующих
		  ,pl.[objtype] --Тип объекта. Значение может быть одним из следующих
		  ,pl.[parent_plan_handle] --Родительский план
		  
		  --данные из sys.dm_exec_query_stats брались за сутки, в которых была пара (запрос, план)
		  ,qs.[creation_time] --Время компиляции плана
		  ,qs.[execution_count] --Количество выполнений плана с момента последней компиляции
		  ,qs.[total_worker_time] --Общее время ЦП, затраченное на выполнение плана с момента компиляции, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[min_last_worker_time] --Минимальное время ЦП, затраченное на последнее выполнение плана, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[max_last_worker_time] --Максимальное время ЦП, затраченное на последнее выполнение плана, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[min_worker_time] --Минимальное время ЦП, когда-либо затраченное на выполнение плана, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[max_worker_time] --Максимальное время ЦП, когда-либо затраченное на выполнение плана, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[total_physical_reads] --Общее количество операций физического считывания при выполнении плана с момента его компиляции.
									 --Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[min_last_physical_reads] --Минимальное количество операций физического считывания за время последнего выполнения плана.
										--Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[max_last_physical_reads] --Максимальное количество операций физического считывания за время последнего выполнения плана.
										--Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[min_physical_reads] --Минимальное количество операций физического считывания за одно выполнение плана.
								   --Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[max_physical_reads] --Максимальное количество операций физического считывания за одно выполнение плана.
								   --Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[total_logical_writes] --Общее количество операций логической записи при выполнении плана с момента его компиляции.
									 --Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[min_last_logical_writes] --Минимальное количество страниц в буферном пуле, загрязненных во время последнего выполнения плана.
										--Если страница уже является «грязной» (т. е. измененной), операции записи не учитываются.
										--Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[max_last_logical_writes] --Максимальное количество страниц в буферном пуле, загрязненных во время последнего выполнения плана.
										--Если страница уже является «грязной» (т. е. измененной), операции записи не учитываются.
										--Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[min_logical_writes] --Минимальное количество операций логической записи за одно выполнение плана.
								   --Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[max_logical_writes] --Максимальное количество операций логической записи за одно выполнение плана.
								   --Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[total_logical_reads] --Общее количество операций логического считывания при выполнении плана с момента его компиляции.
									--Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[min_last_logical_reads] --Минимальное количество операций логического считывания за время последнего выполнения плана.
									   --Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[max_last_logical_reads] --Максимальное количество операций логического считывания за время последнего выполнения плана.
									   --Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[min_logical_reads]	   --Минимальное количество операций логического считывания за одно выполнение плана.
									   --Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[max_logical_reads]	--Максимальное количество операций логического считывания за одно выполнение плана.
									--Значение всегда равно 0 при запросе оптимизированной для памяти таблицы
		  
		  ,qs.[total_clr_time]	--Время, в микросекундах (но с точностью до миллисекунды),
								--внутри Microsoft .NET Framework общеязыковая среда выполнения (CLR) объекты при выполнении плана с момента его компиляции.
								--Объекты среды CLR могут быть хранимыми процедурами, функциями, триггерами, типами и статистическими выражениями
		  
		  ,qs.[min_last_clr_time] --Минимальное время, в микросекундах (но с точностью до миллисекунды),
								  --затраченное внутри .NET Framework объекты среды CLR во время последнего выполнения плана.
								  --Объекты среды CLR могут быть хранимыми процедурами, функциями, триггерами, типами и статистическими выражениями
		  
		  ,qs.[max_last_clr_time] --Максимальное время, в микросекундах (но с точностью до миллисекунды),
								  --затраченное внутри .NET Framework объекты среды CLR во время последнего выполнения плана.
								  --Объекты среды CLR могут быть хранимыми процедурами, функциями, триггерами, типами и статистическими выражениями
		  
		  ,qs.[min_clr_time] --Минимальное время, когда-либо затраченное на выполнение плана внутри объектов .NET Framework среды CLR,
							 --в микросекундах (но с точностью до миллисекунды).
							 --Объекты среды CLR могут быть хранимыми процедурами, функциями, триггерами, типами и статистическими выражениями
		  
		  ,qs.[max_clr_time] --Максимальное время, когда-либо затраченное на выполнение плана внутри среды CLR .NET Framework,
							 --в микросекундах (но с точностью до миллисекунды).
							 --Объекты среды CLR могут быть хранимыми процедурами, функциями, триггерами, типами и статистическими выражениями
		  
		  --,qs.[total_elapsed_time] --Общее время, затраченное на выполнение плана, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[min_last_elapsed_time] --Минимальное время, затраченное на последнее выполнение плана, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[max_last_elapsed_time] --Максимальное время, затраченное на последнее выполнение плана, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[min_elapsed_time] --Минимальное время, когда-либо затраченное на выполнение плана, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[max_elapsed_time] --Максимальное время, когда-либо затраченное на выполнение плана, в микросекундах (но с точностью до миллисекунды)
		  ,qs.[total_rows] --Общее число строк, возвращаемых запросом. Не может иметь значение null.
						   --Значение всегда равно 0, если скомпилированная в собственном коде хранимая процедура запрашивает оптимизированную для памяти таблицу
		  
		  ,qs.[min_last_rows] --Минимальное число строк, возвращенных последним выполнением запроса. Не может иметь значение null.
							  --Значение всегда равно 0, если скомпилированная в собственном коде хранимая процедура запрашивает оптимизированную для памяти таблицу
		  
		  ,qs.[max_last_rows] --Максимальное число строк, возвращенных последним выполнением запроса. Не может иметь значение null.
							  --Значение всегда равно 0, если скомпилированная в собственном коде хранимая процедура запрашивает оптимизированную для памяти таблицу
		  
		  ,qs.[min_rows] --Минимальное количество строк, когда-либо возвращенных по запросу во время выполнения один
						 --Значение всегда равно 0, если скомпилированная в собственном коде хранимая процедура запрашивает оптимизированную для памяти таблицу
		  
		  ,qs.[max_rows] --Максимальное число строк, когда-либо возвращенных по запросу во время выполнения один
						 --Значение всегда равно 0, если скомпилированная в собственном коде хранимая процедура запрашивает оптимизированную для памяти таблицу
		  
		  ,qs.[total_dop] --Общую сумму по степени параллелизма плана используется с момента его компиляции.
						  --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_last_dop] --Минимальная степень параллелизма, если время последнего выполнения плана.
							 --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_last_dop] --Максимальная степень параллелизма, если время последнего выполнения плана.
							 --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_dop] --Минимальная степень параллелизма этот план когда-либо используется во время одного выполнения.
						--Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_dop] --Максимальная степень параллелизма этот план когда-либо используется во время одного выполнения.
						--Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[total_grant_kb] --Общий объем зарезервированной памяти в КБ предоставить этот план, полученных с момента его компиляции.
							   --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_last_grant_kb] --Минимальный объем зарезервированной памяти предоставляет в КБ, когда время последнего выполнения плана.
								  --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_last_grant_kb] --Максимальный объем зарезервированной памяти предоставляет в КБ, когда время последнего выполнения плана.
								  --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_grant_kb] --Минимальный объем зарезервированной памяти в КБ предоставить никогда не получено в ходе одного выполнения плана.
							 --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_grant_kb] --Максимальный объем зарезервированной памяти в КБ предоставить никогда не получено в ходе одного выполнения плана.
							 --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[total_used_grant_kb] --Общий объем зарезервированной памяти в КБ предоставить этот план, используемый с момента его компиляции.
									--Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_last_used_grant_kb] --Минимальная сумма предоставления используемой памяти в КБ, если время последнего выполнения плана.
									   --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_last_used_grant_kb] --Максимальная сумма предоставления используемой памяти в КБ, если время последнего выполнения плана.
									   --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_used_grant_kb] --Минимальный объем используемой памяти в КБ предоставить никогда не используется при выполнении одного плана.
								  --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_used_grant_kb] --Максимальный объем используемой памяти в КБ предоставить никогда не используется при выполнении одного плана.
								  --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[total_ideal_grant_kb] --Общий объем идеальный память в КБ, оценка плана с момента его компиляции.
									 --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_last_ideal_grant_kb] --Минимальный объем памяти, идеальным предоставляет в КБ, когда время последнего выполнения плана.
										--Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_last_ideal_grant_kb] --Максимальный объем памяти, идеальным предоставляет в КБ, когда время последнего выполнения плана.
										--Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_ideal_grant_kb] --Минимальный объем памяти идеальный предоставления в этот план когда-либо оценка во время выполнения один КБ.
								   --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_ideal_grant_kb] --Максимальный объем памяти идеальный предоставления в этот план когда-либо оценка во время выполнения один КБ.
								   --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[total_reserved_threads] --Общая сумма по зарезервированным параллельного потоков этот план когда-либо использовавшегося с момента его компиляции.
									   --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_last_reserved_threads] --Минимальное число зарезервированных параллельных потоков, когда время последнего выполнения плана.
										  --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_last_reserved_threads] --Максимальное число зарезервированных параллельных потоков, когда время последнего выполнения плана.
										  --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_reserved_threads] --Минимальное число зарезервированных параллельного потоков, когда-либо использовать при выполнении одного плана.
									 --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_reserved_threads] --Максимальное число зарезервированных параллельного потоков никогда не используется при выполнении одного плана.
									 --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[total_used_threads] --Общая сумма используется параллельных потоков этот план когда-либо использовавшегося с момента его компиляции.
								   --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_last_used_threads] --Минимальное число используемых параллельных потоков, когда время последнего выполнения плана.
									  --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_last_used_threads] --Максимальное число используемых параллельных потоков, когда время последнего выполнения плана.
									  --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[min_used_threads] --Минимальное число используемых параллельных потоков, при выполнении одного плана использовали.
								 --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
		  
		  ,qs.[max_used_threads] --Максимальное число используемых параллельных потоков, при выполнении одного плана использовали.
								 --Он всегда будет равно 0 для запроса к таблице, оптимизированной для памяти
from tbl_res_rec as t
left outer join sys.dm_exec_query_memory_grants as mg on t.[plan_handle]=mg.[plan_handle] and t.[sql_handle]=mg.[sql_handle]
left outer join sys.dm_exec_cached_plans as pl on t.[plan_handle]=pl.[plan_handle]
left outer join tbl_rec_stat_g as qs on t.[plan_handle]=qs.[plan_handle] and t.[sql_handle]=qs.[sql_handle] --and qs.[last_execution_time]=cast(t.[start_time] as date)
;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Активные, готовые к выполнению и ожидающие запросы, а также те, что явно блокируют другие сеансы экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vRequestDetail';

