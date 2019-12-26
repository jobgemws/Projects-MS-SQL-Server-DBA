CREATE   PROCEDURE [srv].[AutoKillSessionTranBegin]
	@minuteOld int=30, --старость запущенной транзакции
	@countIsNotRequests int=5 --кол-во попаданий в таблицу
AS
BEGIN
	/*
		определение зависших транзакций (забытых, у которых нет активных запросов) с последующим их удалением
	*/
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    
	declare @tbl table (
						SessionID int,
						TransactionID bigint,
						IsSessionNotRequest bit,
						TransactionBeginTime datetime
					   );
	
	--собираем информацию (транзакции и их сессии, у которых нет запросов, т е транзакции запущенные и забытые)
	insert into @tbl (
						SessionID,
						TransactionID,
						IsSessionNotRequest,
						TransactionBeginTime
					 )
	select t.[session_id] as SessionID
		 , t.[transaction_id] as TransactionID
		 , case when exists(select top(1) 1 from sys.dm_exec_requests as r where r.[session_id]=t.[session_id]) then 0 else 1 end as IsSessionNotRequest
		 , (select top(1) ta.[transaction_begin_time] from sys.dm_tran_active_transactions as ta where ta.[transaction_id]=t.[transaction_id]) as TransactionBeginTime
	from sys.dm_tran_session_transactions as t
	where t.[is_user_transaction]=1
	and not exists(select top(1) 1 from sys.dm_exec_requests as r where r.[transaction_id]=t.[transaction_id]);
	
	--обновляем таблицу запущенных транзакций, у которых нет активных запросов
	;merge srv.SessionTran as st
	using @tbl as t
	on st.[SessionID]=t.[SessionID] and st.[TransactionID]=t.[TransactionID]
	when matched then
		update set [UpdateUTCDate]			= getUTCDate()
				 , [CountTranNotRequest]	= st.[CountTranNotRequest]+1			
				 , [CountSessionNotRequest]	= case when (t.[IsSessionNotRequest]=1) then (st.[CountSessionNotRequest]+1) else 0 end
				 , [TransactionBeginTime]	= coalesce(t.[TransactionBeginTime], st.[TransactionBeginTime])
	when not matched by target and (t.[TransactionBeginTime] is not null) then
		insert (
				[SessionID]
				,[TransactionID]
				,[TransactionBeginTime]
			   )
		values (
				t.[SessionID]
				,t.[TransactionID]
				,t.[TransactionBeginTime]
			   )
	when not matched by source then delete;

	--список сессий для удаления (содержащие зависшие транзакции)
	declare @kills table (
							SessionID int
						 );

	--детальная информация для архива
	declare @kills_copy table (
							SessionID int,
							TransactionID bigint,
							CountTranNotRequest tinyint,
							CountSessionNotRequest tinyint,
							TransactionBeginTime datetime
						 )

	--собираем те сессии, которые нужно убить
	--у сессии есть хотя бы одна транзакция, которая попала @countIsNotRequests раз как без активных запросов и столько же раз у самой сессии нет активных запросов
	insert into @kills_copy	(
							SessionID,
							TransactionID,
							CountTranNotRequest,
							CountSessionNotRequest,
							TransactionBeginTime
						 )
	select SessionID,
		   TransactionID,
		   CountTranNotRequest,
		   CountSessionNotRequest,
		   TransactionBeginTime
	from srv.SessionTran
	where [CountTranNotRequest]>=@countIsNotRequests
	  and [CountSessionNotRequest]>=@countIsNotRequests
	  and [TransactionBeginTime]<=DateAdd(minute,-@minuteOld,GetDate());

	  --архивируем что собираемся удалить (детальная информация про удаляемые сессии, подключения и транзакции)
	  INSERT INTO [srv].[KillSession]
           ([session_id]
           ,[transaction_id]
           ,[login_time]
           ,[host_name]
           ,[program_name]
           ,[host_process_id]
           ,[client_version]
           ,[client_interface_name]
           ,[security_id]
           ,[login_name]
           ,[nt_domain]
           ,[nt_user_name]
           ,[status]
           ,[context_info]
           ,[cpu_time]
           ,[memory_usage]
           ,[total_scheduled_time]
           ,[total_elapsed_time]
           ,[endpoint_id]
           ,[last_request_start_time]
           ,[last_request_end_time]
           ,[reads]
           ,[writes]
           ,[logical_reads]
           ,[is_user_process]
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
           ,[original_security_id]
           ,[original_login_name]
           ,[last_successful_logon]
           ,[last_unsuccessful_logon]
           ,[unsuccessful_logons]
           ,[group_id]
           ,[database_id]
           ,[authenticating_database_id]
           ,[open_transaction_count]
           ,[most_recent_session_id]
           ,[connect_time]
           ,[net_transport]
           ,[protocol_type]
           ,[protocol_version]
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
           ,[connection_id]
           ,[parent_connection_id]
           ,[most_recent_sql_handle]
           ,[LastTSQL]
           ,[transaction_begin_time]
           ,[CountTranNotRequest]
           ,[CountSessionNotRequest])
	select ES.[session_id]
           ,kc.[TransactionID]
           ,ES.[login_time]
           ,ES.[host_name]
           ,ES.[program_name]
           ,ES.[host_process_id]
           ,ES.[client_version]
           ,ES.[client_interface_name]
           ,ES.[security_id]
           ,ES.[login_name]
           ,ES.[nt_domain]
           ,ES.[nt_user_name]
           ,ES.[status]
           ,ES.[context_info]
           ,ES.[cpu_time]
           ,ES.[memory_usage]
           ,ES.[total_scheduled_time]
           ,ES.[total_elapsed_time]
           ,ES.[endpoint_id]
           ,ES.[last_request_start_time]
           ,ES.[last_request_end_time]
           ,ES.[reads]
           ,ES.[writes]
           ,ES.[logical_reads]
           ,ES.[is_user_process]
           ,ES.[text_size]
           ,ES.[language]
           ,ES.[date_format]
           ,ES.[date_first]
           ,ES.[quoted_identifier]
           ,ES.[arithabort]
           ,ES.[ansi_null_dflt_on]
           ,ES.[ansi_defaults]
           ,ES.[ansi_warnings]
           ,ES.[ansi_padding]
           ,ES.[ansi_nulls]
           ,ES.[concat_null_yields_null]
           ,ES.[transaction_isolation_level]
           ,ES.[lock_timeout]
           ,ES.[deadlock_priority]
           ,ES.[row_count]
           ,ES.[prev_error]
           ,ES.[original_security_id]
           ,ES.[original_login_name]
           ,ES.[last_successful_logon]
           ,ES.[last_unsuccessful_logon]
           ,ES.[unsuccessful_logons]
           ,ES.[group_id]
           ,ES.[database_id]
           ,ES.[authenticating_database_id]
           ,ES.[open_transaction_count]
           ,EC.[most_recent_session_id]
           ,EC.[connect_time]
           ,EC.[net_transport]
           ,EC.[protocol_type]
           ,EC.[protocol_version]
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
           ,EC.[connection_id]
           ,EC.[parent_connection_id]
           ,EC.[most_recent_sql_handle]
           ,(select top(1) text from sys.dm_exec_sql_text(EC.[most_recent_sql_handle])) as [LastTSQL]
           ,kc.[TransactionBeginTime]
           ,kc.[CountTranNotRequest]
           ,kc.[CountSessionNotRequest]
	from @kills_copy as kc
	inner join sys.dm_exec_sessions ES with(readuncommitted) on kc.[SessionID]=ES.[session_id]
	inner join sys.dm_exec_connections EC  with(readuncommitted) on EC.session_id = ES.session_id;

	--собираем сессии
	insert into @kills (
							SessionID
						 )
	select [SessionID]
	from @kills_copy
	group by [SessionID];
	
	declare @SessionID int;

	--непосредственное удаление выбранных сессий
	while(exists(select top(1) 1 from @kills))
	begin
		select top(1)
		@SessionID=[SessionID]
		from @kills;
    
    BEGIN TRY
		EXEC sp_executesql N'kill @SessionID',
						   N'@SessionID INT',
						   @SessionID;
    END TRY
    BEGIN CATCH
    END CATCH

		delete from @kills
		where [SessionID]=@SessionID;
	end

	select st.[SessionID]
		  ,st.[TransactionID]
		  into #tbl
	from srv.SessionTran as st
	where st.[CountTranNotRequest]>=250
	   or st.[CountSessionNotRequest]>=250
	   or exists(select top(1) 1 from @kills_copy kc where kc.[SessionID]=st.[SessionID]);

	--удаление обработанных записей, а также те, что невозможно удалить и они находятся слишком долго в таблице на рассмотрение
	delete from st
	from #tbl as t
	inner join srv.SessionTran as st on t.[SessionID]	 =st.[SessionID]
									and t.[TransactionID]=st.[TransactionID];

	drop table #tbl;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Определение зависших транзакций (забытых, у которых нет активных запросов) с последующим их удалением', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoKillSessionTranBegin';

