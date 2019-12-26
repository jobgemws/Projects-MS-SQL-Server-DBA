SET CONCAT_NULL_YIELDS_NULL, ANSI_NULLS, ANSI_PADDING, QUOTED_IDENTIFIER, ANSI_WARNINGS, ARITHABORT, XACT_ABORT ON
SET NUMERIC_ROUNDABORT, IMPLICIT_TRANSACTIONS OFF
GO

USE [SRV]
GO

IF DB_NAME() <> N'SRV' SET NOEXEC ON
GO


--
-- Set transaction isolation level
--
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO

--
-- Start Transaction
--
BEGIN TRANSACTION
GO

--
-- Create schema [zabbix]
--
CREATE SCHEMA [zabbix] AUTHORIZATION [dbo]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetSpaceusedDBServer]
--
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetSpaceusedDBServer]
AS
BEGIN
	/*
		информация о занятом месте в БД (данные+индексы) в МБ
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;

	declare @db_name nvarchar(255);
	declare @sql nvarchar(max);
	declare @tbl table ([DBName] nvarchar(255), [DBSizeMB] decimal(18,3), [UnallocatedSpaceMB] decimal(18,3), [ReservedMB] decimal(18,3), [DataMB] decimal(18,3), [IndexSizeMB] decimal(18,3), [UnusedMB] decimal(18,3));

	select [name]
	into #tbls
	from sys.databases
	where [is_read_only]=0
	and [state]=0 --ONLINE
	and [user_access]=0--MULTI_USER
	and [database_id]>4;

	while(exists(select top(1) 1 from #tbls))
	begin
		select top(1)
		@db_name=[name]
		from #tbls;

		set @sql=N'USE ['+@db_name+']; '+
		N'IF(object_id('+N''''+N'[inf].[SpaceusedDB]'+N''''+N') is not null) select [DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB] from [inf].[SpaceusedDB]();';

		insert into @tbl([DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB])
		exec sp_executesql @sql;

		delete from #tbls
		where [name]=@db_name;
	end

	drop table #tbls;

	select SUM([DataMB]+[IndexSizeMB]) as [value]
	from @tbl;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetSpaceusedDBServer]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает информацию о занятом месте в БД (данные+индексы) в МБ', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetSpaceusedDBServer'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetExistsErrorInLog]
--
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetExistsErrorInLog]
AS
BEGIN
	/*
		Признак существования в журнале ошибок MS SQL Server подозрительных записей
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	declare @rez bit=0;

	declare @dt datetime=DateAdd(hour, -3, GetDate());
	declare @str nvarchar(255)=cast(@dt as nvarchar(255));
	
	declare @tbl table ([LogDate] datetime, [ProcessInfo] nvarchar(255), [Text] nvarchar(max));
	declare @tbl_filtered table ([LogDate] datetime, [ProcessInfo] nvarchar(255), [Text] nvarchar(max));

	declare @server_name nvarchar(255)=cast(SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS') as nvarchar(255));

	if((left(@server_name,3) in (N'PRD')) or (@server_name like 'SQL_SERVICES%') or (@server_name in ('com-dba-01')))
	begin
		--читкаем текущий журнал
		insert into @tbl ([LogDate], [ProcessInfo], [Text])
		EXEC master.dbo.xp_readerrorlog 0, 1, N'cost limit', NULL, @str, NULL, 'DESC'; --один раз-пищать
		
		insert into @tbl ([LogDate], [ProcessInfo], [Text])
		EXEC master.dbo.xp_readerrorlog 0, 1, N'failed', NULL, @str, NULL, 'DESC';--при [ProcessInfo]='Logon' проверить частоту, а в остальных случаях-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 1, 1, N'cost limit', NULL, NULL, NULL, 'DESC'; --один раз-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 1, 1, N'failed', NULL, NULL, NULL, 'DESC';--при [ProcessInf`o]='Logon' проверить частоту, а в остальных случаях-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 2, 1, N'cost limit', NULL, NULL, NULL, 'DESC'; --один раз-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 2, 1, N'failed', NULL, NULL, NULL, 'DESC';--при [ProcessInfo]='Logon' проверить частоту, а в остальных случаях-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 3, 1, N'cost limit', NULL, NULL, NULL, 'DESC'; --один раз-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 3, 1, N'failed', NULL, NULL, NULL, 'DESC';--при [ProcessInfo]='Logon' проверить частоту, а в остальных случаях-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 4, 1, N'cost limit', NULL, NULL, NULL, 'DESC'; --один раз-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 4, 1, N'failed', NULL, NULL, NULL, 'DESC';--при [ProcessInfo]='Logon' проверить частоту, а в остальных случаях-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 5, 1, N'cost limit', NULL, NULL, NULL, 'DESC'; --один раз-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 5, 1, N'failed', NULL, NULL, NULL, 'DESC';--при [ProcessInfo]='Logon' проверить частоту, а в остальных случаях-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 6, 1, N'cost limit', NULL, NULL, NULL, 'DESC'; --один раз-пищать
		
		--insert into @tbl ([LogDate], [ProcessInfo], [Text])
		--EXEC master.dbo.xp_readerrorlog 6, 1, N'failed', NULL, NULL, NULL, 'DESC';--при [ProcessInfo]='Logon' проверить частоту, а в остальных случаях-пищать
		
		insert into @tbl_filtered ([LogDate], [ProcessInfo], [Text])
		select [LogDate], [ProcessInfo], [Text]
		from @tbl
		where [Text] not like N'Audit: Server Audit: %Initialized and Assigned State: START_FAILED'
		  and [Text] <> N'Creating view sysmail_faileditems...'
		  and [Text] not like N'Configuration option % changed from %. Run the RECONFIGURE statement to install.'
		
		  --and [Text] <> N'Perfmon counters for resource governor pools and groups failed to initialize and are disabled.'
		  --and [Text] <> N'A read operation on a large object failed while sending data to the client. A common cause for this is if the application is running in READ UNCOMMITTED isolation level. This connection will be terminated.'
		  --and [Text] <> N'Implied authentication manager initialization failed. Implied authentication will be disabled.'
		  --and [Text] <> N'InitializeExternalUserGroupSid failed. Implied authentication will be disabled.'
		  --and [Text] not like N'Login failed%'
		  --and [Text] not like N'BACKUP failed to complete the command BACKUP%'
		  --and [Text] not like N'The client was unable to reuse a session with SPID %, which had been reset for connection pooling. The failure ID is %. This error may have been caused by an earlier operation failing. Check the error logs for failed operations immediately before this error message.'
		  --and [Text] not like N'BackupDiskFile::CreateMedia: Backup device %'
		  --and [Text] not like N'FCB::Open failed: Could not open file %'
		  --and [Text] not like N'One or more recovery units belonging to database % failed to generate a checkpoint. This is typically caused by lack of system resources such as disk or memory, or in some cases due to database corruption. Examine previous entries in the error log for more detailed information on this failure.'
		  --and [Text] not like N'SSPI handshake failed with error code %, state % while establishing a connection with integrated security; the connection has been closed. Reason: AcceptSecurityContext failed. The Windows error code indicates the cause of failure. The logon attempt failed %'
		--group by [ProcessInfo], [Text]
		--where [LogDate]>='2019-05-14T00:00:00'
		
		if(exists(
					select top(1) 1
					from @tbl_filtered
					where [ProcessInfo]='Logon'
					group by [Text]
					having count(*)>=5
				 ))
		begin
			set @rez=1;
		end

		if(@rez=0)
		begin
			if(exists(
					select top(1) 1
					from @tbl_filtered
					where [Text] not like N'Login failed%'
				 ))
			begin
				set @rez=1;
			end
		end
	end
	else set @rez=0;

	select cast(@rez as int) as [value];
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetExistsErrorInLog]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает признак существования в журнале ошибок MS SQL Server подозрительных записей', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetExistsErrorInLog'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetActiveUserTransaction]
--
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetActiveUserTransaction]
AS
BEGIN
	/*
		Количество активных пользовательских транзакций
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	select count(*) as [count]
	from sys.dm_tran_session_transactions
	where [is_user_transaction]=1;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetActiveUserTransaction]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает количество активных пользовательских транзакций', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetActiveUserTransaction'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetActiveRequestProblemCount]
--
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetActiveRequestProblemCount]
	@diffSec    int       =20 --20 секунд на мониториг долгих запросов ctr'SELECT', 'INSERT', 'UPDATE', 'DELETE'
	,@diffSecBackUp    int       =300 --операции бэкпирования, анализ перестроение индексов
	,@Wait_Duration_ms int = 3000
	,@Wait_Duration_semaphore_ms int = 500
AS
BEGIN
	/*
		Количество проблемных запросов в режиме реального времени
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @data datetime=getdate();

	declare @server_name nvarchar(255)=cast(SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS') as nvarchar(255));
 
	select case when ((left(@server_name, 3) in (N'PRD', N'COM')) or (@server_name like N'SQL_SERVICES%')) then count(distinct ER.session_id) 
				else case when (count(distinct ER.session_id)>3) then 3 else count(distinct ER.session_id) end
		   end as [count]
	from sys.dm_exec_requests ER with(readuncommitted)
	inner join sys.dm_exec_sessions ES with(readuncommitted) on ES.session_id = ER.session_id
	left outer join sys.dm_os_waiting_tasks AS t with(readuncommitted) on(ER.session_id=t.blocking_session_id)
	where ER.connection_id is not null and
	((left(last_wait_type,3) ='LCK'/*локи*/ OR last_wait_type='AWAITING COMMAND' /*скорее всего косяк в коде разрабов или триггер, ожидание внешнее от приложений*/)
	  AND t.wait_duration_ms > @Wait_Duration_ms)
	    OR (last_wait_type in('RESOURCE_SEMAPHORE','RESOURCE_SEMAPHORE_QUERY_COMPILE' /*Нехватка RAM под запрос, утечки RAM*/,'PAGEIOLATCH_UP'
	  /*задача ожидает кратковременной блокировки буфера, находящегося в состоянии запроса ввода-вывода (часто связанно с tempdb)*/)
	  and ER.[start_time]<=DateAdd(ms, -@Wait_Duration_semaphore_ms, @data))
	   OR (ER.[start_time]<=DateAdd(second, -@diffSec, @data) AND ER.command in('SELECT', 'INSERT', 'UPDATE', 'DELETE')
	   OR (ER.[start_time]<=DateAdd(second, -@diffSecBackUp, @data) AND ER.command in('BACKUP LOG', 'BACKUP DATABASE', 'DBCC')
	   OR (ER.last_wait_type='CXPACKET' and ER.[start_time]<=DateAdd(second, -@diffSec, @data)))
	  ) and ER.session_id>50;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetActiveRequestProblemCount]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает количество проблемных запросов в режиме реального времени', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetActiveRequestProblemCount'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[SpaceusedDBServer]
--
GO


CREATE PROCEDURE [srv].[SpaceusedDBServer]
	@DB nvarchar(255)=NULL, --по конкретной БД или по всем
	@IsSystem bit=0 --включать ли системные БД
AS
BEGIN
	/*
		информация о распределении места в БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;

	declare @db_name nvarchar(255);
	declare @sql nvarchar(max);
	declare @tbl table ([DBName] nvarchar(255), [DBSizeMB] decimal(18,3), [UnallocatedSpaceMB] decimal(18,3), [ReservedMB] decimal(18,3), [DataMB] decimal(18,3), [IndexSizeMB] decimal(18,3), [UnusedMB] decimal(18,3));

	
	if(@DB is null)
	begin
		select [name]
		into #tbls
		from sys.databases
		where [is_read_only]=0
		and [state]=0 --ONLINE
		and [user_access]=0--MULTI_USER
		and (((@IsSystem=0 or @IsSystem is null) and [database_id]>4) or ([database_id] is not null));

		while(exists(select top(1) 1 from #tbls))
		begin
			select top(1)
			@db_name=[name]
			from #tbls;

			set @sql=N'USE ['+@db_name+']; '+
			N'IF(object_id('+N''''+N'[inf].[SpaceusedDB]'+N''''+N') is not null) select [DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB] from [inf].[SpaceusedDB]();';

			insert into @tbl([DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB])
			exec sp_executesql @sql;

			delete from #tbls
			where [name]=@db_name;
		end

		drop table #tbls;
	end
	else
	begin
		set @sql=N'USE ['+@DB+']; '+
			N'IF(object_id('+N''''+N'[inf].[SpaceusedDB]'+N''''+N') is not null) select [DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB] from [inf].[SpaceusedDB]();';

		insert into @tbl([DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB])
		exec sp_executesql @sql;
	end

	select [DBSizeMB],
		   [UnallocatedSpaceMB],
		   [ReservedMB],
		   [DataMB],
		   [IndexSizeMB],
		   [UnusedMB]
	from @tbl;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [srv].[SpaceusedDBServer]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает информацию о распределении места в БД', 'SCHEMA', N'srv', 'PROCEDURE', N'SpaceusedDBServer'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[AutoShrinkLog]
--
GO

CREATE PROCEDURE [srv].[AutoShrinkLog]
	@max_size_mb int=16000 --при каком размере в МБ сжимать журнал транзакции БД
AS
BEGIN
	/*
		автосжатие журналов транзакций БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @sql nvarchar(max);
	declare @db nvarchar(255);
	declare @file nvarchar(255);
	
	select db.[name] as [db], mf.[name] as [file]
	into #files
	from [master].[sys].[databases] as db
	inner join [master].[sys].[master_files] as mf on db.[database_id]=mf.[database_id]
	where db.[is_read_only]=0				--WRITE
	and	  db.[state]=0						--ONLINE
	and	  db.[user_access]=0				--MULTI_USER
	and	  mf.[type]=1						--LOG
	and   mf.[state]=0						--ONLINE
	and	  mf.[size]>=@max_size_mb*1024/8	--SIZE FILE>=16 GB
	;
	
	DECLARE sql_cursor CURSOR LOCAL FOR
	select [db], [file]
	from #files;
	
	OPEN sql_cursor;
	  
	FETCH NEXT FROM sql_cursor   
	INTO @db, @file;
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		set @sql=N'USE ['+@db+N'];DBCC SHRINKFILE (N'''+@file+N''', '+cast(@max_size_mb as nvarchar(255))+N', TRUNCATEONLY);';

		begin try
		execute sp_executesql @sql;
		end try
		begin catch
		end catch
	
		FETCH NEXT FROM sql_cursor
		INTO @db, @file;
	END   
	
	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
	
	drop table #files;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [srv].[AutoShrinkLog]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Выполняет автосжатие журналов транзакций БД', 'SCHEMA', N'srv', 'PROCEDURE', N'AutoShrinkLog'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[AutoFlushLog]
--
GO

CREATE PROCEDURE [srv].[AutoFlushLog]
AS
BEGIN
	/*
		фиксация всех отложенных транзакций всех БД экземпляра MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @db nvarchar(255);
	declare @sql nvarchar(max);

	select [name]
	into #tbl
	from sys.databases
	where [delayed_durability]<>0;
	
	DECLARE sql_cursor CURSOR LOCAL FOR
	select [name]
	from #tbl;
	
	OPEN sql_cursor;
	  
	FETCH NEXT FROM sql_cursor   
	INTO @db;
	
	while (@@FETCH_STATUS = 0 )
	begin
		set @sql='EXEC ['+@db+'].[sys].[sp_flush_log];';
		
		begin try
			exec sp_executesql @sql;
		end try
		begin catch
		end catch
	
		FETCH NEXT FROM sql_cursor
		INTO @db;
	end
	
	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
	
	drop table #tbl;
END


GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [srv].[AutoFlushLog]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Фиксирует все отложенные транзакции всех БД экземпляра MS SQL Server', 'SCHEMA', N'srv', 'PROCEDURE', N'AutoFlushLog'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[AutoDeleteSnapshotNotDB]
--
GO


CREATE PROCEDURE [srv].[AutoDeleteSnapshotNotDB]
	@path varchar(2000)='E:\DB\'
AS
BEGIN
	/*
		удаление моментальных снимков, которые не привязаны к текущим БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	set xact_abort on;
	 
	declare @table table(a varchar(4000), b int, c int);
	 
	insert into @table(a,b,c)
	exec xp_dirtree @path, 1, 1;
	 
	declare @SQL varchar(max)='';
	 
	select @SQL=@SQL+'
	exec xp_cmdshell ''del '+@path+''+b.a+'''
	'
	from
	(select b.physical_name as physical_name
	 from sys.databases a inner join sys.master_files as b on (a.database_id=b.database_id )
	where a.source_database_id is not null) as a
	full outer join @table as b on (a.physical_name=@path+b.a )
	where a.physical_name is null
	and b.a like '%.ss';
	 
	--заменить print на exec
	--print @SQL;
	
	if(len(@SQL)>1)	exec sp_executesql @SQL;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [srv].[AutoDeleteSnapshotNotDB]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Выполняет удаление моментальных снимков, которые не привязаны к текущим БД', 'SCHEMA', N'srv', 'PROCEDURE', N'AutoDeleteSnapshotNotDB'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[AutoDeleteFileNotDB]
--
GO


CREATE PROCEDURE [srv].[AutoDeleteFileNotDB]
	@path_data varchar(4000)='E:\sql_data\' --каталог mdf файлов
   ,@path_log varchar(4000)='F:\sql_log\' --каталог ldf файлов
AS
BEGIN
	/*
		удаление не привязанных к серверу MS SQL mdf, ldf файлов
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	set xact_abort on;
	 
	declare @tbl table(a varchar(4000),b int,c int, d int); --собираем содержимое файлов
 
	insert into @tbl(a,b,c) --mdf файлы собираем
	exec xp_dirtree @path_data,1,1;
	 
	update @tbl --метка для пути @path
	set d=1;
	 
	insert into @tbl(a,b,c) --ldf файлы собираем
	exec xp_dirtree @path_log,1,1
	 
	--в для @path2 получит значение null
	 
	declare @SQL nvarchar(max)=''--контейнер sql скрипта
	 
	select @SQL=@SQL+'
	exec xp_cmdshell ''del '+case when d=1 then @path_data+p.a else @path_log+p.a end+''''
	from
	(select db.name DB, mf.physical_name
	from sys.databases db
	INNER JOIN sys.master_files mf on(db.database_id=mf.database_id)
	where db.database_id>4 /*не системные, не смотрим онлайн БД и пр. это не важно*/) db
	right outer join @tbl p ON(db.physical_name=case when d=1 then @path_data+p.a else @path_log+p.a end)
	where db.DB is null
	and (p.a like '%.mdf' or p.a like '%.ldf');
	 
	begin try
	    exec sp_executesql @SQL; --выполняем удаление файлов (поскольку они не связанны, то должны удаляться на ура)
	    print @SQL;--печатаем скрипт
	end try
	begin catch --Обработчик ошибок
	    IF @@ERROR<>0
	    begin
	        print @SQL;
	        select ERROR_MESSAGE() err_msg; --обработка ошибок
	    end
	end catch
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [srv].[AutoDeleteFileNotDB]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Выполняет удаление не привязанных к серверу MS SQL mdf, ldf файлов', 'SCHEMA', N'srv', 'PROCEDURE', N'AutoDeleteFileNotDB'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[AutoCHECKDB]
--
GO

CREATE PROCEDURE [srv].[AutoCHECKDB]
	@data_base nvarchar(max)=NULL --все БД или заданная
AS
BEGIN
	/*
		Проверка целостности данных БД
		https://www.sqlservercentral.com/blogs/run-dbcc-checkdb-on-a-regular-basis
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @dbName nvarchar(255);

	DECLARE @sqlCommand nvarchar(max);
	DECLARE @errorMsg	nvarchar(max);
	DECLARE @Return		int;
	
	DECLARE myCursor CURSOR FAST_FORWARD FOR 
	SELECT a.[name] AS LogicalName
	from SYS.databases as a
	WHERE (a.[name]=@data_base)
	   OR (@data_base IS NULL)
	--WHERE a.database_id > 4 --Only User DB 
	ORDER BY name DESC;
	
	OPEN myCursor;
	  
	FETCH NEXT FROM myCursor INTO @dbName;
	
	WHILE (@@FETCH_STATUS <> -1) 
	BEGIN
		SET @errorMsg = 'DB ['+@dbName+'] is corrupt'
		SET @sqlCommand = 'Use ['+@dbName+']'
	
		SET @sqlCommand += 'DBCC CHECKDB (['+@dbName +']) WITH PHYSICAL_ONLY,NO_INFOMSGS, ALL_ERRORMSGS';
	
		EXEC @Return = sp_executesql @sqlCommand;
	
		IF @Return <> 0 RAISERROR (@errorMsg , 11, 1);
	
		FETCH NEXT FROM myCursor INTO @dbName;
	END
	
	CLOSE myCursor;
	DEALLOCATE myCursor;
END


GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [srv].[AutoCHECKDB]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Выполняет проверку целостности данных БД', 'SCHEMA', N'srv', 'PROCEDURE', N'AutoCHECKDB'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[AutoAllDBForDurabilityForced]
--
GO



CREATE PROCEDURE [srv].[AutoAllDBForDurabilityForced]
AS
BEGIN
	/*
		перевод всех несистемных БД в режим полностью отложенных транзакций (неустойчивых)
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @sql nvarchar(max);
	declare @db nvarchar(255);
	
	select [name]
	into #tbl_db
	from sys.databases
	where [source_database_id] is null
	  and [database_id]>4
	  and [state]=0
	  and [is_read_only]=0
	  and [delayed_durability]<>2;
	
	DECLARE sql_cursor CURSOR LOCAL FOR
	select [name]
	from #tbl_db;
		
	OPEN sql_cursor;
		  
	FETCH NEXT FROM sql_cursor   
	INTO @db;
	
	while (@@FETCH_STATUS = 0 )
	begin
		select @sql='ALTER DATABASE ['+@db+'] SET DELAYED_DURABILITY = FORCED WITH NO_WAIT';
	
		print @sql
	
		exec sp_executesql @sql;
		
		FETCH NEXT FROM sql_cursor
			INTO @db;
	end
	
	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
	
	drop table #tbl_db;
END


GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [srv].[AutoAllDBForDurabilityForced]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Выполняет перевод всех несистемных БД в режим полностью отложенных транзакций (неустойчивых)', 'SCHEMA', N'srv', 'PROCEDURE', N'AutoAllDBForDurabilityForced'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[AutoUpdateStatisticsDB]
--
GO

ALTER PROCEDURE [srv].[AutoUpdateStatisticsDB]
	@DB nvarchar(255)=NULL, --по конкретной БД или по всем
	@ObjectSizeMB numeric (16,3) = NULL,
	--Максимальное кол-во строк в секции
	@row_count numeric (16,3) = NULL,
	@IsTempdb bit=0 --включать ли БД tempdb
AS
BEGIN
	/*
		вызов тонкой оптимизации статистики для заданной БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;

	declare @db_name nvarchar(255);
	declare @sql nvarchar(max);
	declare @ParmDefinition nvarchar(255)= N'@ObjectSizeMB numeric (16,3), @row_count numeric (16,3)';
	
	if(@DB is null)
	begin
		select [name]
		into #tbls
		from sys.databases
		where [is_read_only]=0
		and [state]=0 --ONLINE
		and [user_access]=0--MULTI_USER
		and (((@IsTempdb=0 or @IsTempdb is null) and [name]<>N'tempdb') or (@IsTempdb=1));

		while(exists(select top(1) 1 from #tbls))
		begin
			select top(1)
			@db_name=[name]
			from #tbls;

			set @sql=N'USE ['+@db_name+']; '+
			N'IF(object_id('+N''''+N'[srv].[AutoUpdateStatistics]'+N''''+N') is not null) EXEC [srv].[AutoUpdateStatistics] @ObjectSizeMB=@ObjectSizeMB, @row_count=@row_count;';

			exec sp_executesql @sql, @ParmDefinition, @ObjectSizeMB=@ObjectSizeMB, @row_count=@row_count;

			delete from #tbls
			where [name]=@db_name;
		end

		drop table #tbls;
	end
	else
	begin
		set @sql=N'USE ['+@DB+']; '+
		N'IF(object_id('+N''''+N'[srv].[AutoUpdateStatistics]'+N''''+N') is not null) EXEC [srv].[AutoUpdateStatistics] @ObjectSizeMB=@ObjectSizeMB, @row_count=@row_count;';

		exec sp_executesql @sql, @ParmDefinition, @ObjectSizeMB=@ObjectSizeMB, @row_count=@row_count;
	end
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[AutoUpdateStatistics]
--
GO

ALTER PROCEDURE [srv].[AutoUpdateStatistics]
	--Максимальный размер в МБ для рассматриваемого объекта
	@ObjectSizeMB numeric (16,3) = NULL,
	--Максимальное кол-во строк в секции
	@row_count numeric (16,3) = NULL
AS
BEGIN
	/*
		тонкое обновление статистики
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    declare @ObjectID int;
	declare @SchemaName nvarchar(255);
	declare @ObjectName nvarchar(255);
	declare @StatsID int;
	declare @StatName nvarchar(255);
	declare @SQL_Str nvarchar(max);
	
	;with st AS(
	select DISTINCT 
	obj.[object_id]
	, obj.[create_date]
	, OBJECT_SCHEMA_NAME(obj.[object_id]) as [SchemaName]
	, obj.[name] as [ObjectName]
	, CAST(
			(
			   --общее число страниц, зарезервированных в секции (по 8 КБ на 1024 поделить=поделить на 128)
				SELECT SUM(ps2.[reserved_page_count])/128.
				from sys.dm_db_partition_stats as ps2
				where ps2.[object_id] = obj.[object_id]
			) as numeric (38,2)
		  ) as [ObjectSizeMB] --размер объекта в МБ
	, s.[stats_id]
	, s.[name] as [StatName]
	, sp.[last_updated]
	, i.[index_id]
	, i.[type_desc]
	, i.[name] as [IndexName]
	, ps.[row_count]
	, s.[has_filter]
	, s.[no_recompute]
	, sp.[rows]
	, sp.[rows_sampled]
	--кол-во изменений вычисляется как:
	--сумма общего кол-ва изменений в начальном столбце статистики с момента последнего обновления статистики
	--и разности приблизительного кол-ва строк в секции и общего числа строк в таблице или индексированном представлении при последнем обновлении статистики
	, sp.[modification_counter]+ABS(ps.[row_count]-sp.[rows]) as [ModificationCounter]
	--% количества строк, выбранных для статистических вычислений,
	--к общему числу строк в таблице или индексированном представлении при последнем обновлении статистики
	, NULLIF(CAST( sp.[rows_sampled]*100./sp.[rows] as numeric(18,3)), 100.00) as [ProcSampled]
	--% общего кол-ва изменений в начальном столбце статистики с момента последнего обновления статистики
	--к приблизительному количество строк в секции
	, CAST(sp.[modification_counter]*100./(case when (ps.[row_count]=0) then 1 else ps.[row_count] end) as numeric (18,3)) as [ProcModified]
	--Вес объекта:
	--[ProcModified]*десятичный логарифм от приблизительного кол-ва строк в секции
	, CAST(sp.[modification_counter]*100./(case when (ps.[row_count]=0) then 1 else ps.[row_count] end) as numeric (18,3))
								* case when (ps.[row_count]<=10) THEN 1 ELSE LOG10 (ps.[row_count]) END as [Func]
	--было ли сканирование:
	--общее количество строк, выбранных для статистических вычислений, не равно
	--общему числу строк в таблице или индексированном представлении при последнем обновлении статистики
	, CASE WHEN sp.[rows_sampled]<>sp.[rows] THEN 0 ELSE 1 END as [IsScanned]
	, tbl.[name] as [ColumnType]
	, s.[auto_created]	
	from sys.objects as obj
	inner join sys.stats as s on s.[object_id] = obj.[object_id]
	left outer join sys.indexes as i on i.[object_id] = obj.[object_id] and (i.[name] = s.[name] or i.[index_id] in (0,1) 
					and not exists(select top(1) 1 from sys.indexes i2 where i2.[object_id] = obj.[object_id] and i2.[name] = s.[name]))
	left outer join sys.dm_db_partition_stats as ps on ps.[object_id] = obj.[object_id] and ps.[index_id] = i.[index_id]
	outer apply sys.dm_db_stats_properties (s.[object_id], s.[stats_id]) as sp
	left outer join sys.stats_columns as sc on s.[object_id] = sc.[object_id] and s.[stats_id] = sc.[stats_id]
	left outer join sys.columns as col on col.[object_id] = s.[object_id] and col.[column_id] = sc.[column_id]
	left outer join sys.types as tbl on col.[system_type_id] = tbl.[system_type_id] and col.[user_type_id] = tbl.[user_type_id]
	where obj.[type_desc] <> 'SYSTEM_TABLE'
	)
	SELECT
		st.[object_id]
		, st.[SchemaName]
		, st.[ObjectName]
		, st.[stats_id]
		, st.[StatName]
		INTO #tbl
	FROM st
	WHERE NOT (st.[row_count] = 0 AND st.[last_updated] IS NULL)--если нет данных и статистика не обновлялась
		--если нечего обновлять
		AND NOT (st.[row_count] = st.[rows] AND st.[row_count] = st.[rows_sampled] AND st.[ModificationCounter]=0)
		--если есть что обновлять (и данные существенно менялись)
		AND ((st.[ProcModified]>=10.0) OR (st.[Func]>=10.0) OR (st.[ProcSampled]<=50))
		--ограничения, выставленные во входных параметрах
		AND (
			 ([ObjectSizeMB]<=@ObjectSizeMB OR @ObjectSizeMB IS NULL)
			 AND
			 (st.[row_count]<=@row_count OR @row_count IS NULL)
			);
	
	WHILE (exists(select top(1) 1 from #tbl))
	BEGIN
		select top(1)
		@ObjectID	=[object_id]
		,@SchemaName=[SchemaName]
		,@ObjectName=[ObjectName]
		,@StatsId	=[stats_id]
		,@StatName	=[StatName]
		from #tbl;
	
		SET @SQL_Str = 'IF (EXISTS(SELECT TOP(1) 1 FROM sys.stats as s WHERE s.[object_id] = '+CAST(@ObjectID as nvarchar(32)) + 
						' AND s.[stats_id] = ' + CAST(@StatsId as nvarchar(32)) +')) UPDATE STATISTICS ' + QUOTENAME(@SchemaName) +'.' +
						QUOTENAME(@ObjectName) + ' ('+QUOTENAME(@StatName) + ') WITH FULLSCAN;';
	
		execute sp_executesql @SQL_Str;
	
		delete from #tbl
		where [object_id]=@ObjectID
		  and [stats_id]=@StatsId;
	END
	
	drop table #tbl;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[AutoReadWriteTablesStatistics]
--
GO
ALTER PROCEDURE [srv].[AutoReadWriteTablesStatistics]
AS
BEGIN
	/*
		Сбор данных по чтению/записи таблицы (кучи не рассматриваются, т к у них нет индексов).
		Только те таблицы, к которым обращались после запуска SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @dt date=CAST(GetUTCDate() as date);
    declare @dbs nvarchar(255);
	declare @sql nvarchar(max);

	select [name]
	into #dbs3
	from [master].sys.databases;

	DECLARE sql_cursor CURSOR LOCAL FOR
	select [name]
	from #dbs3;
	
	OPEN sql_cursor;
	  
	FETCH NEXT FROM sql_cursor   
	INTO @dbs;

	while (@@FETCH_STATUS = 0 )
	begin
		set @sql=N'USE ['+@dbs+N'];
		if(exists(select top(1) 1 from sys.views where [name]=''vReadWriteTables'' and [schema_id]=schema_id(''inf'')))
		begin
			INSERT INTO [SRV].[srv].[ReadWriteTablesStatistics]
			([ServerName]
		     ,[DBName]
		     ,[SchemaTableName]
		     ,[TableName]
		     ,[Reads]
		     ,[Writes]
		     ,[Reads&Writes]
		     ,[SampleDays]
		     ,[SampleSeconds])
			SELECT [ServerName]
		     ,[DBName]
		     ,[SchemaTableName]
		     ,[TableName]
		     ,[Reads]
		     ,[Writes]
		     ,[Reads&Writes]
		     ,[SampleDays]
		     ,[SampleSeconds]
			FROM ['+@dbs+N'].[inf].[vReadWriteTables];
		end';

		exec sp_executesql @sql;

		FETCH NEXT FROM sql_cursor
		INTO @dbs;
	end

	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[AutoIndexStatistics]
--
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [srv].[AutoIndexStatistics]
AS
BEGIN
	/*
		Сбор информацию по индексам и статистикам по всем помеченным БД экземпляра MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @dt date=CAST(GetUTCDate() as date);
    declare @dbs nvarchar(255);
	declare @sql nvarchar(max);

	--сбор фрагментации индексов
	select [name]
	into #dbs3
	from [master].sys.databases;

	while(exists(select top(1) 1 from #dbs3))
	begin
		select top(1)
		@dbs=[name]
		from #dbs3;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[inf].[vIndexDefrag]'+N''''+N') is not null) BEGIN '
		+N'insert into [SRV].[srv].[IndexDefragStatistics]
	         ([Server]
			 ,[db]
			 ,[shema]
			 ,[tb]
			 ,[idx]
			 ,[database_id]
			 ,[index_name]
			 ,[index_type_desc]
			 ,[level]
			 ,[object_id]
			 ,[frag_num]
			 ,[frag]
			 ,[frag_page]
			 ,[page]
			 ,[rec]
			 ,[ghost]
			 ,[func])
		SELECT @@SERVERNAME AS [Server]
		     ,[db]
			 ,[shema]
			 ,[tb]
			 ,[idx]
			 ,[database_id]
			 ,[index_name]
			 ,[index_type_desc]
			 ,[level]
			 ,[object_id]
			 ,[frag_num]
			 ,[frag]
			 ,[frag_page]
			 ,[page]
			 ,[rec]
			 ,[ghost]
			 ,[func]
		  FROM [inf].[vIndexDefrag]; END';

		exec sp_executesql @sql;

		delete from #dbs3
		where [name]=@dbs;
	end

	--сбор использования индексов
	select [name]
	into #dbs
	from sys.databases;

	while(exists(select top(1) 1 from #dbs))
	begin
		select top(1)
		@dbs=[name]
		from #dbs;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[inf].[vIndexUsageStats]'+N''''+N') is not null) BEGIN '
		+N'INSERT INTO [SRV].[srv].[IndexUsageStatsStatistics]
	         ([SERVER]
			,[DataBase]
			,[SCHEMA_NAME]
			,[OBJECT NAME]
			,[INDEX NAME]
			,[index_advantage]
			,[USER_SEEKS]
			,[USER_SCANS]
			,[USER_LOOKUPS]
			,[USER_UPDATES]
			,[Last_User_Seek]
			,[Last_User_Scan]
			,[Last_User_Lookup]
			,[Last_User_Update]
			,[System_Seeks]
			,[System_Scans]
			,[System_Lookups]
			,[System_Updates]
			,[Last_System_Seek]
			,[Last_System_Scan]
			,[Last_System_Lookup]
			,[Last_System_Update]
			,[schema_id]
			,[object_id]
			,[index_id]
			,[ObjectType]
			,[TYPE_DESC_OBJECT]
			,[IndexType]
			,[TYPE_DESC_INDEX]
			,[Is_Unique]
			,[Data_Space_ID]
			,[Ignore_Dup_Key]
			,[Is_Primary_Key]
			,[Is_Unique_Constraint]
			,[Fill_Factor]
			,[Is_Padded]
			,[Is_Disabled]
			,[Is_Hypothetical]
			,[Allow_Row_Locks]
			,[Allow_Page_Locks]
			,[Has_Filter]
			,[Filter_Definition]
			,[Columns]
			,[IncludeColumns])
	   SELECT @@SERVERNAME AS [Server]
			,DB_Name()
			,[SCHEMA_NAME]
			,[OBJECT NAME]
			,[INDEX NAME]
			,[index_advantage]
			,[USER_SEEKS]
			,[USER_SCANS]
			,[USER_LOOKUPS]
			,[USER_UPDATES]
			,[Last_User_Seek]
			,[Last_User_Scan]
			,[Last_User_Lookup]
			,[Last_User_Update]
			,[System_Seeks]
			,[System_Scans]
			,[System_Lookups]
			,[System_Updates]
			,[Last_System_Seek]
			,[Last_System_Scan]
			,[Last_System_Lookup]
			,[Last_System_Update]
			,[schema_id]
			,[object_id]
			,[index_id]
			,[ObjectType]
			,[TYPE_DESC_OBJECT]
			,[IndexType]
			,[TYPE_DESC_INDEX]
			,[Is_Unique]
			,[Data_Space_ID]
			,[Ignore_Dup_Key]
			,[Is_Primary_Key]
			,[Is_Unique_Constraint]
			,[Fill_Factor]
			,[Is_Padded]
			,[Is_Disabled]
			,[Is_Hypothetical]
			,[Allow_Row_Locks]
			,[Allow_Page_Locks]
			,[Has_Filter]
			,[Filter_Definition]
			,[Columns]
			,[IncludeColumns]
		FROM ['+@dbs+'].[inf].[vIndexUsageStats]; END';

		exec sp_executesql @sql;

		delete from #dbs
		where [name]=@dbs;
	end

	--сбор перекрывающихся индексов
	select [name]
	into #dbs4
	from sys.databases;

	while(exists(select top(1) 1 from #dbs4))
	begin
		select top(1)
		@dbs=[name]
		from #dbs4;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[srv].[vDelIndexInclude]'+N''''+N') is not null) BEGIN '
		+N'INSERT INTO [SRV].[srv].[DelIndexIncludeStatistics]
	         ([Server]
			,[DataBase]
			,[SchemaName]
			,[ObjectName]
			,[ObjectType]
			,[ObjectCreateDate]
			,[DelIndexName]
			,[IndexIsPrimaryKey]
			,[IndexType]
			,[IndexFragmentation]
			,[IndexFragmentCount]
			,[IndexAvgFragmentSizeInPages]
			,[IndexPages]
			,[IndexKeyColumns]
			,[IndexIncludedColumns]
			,[ActualIndexName])
	   SELECT @@SERVERNAME AS [Server]
			,DB_Name()
			,[SchemaName]
			,[ObjectName]
			,[ObjectType]
			,[ObjectCreateDate]
			,[DelIndexName]
			,[IndexIsPrimaryKey]
			,[IndexType]
			,[IndexFragmentation]
			,[IndexFragmentCount]
			,[IndexAvgFragmentSizeInPages]
			,[IndexPages]
			,[IndexKeyColumns]
			,[IndexIncludedColumns]
			,[ActualIndexName]
		FROM ['+@dbs+'].[srv].[vDelIndexInclude]; END';

		exec sp_executesql @sql;

		delete from #dbs4
		where [name]=@dbs;
	end

	--сбор устаревших статистик
	select [name]
	into #dbs5
	from sys.databases;

	while(exists(select top(1) 1 from #dbs5))
	begin
		select top(1)
		@dbs=[name]
		from #dbs5;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[inf].[vOldStatisticsState]'+N''''+N') is not null) BEGIN '
		+N'INSERT INTO [SRV].[srv].[OldStatisticsStateStatistics]
	         ([Server]
			,[DataBase]
			,[object_id]
			,[SchemaName]
			,[ObjectName]
			,[stats_id]
			,[StatName]
			,[row_count]
			,[ProcModified]
			,[ObjectSizeMB]
			,[type_desc]
			,[create_date]
			,[last_updated]
			,[ModificationCounter]
			,[ProcSampled]
			,[Func]
			,[IsScanned]
			,[ColumnType]
			,[auto_created]
			,[IndexName]
			,[has_filter])
	   SELECT @@SERVERNAME AS [Server]
			,DB_Name()
			,[object_id]
			,[SchemaName]
			,[ObjectName]
			,[stats_id]
			,[StatName]
			,[row_count]
			,[ProcModified]
			,[ObjectSizeMB]
			,[type_desc]
			,[create_date]
			,[last_updated]
			,[ModificationCounter]
			,[ProcSampled]
			,[Func]
			,[IsScanned]
			,[ColumnType]
			,[auto_created]
			,[IndexName]
			,[has_filter]
		FROM ['+@dbs+'].[inf].[vOldStatisticsState]; END';

		exec sp_executesql @sql;

		delete from #dbs5
		where [name]=@dbs;
	end

	drop table #dbs;
	drop table #dbs3;
	drop table #dbs4;
	drop table #dbs5;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetWriteStallMSTempDB]
--
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetWriteStallMSTempDB]
AS
BEGIN
	/*
		Максимальное из средних значений по задержке записи на файлы БД TempDB в МС
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	SELECT max([avg_write_stall_ms]) as [valueMS]
	FROM [srv].[vStatisticsIOInTempDB];
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetWriteStallMSTempDB]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает максимальное из средних значений по задержке записи на файлы БД TempDB в МС', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetWriteStallMSTempDB'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetReadStallMSTempDB]
--
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetReadStallMSTempDB]
AS
BEGIN
	/*
		Максимальное из средних значений по задержке чтения на файлы БД TempDB в МС
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	SELECT max([avg_read_stall_ms]) as [valueMS]
	FROM [srv].[vStatisticsIOInTempDB];
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetReadStallMSTempDB]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает максимальное из средних значений по задержке чтения на файлы БД TempDB в МС', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetReadStallMSTempDB'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create table [srv].[RAMSpaceStatistics]
--
CREATE TABLE [srv].[RAMSpaceStatistics] (
  [Server] [nvarchar](128) NOT NULL CONSTRAINT [DF_RAMSpaceStatistics_Server] DEFAULT (@@servername),
  [TotalAvailOSRam_Mb] [int] NOT NULL,
  [RAM_Avail_Percent] [numeric](5, 2) NOT NULL,
  [Server_physical_memory_Mb] [int] NOT NULL CONSTRAINT [DF_RAMSpaceStatistics_Server_physical_memory_Mb] DEFAULT (0),
  [SQL_server_committed_target_Mb] [int] NOT NULL CONSTRAINT [DF_RAMSpaceStatistics_SQL_server_committed_target_Mb] DEFAULT (0),
  [SQL_server_physical_memory_in_use_Mb] [int] NOT NULL CONSTRAINT [DF_RAMSpaceStatistics_SQL_server_physical_memory_in_use_Mb] DEFAULT (0),
  [State] [nvarchar](7) NOT NULL CONSTRAINT [DF_RAMSpaceStatistics_State] DEFAULT (0),
  [InsertUTCDate] [datetime] NOT NULL CONSTRAINT [DF_RAMSpaceStatistics_InsertUTCDate] DEFAULT (getutcdate())
)
ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create index [indInsertUTCDate] on table [srv].[RAMSpaceStatistics]
--
CREATE CLUSTERED INDEX [indInsertUTCDate]
  ON [srv].[RAMSpaceStatistics] ([InsertUTCDate])
  WITH (FILLFACTOR = 95)
  ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create table [srv].[DiskSpaceStatistics]
--
CREATE TABLE [srv].[DiskSpaceStatistics] (
  [Server] [nvarchar](128) NOT NULL CONSTRAINT [DF_DiskSpaceStatistics_Server] DEFAULT (@@servername),
  [Disk] [nvarchar](256) NOT NULL,
  [Disk_Space_Mb] [numeric](11, 2) NOT NULL,
  [Available_Mb] [numeric](11, 2) NOT NULL,
  [Available_Percent] [numeric](11, 2) NOT NULL,
  [State] [varchar](7) NOT NULL,
  [InsertUTCDate] [datetime] NOT NULL CONSTRAINT [DF_DiskSpaceStatistics_InsertUTCDate] DEFAULT (getutcdate())
)
ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create index [indInsertUTCDate] on table [srv].[DiskSpaceStatistics]
--
CREATE CLUSTERED INDEX [indInsertUTCDate]
  ON [srv].[DiskSpaceStatistics] ([InsertUTCDate])
  WITH (FILLFACTOR = 95)
  ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetForecastDiskMinAvailable_Mb]
--
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetForecastDiskMinAvailable_Mb]
AS
BEGIN
	/*
		Наиболее вероятное минимальное свободное место по всем дискам, которое будет через определенный промежуток времени
		Промежуток времени берется ровно столько, за сколько удалось собрать данные
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	declare @tbl table ([DATE] date, [MinAvailable_Mb] decimal(18,6), [MinAvailable_Percent] decimal(18,6), [Disk] nvarchar(255));
	declare @tbl_res table ([DiffMinAvailable_Mb] decimal(18,6), [DiffMinAvailable_Percent] decimal(18,6), [Disk] nvarchar(255));
	declare @curr table ([Disk] nvarchar (255), [MinAvailable_Mb] decimal(18,6));
	declare @diff table ([Disk] nvarchar (255), [Val] decimal(18,6));
	
	insert into @tbl ([DATE], [MinAvailable_Mb], [MinAvailable_Percent], [Disk])
	SELECT cast([InsertUTCDate] as date) as [DATE]
		  ,min([Available_Mb])			 as [MinAvailable_Mb]
	      ,min([Available_Percent])		 as [MinAvailable_Percent]
		  ,[Disk]
	  FROM [srv].[DiskSpaceStatistics]
	  where [Server]=@@SERVERNAME
	  group by cast([InsertUTCDate] as date), [Disk];
	
	;with tbl as (
		select [Disk], max([DATE]) as [DATE]
		from @tbl
		group by [Disk]
	)
	insert into @curr ([Disk], [MinAvailable_Mb])
	select t.[Disk], min(tt.[MinAvailable_Mb]) as [MinAvailable_Mb]
	from tbl as t
	inner join @tbl as tt on t.[Disk]=tt.[Disk] and t.[DATE]=tt.[DATE]
	group by t.[Disk];
	
	insert into @tbl_res ([DiffMinAvailable_Mb], [DiffMinAvailable_Percent], [Disk])
	select t.[MinAvailable_Mb]		-tt.[MinAvailable_Mb]				as [DiffMinAvailable_Mb]
		  ,t.[MinAvailable_Percent]	-tt.[MinAvailable_Percent]			as [DiffMinAvailable_Percent]
		  ,t.[Disk]
	from @tbl as t
	inner join @tbl as tt on t.[Disk]=tt.[Disk] and t.[DATE]=DateAdd(day,-1,tt.[DATE]);

	insert into @diff ([Disk], [Val])
	select t.[Disk],
		   (t.[MinAvailable_Mb]-(
								 select avg([DiffMinAvailable_Mb])*(
																	select count(*)
																	from @tbl_res as t0 
																	where t0.[Disk]=t.[Disk]
																   )
								 from @tbl_res as t0
								 where t0.[Disk]=t.[Disk]
								)
		   ) as [Val]
	from @curr as t;

	select coalesce(min([Val]), 8192) as [valueMB]
	from @diff;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetForecastDiskMinAvailable_Mb]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает наиболее вероятное минимальное свободное место по всем дискам, которое будет через определенный промежуток времени', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetForecastDiskMinAvailable_Mb'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[AutoStatisticsDiskAndRAMSpace]
--
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoStatisticsDiskAndRAMSpace]
AS
BEGIN
	/*
		Собирает информацию о емкостях логических дисков и ОЗУ
	*/
	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    --По дискам сингализация
	insert into [srv].[DiskSpaceStatistics] (
		   [Disk]
		 , [Disk_Space_Mb]
		 , [Available_Mb]
		 , [Available_Percent]
		 , [State]
	)
	select [Disk]
		 , [Disk_Space_Mb]
		 , [Available_Mb]
		 , [Available_Percent]
		 , (case when [Available_Percent]<=20 and [Available_Percent]>10 then 'Warning' when [Available_Percent]<=10 then 'Danger' else 'Normal' end) as [State]
	from
	(	SELECT  volume_mount_point as [Disk]
		, cast(((MAX(s.total_bytes))/1024.0)/1024.0 as numeric(11,2)) as Disk_Space_Mb
		, cast(((MIN(s.available_bytes))/1024.0)/1024.0 as numeric(11,2)) as Available_Mb
		, cast((MIN(available_bytes)/cast(MAX(total_bytes) as float))*100 as numeric(11,2)) as [Available_Percent]
		FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) as s
		GROUP BY volume_mount_point
	) as a;
	
	--ПО RAM сингализация
	insert into [srv].[RAMSpaceStatistics] (
		   [TotalAvailOSRam_Mb]
		 , [RAM_Avail_Percent]
		 , [Server_physical_memory_Mb]
		 , [SQL_server_committed_target_Mb]
		 , [SQL_server_physical_memory_in_use_Mb]
		 , [State]
	)
	select a0.[TotalAvailOSRam_Mb]
		 , a0.[RAM_Avail_Percent]
		 , ceiling(b.physical_memory_kb/1024.0) as [Server_physical_memory_Mb]
		 , ceiling(b.committed_target_kb/1024.0) as [SQL_server_committed_target_Mb]
		 , ceiling(a.physical_memory_in_use_kb/1024.0) as [SQL_server_physical_memory_in_use_Mb]
		 --, ceiling(v.available_physical_memory_kb/1024.0) as [available_physical_memory_Mb]
		 , (case when (ceiling(b.committed_target_kb/1024.0)-1024)<ceiling(a.physical_memory_in_use_kb/1024.0) then 'Warning' else 'Normal' end) as [State]
		 --, (case when [RAM_Avail_Percent]<=8 and [RAM_Avail_Percent]>5 then 'Warning' when [RAM_Avail_Percent]<=5 then 'Danger' else 'Normal' end) as [State]
	from
	(
		select cast(available_physical_memory_kb/1024.0 as int) as TotalAvailOSRam_Mb
			 , cast((available_physical_memory_kb/casT(total_physical_memory_kb as float))*100 as numeric(5,2)) as [RAM_Avail_Percent]
		from sys.dm_os_sys_memory
	) as a0
	cross join sys.dm_os_process_memory as a
	cross join sys.dm_os_sys_info as b
	cross join sys.dm_os_sys_memory as v;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [srv].[AutoStatisticsDiskAndRAMSpace]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Собирает информацию о емкостях логических дисков и ОЗУ', 'SCHEMA', N'srv', 'PROCEDURE', N'AutoStatisticsDiskAndRAMSpace'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create table [srv].[DBListNotDelete]
--
CREATE TABLE [srv].[DBListNotDelete] (
  [Name] [nvarchar](255) NOT NULL,
  [IsWhiteListAll] [bit] NOT NULL DEFAULT (0),
  CONSTRAINT [PK_DBListNotDelete] PRIMARY KEY CLUSTERED ([Name]) WITH (FILLFACTOR = 95)
)
ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create table [srv].[DBFileStatistics]
--
CREATE TABLE [srv].[DBFileStatistics] (
  [Server] [nvarchar](128) NOT NULL CONSTRAINT [DF_DBFileStatistics_Server] DEFAULT (@@servername),
  [DBName] [nvarchar](128) NOT NULL,
  [FileId] [smallint] NOT NULL,
  [NumberReads] [bigint] NOT NULL,
  [BytesRead] [bigint] NOT NULL,
  [IoStallReadMS] [bigint] NOT NULL,
  [NumberWrites] [bigint] NOT NULL,
  [BytesWritten] [bigint] NOT NULL,
  [IoStallWriteMS] [bigint] NOT NULL,
  [IoStallMS] [bigint] NOT NULL,
  [BytesOnDisk] [bigint] NOT NULL,
  [TimeStamp] [bigint] NOT NULL,
  [FileHandle] [varbinary](8) NOT NULL,
  [Type_desc] [nvarchar](60) COLLATE Latin1_General_CI_AS_KS_WS NULL,
  [FileName] [sysname] NOT NULL,
  [Drive] [nvarchar](1) NULL,
  [Physical_Name] [nvarchar](260) NOT NULL,
  [Ext] [nvarchar](3) NULL,
  [CountPage] [int] NOT NULL,
  [SizeMb] [float] NULL,
  [SizeGb] [float] NULL,
  [Growth] [int] NULL,
  [GrowthMb] [float] NULL,
  [GrowthGb] [float] NULL,
  [GrowthPercent] [int] NOT NULL,
  [is_percent_growth] [bit] NOT NULL,
  [database_id] [int] NOT NULL,
  [State] [tinyint] NULL,
  [StateDesc] [nvarchar](60) COLLATE Latin1_General_CI_AS_KS_WS NULL,
  [IsMediaReadOnly] [bit] NOT NULL,
  [IsReadOnly] [bit] NOT NULL,
  [IsSpace] [bit] NOT NULL,
  [IsNameReserved] [bit] NOT NULL,
  [CreateLsn] [numeric](25) NULL,
  [DropLsn] [numeric](25) NULL,
  [ReadOnlyLsn] [numeric](25) NULL,
  [ReadWriteLsn] [numeric](25) NULL,
  [DifferentialBaseLsn] [numeric](25) NULL,
  [DifferentialBaseGuid] [uniqueidentifier] NULL,
  [DifferentialBaseTime] [datetime] NULL,
  [RedoStartLsn] [numeric](25) NULL,
  [RedoStartForkGuid] [uniqueidentifier] NULL,
  [RedoTargetLsn] [numeric](25) NULL,
  [RedoTargetForkGuid] [uniqueidentifier] NULL,
  [BackupLsn] [numeric](25) NULL,
  [InsertUTCDate] [datetime] NOT NULL CONSTRAINT [DF_DBFileStatistics_InsertUTCDate] DEFAULT (getutcdate())
)
ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create index [indInsertUTCDate] on table [srv].[DBFileStatistics]
--
CREATE CLUSTERED INDEX [indInsertUTCDate]
  ON [srv].[DBFileStatistics] ([InsertUTCDate])
  WITH (FILLFACTOR = 95)
  ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create table [srv].[BigQueryGroupStatistics]
--
CREATE TABLE [srv].[BigQueryGroupStatistics] (
  [Server] [nvarchar](128) NOT NULL,
  [creation_time] [datetime] NULL,
  [last_execution_time] [datetime] NULL,
  [execution_count] [bigint] NULL,
  [CPU] [bigint] NULL,
  [AvgCPUTime] [money] NULL,
  [TotDuration] [bigint] NULL,
  [AvgDur] [money] NULL,
  [AvgIOLogicalReads] [money] NULL,
  [AvgIOLogicalWrites] [money] NULL,
  [AggIO] [bigint] NULL,
  [AvgIO] [money] NULL,
  [AvgIOPhysicalReads] [money] NULL,
  [plan_generation_num] [bigint] NULL,
  [AvgRows] [money] NULL,
  [AvgDop] [money] NULL,
  [AvgGrantKb] [money] NULL,
  [AvgUsedGrantKb] [money] NULL,
  [AvgIdealGrantKb] [money] NULL,
  [AvgReservedThreads] [money] NULL,
  [AvgUsedThreads] [money] NULL,
  [query_text] [nvarchar](max) NULL,
  [database_name] [nvarchar](128) NULL,
  [object_name] [nvarchar](257) NULL,
  [query_plan] [xml] NULL,
  [sql_handle] [varbinary](64) NULL,
  [plan_handle] [varbinary](64) NULL,
  [query_hash] [binary](8) NULL,
  [query_plan_hash] [binary](8) NULL,
  [InsertUTCDate] [datetime] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create index [indInsertUTCDate] on table [srv].[BigQueryGroupStatistics]
--
CREATE CLUSTERED INDEX [indInsertUTCDate]
  ON [srv].[BigQueryGroupStatistics] ([InsertUTCDate])
  WITH (FILLFACTOR = 95)
  ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create view [srv].[vBigQueryGroupStatisticsRemote]
--
GO
create view [srv].[vBigQueryGroupStatisticsRemote]
as
SELECT [Server]
      ,[creation_time]
      ,[last_execution_time]
      ,[execution_count]
      ,[CPU]
      ,[AvgCPUTime]
      ,[TotDuration]
      ,[AvgDur]
      ,[AvgIOLogicalReads]
      ,[AvgIOLogicalWrites]
      ,[AggIO]
      ,[AvgIO]
      ,[AvgIOPhysicalReads]
      ,[plan_generation_num]
      ,[AvgRows]
      ,[AvgDop]
      ,[AvgGrantKb]
      ,[AvgUsedGrantKb]
      ,[AvgIdealGrantKb]
      ,[AvgReservedThreads]
      ,[AvgUsedThreads]
      ,[query_text]
      ,[database_name]
      ,[object_name]
      ,cast([query_plan] as nvarchar(max)) as [query_plan]
      ,[sql_handle]
      ,[plan_handle]
      ,[query_hash]
      ,[query_plan_hash]
      ,[InsertUTCDate]
  FROM [srv].[BigQueryGroupStatistics]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [type_desc] on table [srv].[OldStatisticsStateStatistics]
--
ALTER TABLE [srv].[OldStatisticsStateStatistics]
  ALTER
    COLUMN [type_desc] [nvarchar](60) COLLATE Latin1_General_CI_AS_KS_WS
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create column [DataBase] on table [srv].[OldStatisticsStateStatistics]
--
ALTER TABLE [srv].[OldStatisticsStateStatistics]
  ADD [DataBase] [nvarchar](256) NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Drop index [indInsertUTCDate] from table [srv].[ListDefragIndex]
--
DROP INDEX [indInsertUTCDate] ON [srv].[ListDefragIndex]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Drop primary key [PK_ListDefragIndex] on table [srv].[ListDefragIndex]
--
ALTER TABLE [srv].[ListDefragIndex]
  DROP CONSTRAINT [PK_ListDefragIndex]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [db] on table [srv].[ListDefragIndex]
--
ALTER TABLE [srv].[ListDefragIndex]
  ALTER
    COLUMN [db] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [shema] on table [srv].[ListDefragIndex]
--
ALTER TABLE [srv].[ListDefragIndex]
  ALTER
    COLUMN [shema] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [table] on table [srv].[ListDefragIndex]
--
ALTER TABLE [srv].[ListDefragIndex]
  ALTER
    COLUMN [table] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [IndexName] on table [srv].[ListDefragIndex]
--
ALTER TABLE [srv].[ListDefragIndex]
  ALTER
    COLUMN [IndexName] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create primary key [PK_ListDefragIndex] on table [srv].[ListDefragIndex]
--
ALTER TABLE [srv].[ListDefragIndex]
  ADD CONSTRAINT [PK_ListDefragIndex] PRIMARY KEY CLUSTERED ([object_id], [idx], [db_id]) WITH (FILLFACTOR = 95)
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create index [indInsertUTCDate] on table [srv].[ListDefragIndex]
--
CREATE INDEX [indInsertUTCDate]
  ON [srv].[ListDefragIndex] ([InsertUTCDate])
  WITH (FILLFACTOR = 95)
  ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on index [srv].[ListDefragIndex].[indInsertUTCDate]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Индекс по InsertUTCDate', 'SCHEMA', N'srv', 'TABLE', N'ListDefragIndex', 'INDEX', N'indInsertUTCDate'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[AutoDefragIndexDB]
--
GO

ALTER PROCEDURE [srv].[AutoDefragIndexDB]
	@DB nvarchar(255)=NULL, --по конкретной БД или по всем
	@count int=NULL, --кол-во индексов для рассмотрения в каждой БД
	@IsTempdb bit=0 --включать ли БД tempdb
AS
BEGIN
	/*
		вызов оптимизации индексов для заданной БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;

	declare @db_name nvarchar(255);
	declare @sql nvarchar(max);
	declare @ParmDefinition nvarchar(255)= N'@count int';

	truncate table [SRV].[srv].[ListDefragIndex];
	
	if(@DB is null)
	begin
		select [name]
		into #tbls
		from sys.databases
		where [is_read_only]=0
		and [state]=0 --ONLINE
		and [user_access]=0--MULTI_USER
		and (((@IsTempdb=0 or @IsTempdb is null) and [name]<>N'tempdb') or (@IsTempdb=1));

		while(exists(select top(1) 1 from #tbls))
		begin
			select top(1)
			@db_name=[name]
			from #tbls;

			set @sql=N'USE ['+@db_name+']; '+
			N'IF(object_id('+N''''+N'[srv].[AutoDefragIndex]'+N''''+N') is not null) EXEC [srv].[AutoDefragIndex] @count=@count;';

			exec sp_executesql @sql, @ParmDefinition, @count=@count;

			delete from #tbls
			where [name]=@db_name;
		end

		drop table #tbls;
	end
	else
	begin
		set @sql=N'USE ['+@DB+']; '+
			N'IF(object_id('+N''''+N'[srv].[AutoDefragIndex]'+N''''+N') is not null) EXEC [srv].[AutoDefragIndex] @count=@count;';

		exec sp_executesql @sql, @ParmDefinition, @count=@count;
	end
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[AutoKillSessionTranBegin]
--
GO
ALTER PROCEDURE [srv].[AutoKillSessionTranBegin]
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
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create view [srv].[vIndicatorServerPred4DaysStatistics]
--
GO
create view [srv].[vIndicatorServerPred4DaysStatistics] as
with tbl as (
SELECT [Server]
      ,[ExecutionCount]
      ,[AvgDur]
      ,[AvgCPUTime]
      ,[AvgIOLogicalReads]
      ,[AvgIOLogicalWrites]
      ,[AvgIOPhysicalReads]
      ,[DATE]
	  ,row_number() over(partition by [Server] order by [DATE] asc) as Num
  FROM [srv].[IndicatorServerDayStatistics]
)
select t1.[Server]
      ,t1.[ExecutionCount]		as [ExecutionCountPred4Days]
	  ,t2.[ExecutionCount]		as [ExecutionCountPred3Days]
	  ,t3.[ExecutionCount]		as [ExecutionCountPred2Days]
	  ,t4.[ExecutionCount]		as [ExecutionCountPred1Days]
      ,t1.[AvgDur]				as [AvgDurPred4Days]
	  ,t2.[AvgDur]				as [AvgDurPred3Days]
	  ,t3.[AvgDur]				as [AvgDurPred2Days]
	  ,t4.[AvgDur]				as [AvgDurPred1Days]
      ,t1.[AvgCPUTime]			as [AvgCPUTimePred4Days]
	  ,t2.[AvgCPUTime]			as [AvgCPUTimePred3Days]
	  ,t3.[AvgCPUTime]			as [AvgCPUTimePred2Days]
	  ,t4.[AvgCPUTime]			as [AvgCPUTimePred1Days]
      ,t1.[AvgIOLogicalReads]	as [AvgIOLogicalReadsPred4Days]
	  ,t2.[AvgIOLogicalReads]	as [AvgIOLogicalReadsPred3Days]
	  ,t3.[AvgIOLogicalReads]	as [AvgIOLogicalReadsPred2Days]
	  ,t4.[AvgIOLogicalReads]	as [AvgIOLogicalReadsPred1Days]
      ,t1.[AvgIOLogicalWrites]	as [AvgIOLogicalWritesPred4Days]
	  ,t2.[AvgIOLogicalWrites]	as [AvgIOLogicalWritesPred3Days]
	  ,t3.[AvgIOLogicalWrites]	as [AvgIOLogicalWritesPred2Days]
	  ,t4.[AvgIOLogicalWrites]	as [AvgIOLogicalWritesPred1Days]
      ,t1.[AvgIOPhysicalReads]	as [AvgIOPhysicalReadsPred4Days]
	  ,t2.[AvgIOPhysicalReads]	as [AvgIOPhysicalReadsPred3Days]
	  ,t3.[AvgIOPhysicalReads]	as [AvgIOPhysicalReadsPred2Days]
	  ,t4.[AvgIOPhysicalReads]	as [AvgIOPhysicalReadsPred1Days]
      ,t1.[DATE]				as [DATEPred4Days]
	  ,t2.[DATE]				as [DATEPred3Days]
	  ,t3.[DATE]				as [DATEPred2Days]
	  ,t4.[DATE]				as [DATEPred1Days]
from tbl as t1
inner join tbl as t2 on t1.[Server]=t2.[Server] and t1.[Num]=t2.[Num]-1 and t2.[DATE]=cast(DateAdd(day,-3,GetUTCDate()) as DATE)
inner join tbl as t3 on t2.[Server]=t3.[Server] and t2.[Num]=t3.[Num]-1 and t3.[DATE]=cast(DateAdd(day,-2,GetUTCDate()) as DATE)
inner join tbl as t4 on t3.[Server]=t4.[Server] and t3.[Num]=t4.[Num]-1 and t4.[DATE]=cast(DateAdd(day,-1,GetUTCDate()) as DATE);
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [ObjectType] on table [srv].[IndexUsageStatsStatistics]
--
ALTER TABLE [srv].[IndexUsageStatsStatistics]
  ALTER
    COLUMN [ObjectType] [char](2) COLLATE Latin1_General_CI_AS_KS_WS
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [TYPE_DESC_OBJECT] on table [srv].[IndexUsageStatsStatistics]
--
ALTER TABLE [srv].[IndexUsageStatsStatistics]
  ALTER
    COLUMN [TYPE_DESC_OBJECT] [nvarchar](60) COLLATE Latin1_General_CI_AS_KS_WS
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [TYPE_DESC_INDEX] on table [srv].[IndexUsageStatsStatistics]
--
ALTER TABLE [srv].[IndexUsageStatsStatistics]
  ALTER
    COLUMN [TYPE_DESC_INDEX] [nvarchar](60) COLLATE Latin1_General_CI_AS_KS_WS
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create column [DataBase] on table [srv].[IndexUsageStatsStatistics]
--
ALTER TABLE [srv].[IndexUsageStatsStatistics]
  ADD [DataBase] [nvarchar](256) NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [ObjectType] on table [srv].[DelIndexIncludeStatistics]
--
ALTER TABLE [srv].[DelIndexIncludeStatistics]
  ALTER
    COLUMN [ObjectType] [nvarchar](60) COLLATE Latin1_General_CI_AS_KS_WS
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create column [DataBase] on table [srv].[DelIndexIncludeStatistics]
--
ALTER TABLE [srv].[DelIndexIncludeStatistics]
  ADD [DataBase] [nvarchar](256) NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [Server] on table [srv].[DefragServers]
--
ALTER TABLE [srv].[DefragServers]
  ALTER
    COLUMN [Server] [nvarchar](255)
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [db] on table [srv].[DefragServers]
--
ALTER TABLE [srv].[DefragServers]
  ALTER
    COLUMN [db] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [shema] on table [srv].[DefragServers]
--
ALTER TABLE [srv].[DefragServers]
  ALTER
    COLUMN [shema] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [table] on table [srv].[DefragServers]
--
ALTER TABLE [srv].[DefragServers]
  ALTER
    COLUMN [table] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [IndexName] on table [srv].[DefragServers]
--
ALTER TABLE [srv].[DefragServers]
  ALTER
    COLUMN [IndexName] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[ID]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Record ID', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'ID'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[db]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'DB', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'db'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[shema]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Scheme', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'shema'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[table]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Table', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'table'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[IndexName]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Index', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'IndexName'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[frag_num]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'The number of fragments at the leaf level of the distribution unit IN_ROW_DATA
NULL for non-finite index levels and LOB_DATA or ROW_OVERFLOW_DATA distribution units.

NULL value for heaps if mode = SAMPLED is specified
sys.dm_db_index_physical_stats', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'frag_num'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[frag]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Fragmentation in%', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'frag'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[page]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Number of pages occupied by the index', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'page'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[rec]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Total number of records', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'rec'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[ts]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Date and time of the start of the index defragmentation process', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'ts'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[tf]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Date and time of the end of the index defragmentation process', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'tf'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[frag_after]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Fragmentation in% after the defragmentation process', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'frag_after'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[object_id]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Object identifier', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'object_id'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[idx]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'
Index identifier', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'idx'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on column [srv].[Defrag].[InsertUTCDate]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'Date and time of record creation in UTC', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'COLUMN', N'InsertUTCDate'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Drop index [IndMain] from table [srv].[Defrag]
--
DROP INDEX [IndMain] ON [srv].[Defrag]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Drop index [indInsertUTCDate] from table [srv].[Defrag]
--
DROP INDEX [indInsertUTCDate] ON [srv].[Defrag]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Drop primary key [PK_Defrag] on table [srv].[Defrag]
--
ALTER TABLE [srv].[Defrag]
  DROP CONSTRAINT [PK_Defrag]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [db] on table [srv].[Defrag]
--
ALTER TABLE [srv].[Defrag]
  ALTER
    COLUMN [db] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [shema] on table [srv].[Defrag]
--
ALTER TABLE [srv].[Defrag]
  ALTER
    COLUMN [shema] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [table] on table [srv].[Defrag]
--
ALTER TABLE [srv].[Defrag]
  ALTER
    COLUMN [table] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter column [IndexName] on table [srv].[Defrag]
--
ALTER TABLE [srv].[Defrag]
  ALTER
    COLUMN [IndexName] [nvarchar](255) NOT NULL
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create column [Server] on table [srv].[Defrag]
--
ALTER TABLE [srv].[Defrag]
  ADD [Server] [nvarchar](255) NOT NULL CONSTRAINT [DF_Defrag_Server] DEFAULT (@@servername)
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create primary key [PK_Defrag] on table [srv].[Defrag]
--
ALTER TABLE [srv].[Defrag]
  ADD CONSTRAINT [PK_Defrag] PRIMARY KEY CLUSTERED ([ID]) WITH (FILLFACTOR = 95)
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create index [indInsertUTCDate] on table [srv].[Defrag]
--
CREATE INDEX [indInsertUTCDate]
  ON [srv].[Defrag] ([InsertUTCDate])
  WITH (FILLFACTOR = 90)
  ON [PRIMARY]
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on index [srv].[Defrag].[indInsertUTCDate]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Index on InsertUTCDate', 'SCHEMA', N'srv', 'TABLE', N'Defrag', 'INDEX', N'indInsertUTCDate'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Update extended property [MS_Description] on table [srv].[Defrag]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'History about the reorganization of the indexes of all databases of an instance of MS SQL Server', 'SCHEMA', N'srv', 'TABLE', N'Defrag'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Refresh view [srv].[vStatisticDefrag]
--
EXEC sp_refreshview '[srv].[vStatisticDefrag]'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[AutoDataCollectionRemote]
--
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [srv].[AutoDataCollectionRemote]
AS
BEGIN
	/*
		Сбор данных с удаленных серверов
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @sql nvarchar(max);
	declare @server sysname;
	declare @dt0 datetime=GetUTCDate();
	declare @dt datetime=DateAdd(hour, -16, @dt0);
	declare @existsSRV table([IsExists] bit);
	declare @IsSRV bit;

	select [name]
	into #tbl
	from sys.servers
	where [is_system]=0
	  and [is_linked]=1
	  and [name]<>N'sql_services';

	DECLARE sql_cursor CURSOR LOCAL FOR
	select [name]
	from #tbl;
	
	OPEN sql_cursor;
	  
	FETCH NEXT FROM sql_cursor   
	INTO @server;

	while (@@FETCH_STATUS = 0 )
	begin
		delete from @existsSRV;
		
		set @sql=N'
		if(exists(select top(1) 1 from ['+@server+N'].master.sys.databases where [name]=''SRV''))
		begin
			select 1;
		end
		else select 0;';

		insert into @existsSRV ([IsExists])
		exec sp_executesql @sql;

		select top(1)
		@IsSRV=[IsExists]
		from @existsSRV;
		
		if(@IsSRV=1)
		begin
			set @sql=N'
			begin
				INSERT INTO [srv].[WaitsStatistics]
					   ([Server]
					   ,[WaitType]
					   ,[Wait_S]
					   ,[Resource_S]
					   ,[Signal_S]
					   ,[WaitCount]
					   ,[Percentage]
					   ,[AvgWait_S]
					   ,[AvgRes_S]
					   ,[AvgSig_S]
					   ,[InsertUTCDate])
				SELECT  [Server]
					   ,[WaitType]
					   ,[Wait_S]
					   ,[Resource_S]
					   ,[Signal_S]
					   ,[WaitCount]
					   ,[Percentage]
					   ,[AvgWait_S]
					   ,[AvgRes_S]
					   ,[AvgSig_S]
					   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[WaitsStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

				INSERT INTO [srv].[ReadWriteTablesStatistics]
				   ([ServerName]
				   ,[DBName]
				   ,[SchemaTableName]
				   ,[TableName]
				   ,[Reads]
				   ,[Writes]
				   ,[Reads&Writes]
				   ,[SampleDays]
				   ,[SampleSeconds]
				   ,[InsertUTCDate])
				SELECT [ServerName]
				   ,[DBName]
				   ,[SchemaTableName]
				   ,[TableName]
				   ,[Reads]
				   ,[Writes]
				   ,[Reads&Writes]
				   ,[SampleDays]
				   ,[SampleSeconds]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[ReadWriteTablesStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

				INSERT INTO [srv].[OldStatisticsStateStatistics]
				   ([Server]
				   ,[DataBase]
				   ,[object_id]
				   ,[SchemaName]
				   ,[ObjectName]
				   ,[stats_id]
				   ,[StatName]
				   ,[row_count]
				   ,[ProcModified]
				   ,[ObjectSizeMB]
				   ,[type_desc]
				   ,[create_date]
				   ,[last_updated]
				   ,[ModificationCounter]
				   ,[ProcSampled]
				   ,[Func]
				   ,[IsScanned]
				   ,[ColumnType]
				   ,[auto_created]
				   ,[IndexName]
				   ,[has_filter]
				   ,[InsertUTCDate])
				SELECT [Server]
				   ,[DataBase]
				   ,[object_id]
				   ,[SchemaName]
				   ,[ObjectName]
				   ,[stats_id]
				   ,[StatName]
				   ,[row_count]
				   ,[ProcModified]
				   ,[ObjectSizeMB]
				   ,[type_desc]
				   ,[create_date]
				   ,[last_updated]
				   ,[ModificationCounter]
				   ,[ProcSampled]
				   ,[Func]
				   ,[IsScanned]
				   ,[ColumnType]
				   ,[auto_created]
				   ,[IndexName]
				   ,[has_filter]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[OldStatisticsStateStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[NewIndexOptimizeStatistics]
				   ([ServerName]
				   ,[DBName]
				   ,[Schema]
				   ,[Name]
				   ,[index_advantage]
				   ,[group_handle]
				   ,[unique_compiles]
				   ,[last_user_seek]
				   ,[last_user_scan]
				   ,[avg_total_user_cost]
				   ,[avg_user_impact]
				   ,[system_seeks]
				   ,[last_system_scan]
				   ,[last_system_seek]
				   ,[avg_total_system_cost]
				   ,[avg_system_impact]
				   ,[index_group_handle]
				   ,[index_handle]
				   ,[database_id]
				   ,[object_id]
				   ,[equality_columns]
				   ,[inequality_columns]
				   ,[statement]
				   ,[K]
				   ,[Keys]
				   ,[include]
				   ,[sql_statement]
				   ,[user_seeks]
				   ,[user_scans]
				   ,[est_impact]
				   ,[SecondsUptime]
				   ,[InsertUTCDate])
				SELECT [ServerName]
				   ,[DBName]
				   ,[Schema]
				   ,[Name]
				   ,[index_advantage]
				   ,[group_handle]
				   ,[unique_compiles]
				   ,[last_user_seek]
				   ,[last_user_scan]
				   ,[avg_total_user_cost]
				   ,[avg_user_impact]
				   ,[system_seeks]
				   ,[last_system_scan]
				   ,[last_system_seek]
				   ,[avg_total_system_cost]
				   ,[avg_system_impact]
				   ,[index_group_handle]
				   ,[index_handle]
				   ,[database_id]
				   ,[object_id]
				   ,[equality_columns]
				   ,[inequality_columns]
				   ,[statement]
				   ,[K]
				   ,[Keys]
				   ,[include]
				   ,[sql_statement]
				   ,[user_seeks]
				   ,[user_scans]
				   ,[est_impact]
				   ,[SecondsUptime]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[NewIndexOptimizeStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

				INSERT INTO [srv].[IndicatorServerDayStatistics]
				   ([Server]
				   ,[ExecutionCount]
				   ,[AvgDur]
				   ,[AvgCPUTime]
				   ,[AvgIOLogicalReads]
				   ,[AvgIOLogicalWrites]
				   ,[AvgIOPhysicalReads]
				   ,[DATE])
				SELECT [Server]
				   ,[ExecutionCount]
				   ,[AvgDur]
				   ,[AvgCPUTime]
				   ,[AvgIOLogicalReads]
				   ,[AvgIOLogicalWrites]
				   ,[AvgIOPhysicalReads]
				   ,[DATE]
				FROM ['+@server+N'].[SRV].[srv].[IndicatorServerDayStatistics] as t_src
				WHERE [DATE]>='''+cast(cast(DateAdd(day,-1,@dt0) as date) as nvarchar(255))+N'''
				and not exists (select top(1) 1 from [srv].[IndicatorServerDayStatistics] as t_trg where t_src.[DATE]=t_trg.[DATE] and t_src.[Server]=t_trg.[Server]);
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[IndexUsageStatsStatistics]
				   ([SERVER]
				   ,[DataBase]
				   ,[SCHEMA_NAME]
				   ,[OBJECT NAME]
				   ,[INDEX NAME]
				   ,[index_advantage]
				   ,[USER_SEEKS]
				   ,[USER_SCANS]
				   ,[USER_LOOKUPS]
				   ,[USER_UPDATES]
				   ,[Last_User_Seek]
				   ,[Last_User_Scan]
				   ,[Last_User_Lookup]
				   ,[Last_User_Update]
				   ,[System_Seeks]
				   ,[System_Scans]
				   ,[System_Lookups]
				   ,[System_Updates]
				   ,[Last_System_Seek]
				   ,[Last_System_Scan]
				   ,[Last_System_Lookup]
				   ,[Last_System_Update]
				   ,[schema_id]
				   ,[object_id]
				   ,[index_id]
				   ,[ObjectType]
				   ,[TYPE_DESC_OBJECT]
				   ,[IndexType]
				   ,[TYPE_DESC_INDEX]
				   ,[Is_Unique]
				   ,[Data_Space_ID]
				   ,[Ignore_Dup_Key]
				   ,[Is_Primary_Key]
				   ,[Is_Unique_Constraint]
				   ,[Fill_Factor]
				   ,[Is_Padded]
				   ,[Is_Disabled]
				   ,[Is_Hypothetical]
				   ,[Allow_Row_Locks]
				   ,[Allow_Page_Locks]
				   ,[Has_Filter]
				   ,[Filter_Definition]
				   ,[Columns]
				   ,[IncludeColumns]
				   ,[InsertUTCDate])
				SELECT [SERVER]
				   ,[DataBase]
				   ,[SCHEMA_NAME]
				   ,[OBJECT NAME]
				   ,[INDEX NAME]
				   ,[index_advantage]
				   ,[USER_SEEKS]
				   ,[USER_SCANS]
				   ,[USER_LOOKUPS]
				   ,[USER_UPDATES]
				   ,[Last_User_Seek]
				   ,[Last_User_Scan]
				   ,[Last_User_Lookup]
				   ,[Last_User_Update]
				   ,[System_Seeks]
				   ,[System_Scans]
				   ,[System_Lookups]
				   ,[System_Updates]
				   ,[Last_System_Seek]
				   ,[Last_System_Scan]
				   ,[Last_System_Lookup]
				   ,[Last_System_Update]
				   ,[schema_id]
				   ,[object_id]
				   ,[index_id]
				   ,[ObjectType]
				   ,[TYPE_DESC_OBJECT]
				   ,[IndexType]
				   ,[TYPE_DESC_INDEX]
				   ,[Is_Unique]
				   ,[Data_Space_ID]
				   ,[Ignore_Dup_Key]
				   ,[Is_Primary_Key]
				   ,[Is_Unique_Constraint]
				   ,[Fill_Factor]
				   ,[Is_Padded]
				   ,[Is_Disabled]
				   ,[Is_Hypothetical]
				   ,[Allow_Row_Locks]
				   ,[Allow_Page_Locks]
				   ,[Has_Filter]
				   ,[Filter_Definition]
				   ,[Columns]
				   ,[IncludeColumns]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[IndexUsageStatsStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

				INSERT INTO [srv].[IndexDefragStatistics]
				   ([Server]
				   ,[db]
				   ,[shema]
				   ,[tb]
				   ,[idx]
				   ,[database_id]
				   ,[index_name]
				   ,[index_type_desc]
				   ,[level]
				   ,[object_id]
				   ,[frag_num]
				   ,[frag]
				   ,[frag_page]
				   ,[page]
				   ,[rec]
				   ,[ghost]
				   ,[func]
				   ,[InsertUTCDate])
				SELECT [Server]
				   ,[db]
				   ,[shema]
				   ,[tb]
				   ,[idx]
				   ,[database_id]
				   ,[index_name]
				   ,[index_type_desc]
				   ,[level]
				   ,[object_id]
				   ,[frag_num]
				   ,[frag]
				   ,[frag_page]
				   ,[page]
				   ,[rec]
				   ,[ghost]
				   ,[func]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[IndexDefragStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[DelIndexIncludeStatistics]
				   ([Server]
				   ,[DataBase]
				   ,[SchemaName]
				   ,[ObjectName]
				   ,[ObjectType]
				   ,[ObjectCreateDate]
				   ,[DelIndexName]
				   ,[IndexIsPrimaryKey]
				   ,[IndexType]
				   ,[IndexFragmentation]
				   ,[IndexFragmentCount]
				   ,[IndexAvgFragmentSizeInPages]
				   ,[IndexPages]
				   ,[IndexKeyColumns]
				   ,[IndexIncludedColumns]
				   ,[ActualIndexName]
				   ,[InsertUTCDate])
				SELECT [Server]
				   ,[DataBase]
				   ,[SchemaName]
				   ,[ObjectName]
				   ,[ObjectType]
				   ,[ObjectCreateDate]
				   ,[DelIndexName]
				   ,[IndexIsPrimaryKey]
				   ,[IndexType]
				   ,[IndexFragmentation]
				   ,[IndexFragmentCount]
				   ,[IndexAvgFragmentSizeInPages]
				   ,[IndexPages]
				   ,[IndexKeyColumns]
				   ,[IndexIncludedColumns]
				   ,[ActualIndexName]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[DelIndexIncludeStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[BigQueryStatistics]
				   ([Server]
				   ,[creation_time]
				   ,[last_execution_time]
				   ,[execution_count]
				   ,[CPU]
				   ,[AvgCPUTime]
				   ,[TotDuration]
				   ,[AvgDur]
				   ,[AvgIOLogicalReads]
				   ,[AvgIOLogicalWrites]
				   ,[AggIO]
				   ,[AvgIO]
				   ,[AvgIOPhysicalReads]
				   ,[plan_generation_num]
				   ,[AvgRows]
				   ,[AvgDop]
				   ,[AvgGrantKb]
				   ,[AvgUsedGrantKb]
				   ,[AvgIdealGrantKb]
				   ,[AvgReservedThreads]
				   ,[AvgUsedThreads]
				   ,[query_text]
				   ,[database_name]
				   ,[object_name]
				   ,[query_plan]
				   ,[sql_handle]
				   ,[plan_handle]
				   ,[query_hash]
				   ,[query_plan_hash]
				   ,[InsertUTCDate])
				SELECT [Server]
				   ,[creation_time]
				   ,[last_execution_time]
				   ,[execution_count]
				   ,[CPU]
				   ,[AvgCPUTime]
				   ,[TotDuration]
				   ,[AvgDur]
				   ,[AvgIOLogicalReads]
				   ,[AvgIOLogicalWrites]
				   ,[AggIO]
				   ,[AvgIO]
				   ,[AvgIOPhysicalReads]
				   ,[plan_generation_num]
				   ,[AvgRows]
				   ,[AvgDop]
				   ,[AvgGrantKb]
				   ,[AvgUsedGrantKb]
				   ,[AvgIdealGrantKb]
				   ,[AvgReservedThreads]
				   ,[AvgUsedThreads]
				   ,[query_text]
				   ,[database_name]
				   ,[object_name]
				   ,cast([query_plan] as XML)
				   ,[sql_handle]
				   ,[plan_handle]
				   ,[query_hash]
				   ,[query_plan_hash]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[vBigQueryStatisticsRemote]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[TableStatistics]
				   ([ServerName]
				   ,[DBName]
				   ,[SchemaName]
				   ,[TableName]
				   ,[CountRows]
				   ,[DataKB]
				   ,[IndexSizeKB]
				   ,[UnusedKB]
				   ,[ReservedKB]
				   ,[InsertUTCDate]
				   ,[CountRowsBack]
				   ,[CountRowsNext]
				   ,[DataKBBack]
				   ,[DataKBNext]
				   ,[IndexSizeKBBack]
				   ,[IndexSizeKBNext]
				   ,[UnusedKBBack]
				   ,[UnusedKBNext]
				   ,[ReservedKBBack]
				   ,[ReservedKBNext]
				   ,[TotalPageSizeKB]
				   ,[TotalPageSizeKBBack]
				   ,[TotalPageSizeKBNext]
				   ,[UsedPageSizeKB]
				   ,[UsedPageSizeKBBack]
				   ,[UsedPageSizeKBNext]
				   ,[DataPageSizeKB]
				   ,[DataPageSizeKBBack]
				   ,[DataPageSizeKBNext])
				SELECT [ServerName]
				   ,[DBName]
				   ,[SchemaName]
				   ,[TableName]
				   ,[CountRows]
				   ,[DataKB]
				   ,[IndexSizeKB]
				   ,[UnusedKB]
				   ,[ReservedKB]
				   ,[InsertUTCDate]
				   ,[CountRowsBack]
				   ,[CountRowsNext]
				   ,[DataKBBack]
				   ,[DataKBNext]
				   ,[IndexSizeKBBack]
				   ,[IndexSizeKBNext]
				   ,[UnusedKBBack]
				   ,[UnusedKBNext]
				   ,[ReservedKBBack]
				   ,[ReservedKBNext]
				   ,[TotalPageSizeKB]
				   ,[TotalPageSizeKBBack]
				   ,[TotalPageSizeKBNext]
				   ,[UsedPageSizeKB]
				   ,[UsedPageSizeKBBack]
				   ,[UsedPageSizeKBNext]
				   ,[DataPageSizeKB]
				   ,[DataPageSizeKBBack]
				   ,[DataPageSizeKBNext]
				FROM ['+@server+N'].[SRV].[srv].[TableStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

				INSERT INTO [srv].[TableIndexStatistics]
				   ([ServerName]
				   ,[DBName]
				   ,[SchemaName]
				   ,[TableName]
				   ,[IndexUsedForCounts]
				   ,[CountRows]
				   ,[InsertUTCDate])
				SELECT [ServerName]
				   ,[DBName]
				   ,[SchemaName]
				   ,[TableName]
				   ,[IndexUsedForCounts]
				   ,[CountRows]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[TableIndexStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[ServerDBFileInfoStatistics]
				   ([ServerName]
				   ,[DBName]
				   ,[File_id]
				   ,[Type_desc]
				   ,[FileName]
				   ,[Drive]
				   ,[Ext]
				   ,[CountPage]
				   ,[SizeMb]
				   ,[SizeGb]
				   ,[InsertUTCDate])
				SELECT [ServerName]
				   ,[DBName]
				   ,[File_id]
				   ,[Type_desc]
				   ,[FileName]
				   ,[Drive]
				   ,[Ext]
				   ,[CountPage]
				   ,[SizeMb]
				   ,[SizeGb]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[ServerDBFileInfoStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

				INSERT INTO [srv].[DefragServers]
				   ([Server]
				   ,[db]
				   ,[shema]
				   ,[table]
				   ,[IndexName]
				   ,[frag_num]
				   ,[frag]
				   ,[page]
				   ,[rec]
				   ,[ts]
				   ,[tf]
				   ,[frag_after]
				   ,[object_id]
				   ,[idx]
				   ,[InsertUTCDate])
				SELECT '''+@server+N''' AS [Server]
				   ,[db]
				   ,[shema]
				   ,[table]
				   ,[IndexName]
				   ,[frag_num]
				   ,[frag]
				   ,[page]
				   ,[rec]
				   ,[ts]
				   ,[tf]
				   ,[frag_after]
				   ,[object_id]
				   ,[idx]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[Defrag]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[ShortInfoRunJobsServers]
				   ([Job_GUID]
				   ,[Job_Name]
				   ,[LastFinishRunState]
				   ,[LastRunDurationString]
				   ,[LastRunDurationInt]
				   ,[LastOutcomeMessage]
				   ,[LastRunOutcome]
				   ,[Server]
				   ,[InsertUTCDate]
				   ,[TargetServer]
				   ,[LastDateTime])
				SELECT [Job_GUID]
				   ,[Job_Name]
				   ,[LastFinishRunState]
				   ,[LastRunDurationString]
				   ,[LastRunDurationInt]
				   ,[LastOutcomeMessage]
				   ,[LastRunOutcome]
				   ,[Server]
				   ,[InsertUTCDate]
				   ,[TargetServer]
				   ,[LastDateTime]
				FROM ['+@server+N'].[SRV].[srv].[ShortInfoRunJobsServers]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

				INSERT INTO [srv].[StatisticsIOInTempDBStatistics]
				   ([Server]
				   ,[physical_name]
				   ,[name]
				   ,[num_of_writes]
				   ,[avg_write_stall_ms]
				   ,[num_of_reads]
				   ,[avg_read_stall_ms]
				   ,[InsertUTCDate])
				SELECT [Server]
				   ,[physical_name]
				   ,[name]
				   ,[num_of_writes]
				   ,[avg_write_stall_ms]
				   ,[num_of_reads]
				   ,[avg_read_stall_ms]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[StatisticsIOInTempDBStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[DiskSpaceStatistics]
				   ([Server]
				   ,[Disk]
				   ,[Disk_Space_Mb]
				   ,[Available_Mb]
				   ,[Available_Percent]
				   ,[State]
				   ,[InsertUTCDate])
				SELECT [Server]
				   ,[Disk]
				   ,[Disk_Space_Mb]
				   ,[Available_Mb]
				   ,[Available_Percent]
				   ,[State]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[DiskSpaceStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

				INSERT INTO [srv].[RAMSpaceStatistics]
				   ([Server]
				   ,[TotalAvailOSRam_Mb]
				   ,[RAM_Avail_Percent]
				   ,[Server_physical_memory_Mb]
				   ,[SQL_server_committed_target_Mb]
				   ,[SQL_server_physical_memory_in_use_Mb]
				   ,[State]
				   ,[InsertUTCDate])
				SELECT [Server]
				   ,[TotalAvailOSRam_Mb]
				   ,[RAM_Avail_Percent]
				   ,[Server_physical_memory_Mb]
				   ,[SQL_server_committed_target_Mb]
				   ,[SQL_server_physical_memory_in_use_Mb]
				   ,[State]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[RAMSpaceStatistics]
				WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
				  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[BigQueryGroupStatistics]
				   ([Server]
				   ,[creation_time]
				   ,[last_execution_time]
				   ,[execution_count]
				   ,[CPU]
				   ,[AvgCPUTime]
				   ,[TotDuration]
				   ,[AvgDur]
				   ,[AvgIOLogicalReads]
				   ,[AvgIOLogicalWrites]
				   ,[AggIO]
				   ,[AvgIO]
				   ,[AvgIOPhysicalReads]
				   ,[plan_generation_num]
				   ,[AvgRows]
				   ,[AvgDop]
				   ,[AvgGrantKb]
				   ,[AvgUsedGrantKb]
				   ,[AvgIdealGrantKb]
				   ,[AvgReservedThreads]
				   ,[AvgUsedThreads]
				   ,[query_text]
				   ,[database_name]
				   ,[object_name]
				   ,[query_plan]
				   ,[sql_handle]
				   ,[plan_handle]
				   ,[query_hash]
				   ,[query_plan_hash]
				   ,[InsertUTCDate])
				SELECT [Server]
				   ,[creation_time]
				   ,[last_execution_time]
				   ,[execution_count]
				   ,[CPU]
				   ,[AvgCPUTime]
				   ,[TotDuration]
				   ,[AvgDur]
				   ,[AvgIOLogicalReads]
				   ,[AvgIOLogicalWrites]
				   ,[AggIO]
				   ,[AvgIO]
				   ,[AvgIOPhysicalReads]
				   ,[plan_generation_num]
				   ,[AvgRows]
				   ,[AvgDop]
				   ,[AvgGrantKb]
				   ,[AvgUsedGrantKb]
				   ,[AvgIdealGrantKb]
				   ,[AvgReservedThreads]
				   ,[AvgUsedThreads]
				   ,[query_text]
				   ,[database_name]
				   ,[object_name]
				   ,cast([query_plan] as XML)
				   ,[sql_handle]
				   ,[plan_handle]
				   ,[query_hash]
				   ,[query_plan_hash]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[vBigQueryGroupStatisticsRemote];
			end';

			exec sp_executesql @sql;

			set @sql=N'
			begin
				INSERT INTO [srv].[DBFileStatistics]
				   ([Server]
				   ,[DBName]
				   ,[FileId]
				   ,[NumberReads]
				   ,[BytesRead]
				   ,[IoStallReadMS]
				   ,[NumberWrites]
				   ,[BytesWritten]
				   ,[IoStallWriteMS]
				   ,[IoStallMS]
				   ,[BytesOnDisk]
				   ,[TimeStamp]
				   ,[FileHandle]
				   ,[Type_desc]
				   ,[FileName]
				   ,[Drive]
				   ,[Physical_Name]
				   ,[Ext]
				   ,[CountPage]
				   ,[SizeMb]
				   ,[SizeGb]
				   ,[Growth]
				   ,[GrowthMb]
				   ,[GrowthGb]
				   ,[GrowthPercent]
				   ,[is_percent_growth]
				   ,[database_id]
				   ,[State]
				   ,[StateDesc]
				   ,[IsMediaReadOnly]
				   ,[IsReadOnly]
				   ,[IsSpace]
				   ,[IsNameReserved]
				   ,[CreateLsn]
				   ,[DropLsn]
				   ,[ReadOnlyLsn]
				   ,[ReadWriteLsn]
				   ,[DifferentialBaseLsn]
				   ,[DifferentialBaseGuid]
				   ,[DifferentialBaseTime]
				   ,[RedoStartLsn]
				   ,[RedoStartForkGuid]
				   ,[RedoTargetLsn]
				   ,[RedoTargetForkGuid]
				   ,[BackupLsn]
				   ,[InsertUTCDate])
				SELECT [Server]
				   ,[DBName]
				   ,[FileId]
				   ,[NumberReads]
				   ,[BytesRead]
				   ,[IoStallReadMS]
				   ,[NumberWrites]
				   ,[BytesWritten]
				   ,[IoStallWriteMS]
				   ,[IoStallMS]
				   ,[BytesOnDisk]
				   ,[TimeStamp]
				   ,[FileHandle]
				   ,[Type_desc]
				   ,[FileName]
				   ,[Drive]
				   ,[Physical_Name]
				   ,[Ext]
				   ,[CountPage]
				   ,[SizeMb]
				   ,[SizeGb]
				   ,[Growth]
				   ,[GrowthMb]
				   ,[GrowthGb]
				   ,[GrowthPercent]
				   ,[is_percent_growth]
				   ,[database_id]
				   ,[State]
				   ,[StateDesc]
				   ,[IsMediaReadOnly]
				   ,[IsReadOnly]
				   ,[IsSpace]
				   ,[IsNameReserved]
				   ,[CreateLsn]
				   ,[DropLsn]
				   ,[ReadOnlyLsn]
				   ,[ReadWriteLsn]
				   ,[DifferentialBaseLsn]
				   ,[DifferentialBaseGuid]
				   ,[DifferentialBaseTime]
				   ,[RedoStartLsn]
				   ,[RedoStartForkGuid]
				   ,[RedoTargetLsn]
				   ,[RedoTargetForkGuid]
				   ,[BackupLsn]
				   ,[InsertUTCDate]
				FROM ['+@server+N'].[SRV].[srv].[DBFileStatistics];
			end';

			exec sp_executesql @sql;--,
					  --N'@IsSRV bit',  
					  --@IsSRV = @IsSRV;
		end

		FETCH NEXT FROM sql_cursor
		INTO @server;
	end

	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;

	drop table #tbl;

	INSERT INTO [srv].[DefragServers]
			   ([Server]
			   ,[db]
			   ,[shema]
			   ,[table]
			   ,[IndexName]
			   ,[frag_num]
			   ,[frag]
			   ,[page]
			   ,[rec]
			   ,[ts]
			   ,[tf]
			   ,[frag_after]
			   ,[object_id]
			   ,[idx]
			   ,[InsertUTCDate])
		SELECT @@SERVERNAME AS [Server]
			   ,[db]
			   ,[shema]
			   ,[table]
			   ,[IndexName]
			   ,[frag_num]
			   ,[frag]
			   ,[page]
			   ,[rec]
			   ,[ts]
			   ,[tf]
			   ,[frag_after]
			   ,[object_id]
			   ,[idx]
			   ,[InsertUTCDate]
			FROM [srv].[Defrag]
			WHERE [InsertUTCDate]>=@dt
			  AND [InsertUTCDate]<=@dt0;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[DeleteArchive]
--
GO




ALTER PROCEDURE [srv].[DeleteArchive]
	@day int=14 -- кол-во дней, по которым определяется старость записи
AS
BEGIN
	/*
		удаление старых архивных записей из архивов
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;

	while(exists(select top(1) 1 from [srv].[ErrorInfoArchive] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ErrorInfoArchive]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ddl_log_all] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ddl_log_all]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[Defrag] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[Defrag]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[TableIndexStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[TableIndexStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[TableStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[TableStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[RequestStatisticsArchive] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[RequestStatisticsArchive]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ActiveConnectionStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ActiveConnectionStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ServerDBFileInfoStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ServerDBFileInfoStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[KillSession] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[KillSession]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[WaitsStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[WaitsStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[BigQueryStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[BigQueryStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[IndexDefragStatistics]	where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[IndexDefragStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[DefragServers]	where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[DefragServers]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ServerDBFileInfoStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ServerDBFileInfoStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[IndexUsageStatsStatistics]	where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[IndexUsageStatsStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[OldStatisticsStateStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[OldStatisticsStateStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[NewIndexOptimizeStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[NewIndexOptimizeStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[StatisticsIOInTempDBStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[StatisticsIOInTempDBStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[DelIndexIncludeStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[DelIndexIncludeStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ShortInfoRunJobsServers] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ShortInfoRunJobsServers]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ReadWriteTablesStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ReadWriteTablesStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[DiskSpaceStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[DiskSpaceStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[RAMSpaceStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[RAMSpaceStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[DBFileStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[DBFileStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end
END



GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[ClearFullInfo]
--
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [srv].[ClearFullInfo]
AS
BEGIN
	/*
		очищает все собранные данные
	*/
	SET NOCOUNT ON;

	--truncate table [srv].[BlockRequest];
	truncate table [srv].[DBFile];
	truncate table [srv].[ddl_log];
	truncate table [srv].[ddl_log_all];
	truncate table [srv].[Deadlocks];
	truncate table [srv].[Defrag];

	update [srv].[DefragRun]
	set [Run]=0;

    truncate table [srv].[ErrorInfo];
	truncate table [srv].[ErrorInfoArchive];
	truncate table [srv].[ListDefragIndex];

	truncate table [srv].[TableIndexStatistics];
	truncate table [srv].[TableStatistics];
	truncate table [srv].[RequestStatistics];
	truncate table [srv].[RequestStatisticsArchive];
	truncate table [srv].[QueryStatistics];
	truncate table [srv].[PlanQuery];
	truncate table [srv].[SQLQuery];
	truncate table [srv].[QueryRequestGroupStatistics];
	truncate table [srv].[ActiveConnectionStatistics];
	truncate table [srv].[ServerDBFileInfoStatistics];
	truncate table [srv].[ShortInfoRunJobs];

	truncate table [srv].[TSQL_DAY_Statistics];
	truncate table [srv].[IndicatorStatistics];
	truncate table [srv].[KillSession];
	truncate table [srv].[SessionTran];

	truncate table [srv].[WaitsStatistics];
	truncate table [srv].[BigQueryStatistics];
	truncate table [srv].[IndexDefragStatistics];
	truncate table [srv].[DefragServers];
	truncate table [srv].[ServerDBFileInfoStatistics];
	truncate table [srv].[IndexUsageStatsStatistics];
	truncate table [srv].[OldStatisticsStateStatistics];
	truncate table [srv].[NewIndexOptimizeStatistics];
	truncate table [srv].[StatisticsIOInTempDBStatistics];
	truncate table [srv].[DelIndexIncludeStatistics];
	truncate table [srv].[ShortInfoRunJobsServers];
	truncate table [srv].[ReadWriteTablesStatistics];
	truncate table [srv].[DiskSpaceStatistics];
	truncate table [srv].[RAMSpaceStatistics];

	truncate table [srv].[IndicatorServerDayStatistics];
	truncate table [srv].[DBFileStatistics];
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[GetHTMLTableShortInfoRunJobsServers]
--
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[GetHTMLTableShortInfoRunJobsServers]
	@Path nvarchar(255),
	@Filename nvarchar(255),
	@second int=60
AS
BEGIN
	/*
		формирует HTML-код для таблицы выполненных заданий
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage nvarchar(1000),
	    @Command nvarchar(1000),
	    @hr int,
		@fileAndPath varchar(80);

	select @strErrorMessage='opening the File System Object'
	EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT
	
	Select @FileAndPath=@path+'\'+@filename
	if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage='Creating file "'+@FileAndPath+'"'
	if @HR=0 execute @hr = sp_OAMethod   @objFileSystem   , 'CreateTextFile'
	, @objTextStream OUT, @FileAndPath,2,True

	if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='writing to the file "'+@FileAndPath+'"'

	declare @body nvarchar(max);

	declare @tbl table (
						Job_GUID				uniqueidentifier
						,Job_Name				nvarchar(255)
						,LastFinishRunState		nvarchar(255)
						,LastDateTime			datetime
						,LastRunDurationString	nvarchar(255)
						,LastOutcomeMessage		nvarchar(max)
						,[Server]				nvarchar(255)
						,ID						int identity(1,1)
					   );

	declare
	@Job_GUID				uniqueidentifier
	,@Job_Name				nvarchar(255)
	,@LastFinishRunState	nvarchar(255)
	,@LastDateTime			datetime
	,@LastRunDurationString	nvarchar(255)
	,@LastOutcomeMessage	nvarchar(max)
	,@Server				nvarchar(255)
	,@ID					int;

	insert into @tbl(
						Job_GUID
						,Job_Name
						,LastFinishRunState
						,LastDateTime
						,LastRunDurationString
						,LastOutcomeMessage
						,[Server]
					)
			select		Job_GUID
						,Job_Name
						,LastFinishRunState
						,LastDateTime
						,LastRunDurationString
						,LastOutcomeMessage
						,[Server]
			from	srv.ShortInfoRunJobsServers
			where [InsertUTCDate]>=DateAdd(day,-1,GetUTCDate())
			order by [Server] asc, LastRunDurationInt desc;

	if(exists(select top(1) 1 from @tbl))
	begin
		set @body='В ходе анализа последних выполнений заданий, были выявлены следующие задания, которые либо с ошибочным завершением, '
				 +'либо выполнились по времени более '+cast(@second as nvarchar(255))+' секунд:<br><br>'+'<TABLE BORDER=5>';

		set @body=@body+'<TR>';

		set @body=@body+'<TD>';
		set @body=@body+'№ п/п';
		set @body=@body+'</TD>';
	
		set @body=@body+'<TD>';
		set @body=@body+'СЕРВЕР';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'ЗАДАНИЕ';
		set @body=@body+'</TD>';
	
		set @body=@body+'<TD>';
		set @body=@body+'СТАТУС';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'ДАТА И ВРЕМЯ';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'ДЛИТЕЛЬНОСТЬ';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'СООБЩЕНИЕ';
		set @body=@body+'</TD>';

		set @body=@body+'</TR>';

		if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @body;

		set @body='';

		DECLARE sql_cursor CURSOR LOCAL FOR
		select Job_GUID
			  ,Job_Name
			  ,LastFinishRunState
			  ,LastDateTime
			  ,LastRunDurationString
			  ,LastOutcomeMessage
			  ,[Server]
		from @tbl;
		
		OPEN sql_cursor;
		  
		FETCH NEXT FROM sql_cursor   
		INTO @Job_GUID
			  ,@Job_Name
			  ,@LastFinishRunState
			  ,@LastDateTime
			  ,@LastRunDurationString
			  ,@LastOutcomeMessage
			  ,@Server;

		set @ID=0;

		while (@@FETCH_STATUS = 0 )
		begin
			set @ID=@ID+1;
			
			set @body=@body+'<TR>';

			--select top (1)
			--@ID						=	[ID]
			--,@Job_GUID				=	Job_GUID
			--,@Job_Name				=	Job_Name				
			--,@LastFinishRunState	=	LastFinishRunState		
			--,@LastDateTime			=	LastDateTime			
			--,@LastRunDurationString	=	LastRunDurationString	
			--,@LastOutcomeMessage	=	LastOutcomeMessage		
			--,@Server				=	[Server]				
			--from @tbl;

			set @body=@body+'<TD>';
			set @body=@body+cast(@ID as nvarchar(max));
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@Server, '');
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@Job_Name,'');
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@LastFinishRunState,'');
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+coalesce(rep.GetDateFormat(@LastDateTime, default)+' '+rep.GetTimeFormat(@LastDateTime, default), '');--cast(@InsertDate as nvarchar(max));
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+coalesce(@LastRunDurationString,'');
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+coalesce(@LastOutcomeMessage, '');
			set @body=@body+'</TD>';

			--delete from @tbl
			--where ID=@ID;

			set @body=@body+'</TR>';

			if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @body;

			set @body='';

			FETCH NEXT FROM sql_cursor   
			INTO @Job_GUID
			  ,@Job_Name
			  ,@LastFinishRunState
			  ,@LastDateTime
			  ,@LastRunDurationString
			  ,@LastOutcomeMessage
			  ,@Server;
		end

		CLOSE sql_cursor;
		DEALLOCATE sql_cursor;

		set @body=@body+'</TABLE>';
	end
	else
	begin
		set @body='В ходе анализа последних выполнений заданий, задания с ошибочным завершением, а также те, что выполнились по времени более '
				 +cast(@second as nvarchar(255))
				 +' секунд, не выявлены на сервере '+@@SERVERNAME;
	end
	
	set @body=@body+'<br><br>Для более детальной информации обратитесь к таблице SRV.srv.ShortInfoRunJobs';

	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @body;

	if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@FileAndPath+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'
	
	if @hr<>0
		begin
		Declare 
			@Source varchar(255),
			@Description Varchar(255),
			@Helpfile Varchar(255),
			@HelpID int
		
		EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
			@source output,@Description output,@Helpfile output,@HelpID output
		Select @strErrorMessage='Error whilst '
				+coalesce(@strErrorMessage,'doing something')
				+', '+coalesce(@Description,'')
		raiserror (@strErrorMessage,16,1)
		end
	EXECUTE  sp_OADestroy @objTextStream
	EXECUTE sp_OADestroy @objFileSystem
END

GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on function [inf].[SpaceusedDB]
--
CREATE FUNCTION [inf].[SpaceusedDB]
(
)
RETURNS 
@tbl TABLE 
(
	[DBName]			 nvarchar(255), 
	[DBSizeMB]			 decimal(18,3),
	[UnallocatedSpaceMB] decimal(18,3),
	[ReservedMB]		 decimal(18,3),
	[DataMB]			 decimal(18,3),
	[IndexSizeMB]		 decimal(18,3),
	[UnusedMB]			 decimal(18,3)

)
AS
BEGIN
	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	--SET NOCOUNT ON;
	--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @id	int			-- The object id that takes up space
		,@type	character(2) -- The object type.
		,@pages	bigint			-- Working variable for size calc.
		,@dbname sysname
		,@dbsize bigint
		,@logsize bigint
		,@reservedpages  bigint
		,@usedpages  bigint
		,@rowCount bigint;
	
	select @dbsize = sum(convert(bigint,case when status & 64 = 0 then size else 0 end))
		, @logsize = sum(convert(bigint,case when status & 64 <> 0 then size else 0 end))
		from dbo.sysfiles;
	
	select @reservedpages = sum(a.total_pages),
		@usedpages = sum(a.used_pages),
		@pages = sum(
				CASE
					-- XML-Index and FT-Index and semantic index internal tables are not considered "data", but is part of "index_size"
					When it.internal_type IN (202,204,207,211,212,213,214,215,216,221,222,236) Then 0
					When a.type <> 1 and p.index_id < 2 Then a.used_pages
					When p.index_id < 2 Then a.data_pages
					Else 0
				END
			)
	from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
		left join sys.internal_tables it on p.object_id = it.object_id;

		insert into @tbl ([DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB])
		select
		database_name = db_name(),
		database_size = (convert (dec (15,2),@dbsize) + convert (dec (15,2),@logsize)) 
			* 8192 / 1048576,
		'unallocated space' = (case when @dbsize >= @reservedpages then
			(convert (dec (15,2),@dbsize) - convert (dec (15,2),@reservedpages)) 
			* 8192 / 1048576 else 0 end),
		reserved = @reservedpages * 8192 / 1048576.,
		data = @pages * 8192 / 1048576.,
		index_size = (@usedpages - @pages) * 8192 / 1048576.,
		unused = (@reservedpages - @usedpages) * 8192 / 1048576.;
	
	RETURN;
END
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Выводит информацию о распределении места в БД' , @level0type=N'SCHEMA',@level0name=N'inf', @level1type=N'FUNCTION',@level1name=N'SpaceusedDB'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create view [inf].[vRAM]
--
GO


CREATE view [inf].[vRAM] as
select a.[TotalAvailOSRam_Mb]						--сколько свободно ОЗУ на сервере в МБ
		 , a.[RAM_Avail_Percent]					--процент свободного ОЗУ на сервере
		 , a.[Server_physical_memory_Mb]			--сколько всего ОЗУ на сервере в МБ
		 , a.[SQL_server_committed_target_Mb]		--сколько всего ОЗУ выделено под MS SQL Server в МБ
		 , a.[SQL_server_physical_memory_in_use_Mb] --сколько всего ОЗУ потребляет MS SQL Server в данный момент времени в МБ
		 , a.[SQL_RAM_Avail_Percent]				--поцент свободного ОЗУ для MS SQL Server относительно всего выделенного ОЗУ для MS SQL Server
		 , a.[StateMemorySQL]						--достаточно ли ОЗУ для MS SQL Server
		 , a.[SQL_RAM_Reserve_Percent]				--процентт выделенной ОЗУ для MS SQL Server относительно всего ОЗУ сервера
		 --достаточн ли ОЗУ для сервера
		, (case when a.[RAM_Avail_Percent]<10 and a.[RAM_Avail_Percent]>5 and a.[TotalAvailOSRam_Mb]<8192 then 'Warning' when a.[RAM_Avail_Percent]<=5 and a.[TotalAvailOSRam_Mb]<2048 then 'Danger' else 'Normal' end) as [StateMemoryServer]
	from
	(
		select cast(a0.available_physical_memory_kb/1024.0 as int) as TotalAvailOSRam_Mb
			 , cast((a0.available_physical_memory_kb/casT(a0.total_physical_memory_kb as float))*100 as numeric(5,2)) as [RAM_Avail_Percent]
			 , a0.system_low_memory_signal_state
			 , ceiling(b.physical_memory_kb/1024.0) as [Server_physical_memory_Mb]
			 , ceiling(b.committed_target_kb/1024.0) as [SQL_server_committed_target_Mb]
			 , ceiling(a.physical_memory_in_use_kb/1024.0) as [SQL_server_physical_memory_in_use_Mb]
			 , cast(((b.committed_target_kb-a.physical_memory_in_use_kb)/casT(b.committed_target_kb as float))*100 as numeric(5,2)) as [SQL_RAM_Avail_Percent]
			 , cast((b.committed_target_kb/casT(a0.total_physical_memory_kb as float))*100 as numeric(5,2)) as [SQL_RAM_Reserve_Percent]
			 , (case when (ceiling(b.committed_target_kb/1024.0)-1024)<ceiling(a.physical_memory_in_use_kb/1024.0) then 'Warning' else 'Normal' end) as [StateMemorySQL]
		from sys.dm_os_sys_memory as a0
		cross join sys.dm_os_process_memory as a
		cross join sys.dm_os_sys_info as b
		cross join sys.dm_os_sys_memory as v
	) as a
	;
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create view [inf].[vDisk]
--
GO
create view [inf].[vDisk] as
select [Disk]
		 , [Disk_Space_Mb]
		 , [Available_Mb]
		 , [Available_Percent]
		 , (case when [Available_Percent]<=20 and [Available_Percent]>10 then 'Warning' when [Available_Percent]<=10 then 'Danger' else 'Normal' end) as [State]
	from
	(	SELECT  volume_mount_point as [Disk]
		, cast(((MAX(s.total_bytes))/1024.0)/1024.0 as numeric(11,2)) as Disk_Space_Mb
		, cast(((MIN(s.available_bytes))/1024.0)/1024.0 as numeric(11,2)) as Available_Mb
		, cast((MIN(available_bytes)/cast(MAX(total_bytes) as float))*100 as numeric(11,2)) as [Available_Percent]
		FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) as s
		GROUP BY volume_mount_point
	) as a;
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create view [inf].[vDBSizeDrive]
--
GO
create view [inf].[vDBSizeDrive] as
SELECT [Server], [DBName], [Drive]
      ,SUM([SizeMb]) as [SizeMb]
      ,SUM([GrowthMb]) as [GrowthMb]
      ,cast([InsertUTCDate] as date) as [DATE]
  FROM [srv].[DBFileStatistics]
  where [Server] not like 'HLT%'
  and [Server] not like 'STG%'
  group by [Server], [DBName], [Drive], cast([InsertUTCDate] as date)
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter view [inf].[vWaits]
--
GO









ALTER view [inf].[vWaits] as
/*
	2014-08-22 ГЕМ:
		SQL Server отслеживает время, которое проходит между выходом потока из состояния «выполняется» и его возвращением в это состояние, 
		определяя его как «время ожидания» (wait time) и время, потраченное в состоянии «готов к выполнению», 
		определяя его как «время ожидания сигнала» (signal wait time), 
		т.е. сколько времени требуется потоку после получения сигнала о доступности ресурсов для того, 
		чтобы получить доступ к процессору. 
		Мы должны понять, сколько времени тратит поток в состоянии «приостановлен», 
		называемом «временем ожидания ресурсов» (resource wait time), вычитая время ожидания сигнала из общего времени ожидания.

		http://habrahabr.ru/post/216309/

		505: CXPACKET 
			Означает параллелизм, но не обязательно в нем проблема. 
			Поток-координатор в параллельном запросе всегда накапливает эти ожидания. 
			Если параллельные потоки не заняты работой или один из потоков заблокирован, то ожидающие потоки также накапливают ожидание CXPACKET, 
			что приводит к более быстрому накоплению статистики по этому типу — в этом и проблема. 
			Один поток может иметь больше работы, чем остальные, и по этой причине весь запрос блокируется, пока долгий поток не закончит свою работу. 
			Если этот тип ожидания совмещен с большими цифрами ожидания PAGEIOLATCH_XX, то это может быть сканирование больших таблиц 
			по причине некорректных некластерных индексов или из-за плохого плана выполнения запроса. 
			Если это не является причиной, вы можете попробовать применение опции MAXDOP со значениями 4, 2, или 1 для проблемных запросов 
			или для всего экземпляра сервера (устанавливается на сервере параметром «max degree of parallelism»). 
			Если ваша система основана на схеме NUMA, попробуйте установить MAXDOP в значение, равное количеству процессоров в одном узле NUMA для того, 
			чтобы определить, не в этом ли проблема. Вам также нужно определить эффект от установки MAXDOP на системах со смешанной нагрузкой. 
			Если честно, я бы поиграл с параметром «cost threshold for parallelism» (поднял его до 25 для начала), прежде чем снижать значение MAXDOP для всего экземпляра. 
			И не забывайте про регулятор ресурсов (Resource Governor) в Enterprise версии SQL Server 2008, который позволяет установить количество процессоров 
			для конкретной группы соединений с сервером.

		304: PAGEIOLATCH_XX
			Вот тут SQL Server ждет чтения страницы данных с диска в память. 
			Этот тип ожидания может указывать на проблему в системе ввода/вывода (что является первой реакцией на этот тип ожидания), 
			но почему система ввода/вывода должна обслуживать такое количество чтений? 
			Возможно, давление оказывает буферный пул/память (недостаточно памяти для типичной нагрузки), внезапное изменение в планах выполнения, 
			приводящее к большим параллельным сканированиям вместо поиска, раздувание кэша планов или некоторые другие причины. 
			Не стоит считать, что основная проблема в системе ввода/вывода.

		275: ASYNC_NETWORK_IO
			Здесь SQL Server ждет, пока клиент закончит получать данные. 
			Причина может быть в том, что клиент запросил слишком большое количество данных или просто получает их ооочень медленно из-за плохого кода — я почти никогда не не видел, 
			чтобы проблема заключалась в сети. 
			Клиенты часто читают по одной строке за раз — так называемый RBAR или «строка за агонизирующей строкой»(Row-By-Agonizing-Row) — вместо того, 
			чтобы закешировать данные на клиенте и уведомить SQL Server об окончании чтения немедленно.

		112: WRITELOG
			Подсистема управления логом ожидает записи лога на диск. 
			Как правило, означает, что система ввода/ввода не может обеспечить своевременную запись всего объема лога, 
			но на высоконагруженных системах это может быть вызвано общими ограничениями записи лога, что может означать, 
			что вам следует разделить нагрузку между несколькими базами, или даже сделать ваши транзакции чуть более долгими, 
			чтобы уменьшить количество записей лога на диск. Для того, чтобы убедиться, что причина в системе ввода/вывода, 
			используйте DMV sys.dm_io_virtual_file_stats для того, чтобы изучить задержку ввода/вывода для файла лога и увидеть, 
			совпадает ли она с временем задержки WRITELOG. Если WRITELOG длится дольше, вы получили внутреннюю конкуренцию за запись на диск и должны разделить нагрузку. 
			Если нет, выясняйте, почему вы создаете такой большой лог транзакций. 
			Здесь (https://sqlperformance.com/2012/12/io-subsystem/trimming-t-log-fat) 
			и здесь (https://sqlperformance.com/2013/01/io-subsystem/trimming-more-transaction-log-fat) можно почерпнуть некоторые идеи.
			(прим переводчика: следующий запрос позволяет в простом и удобном виде получить статистику задержек ввода/вывода для каждого файла каждой базы данных на сервере:
				-- Плохо: Ср.задержка одной операции > 20 мсек
				USE master
				GO
				SELECT cast(db_name(a.database_id) AS VARCHAR) AS Database_Name
					 , b.physical_name
					 --, a.io_stall
					 , a.size_on_disk_bytes
					 , a.io_stall_read_ms / a.num_of_reads 'Ср.задержка одной операции чтения'
					 , a.io_stall_write_ms / a.num_of_writes 'Ср.задержка одной операции записи'
					 --, *
				FROM
					sys.dm_io_virtual_file_stats(NULL, NULL) a
					INNER JOIN sys.master_files b
						ON a.database_id = b.database_id AND a.file_id = b.file_id
				where num_of_writes > 0 and num_of_reads > 0
				ORDER BY
					Database_Name
				  , a.io_stall DESC

		109: BROKER_RECEIVE_WAITFOR
			Здесь Service Broker ждет новые сообщения. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		086: MSQL_XP
			Здесь SQL Server ждет выполнения расширенных хранимых процедур. 
			Это может означать наличие проблем в коде ваших расширенных хранимых процедур.

		074: OLEDB
			Как и предполагается из названия, это ожидание взаимодействия с использованием OLEDB — например, со связанным сервером. 
			Однако, OLEDB также используется в DMV и командой DBCC CHECKDB, так что не думайте, 
			что проблема обязательно в связанных серверах — это может быть внешняя система мониторинга, чрезмерно использующая вызовы DMV. 
			Если это и в самом деле связанный сервер — тогда проведите анализ ожиданий на связанном сервере и определите, в чем проблема с производительностью на нем.

		054: BACKUPIO
			Показывает, когда вы делаете бэкап напрямую на ленту, что ооочень медленно. 
			Я бы предпочел отфильтровать это ожидание. 
			(прим. переводчика: я встречался с этим типом ожиданий при записи бэкапа на диск, при этом бэкап небольшой базы выполнялся очень долго, 
			не успевая выполниться в технологический перерыв и вызывая проблемы с производительностью у пользователей. 
			Если это ваш случай, возможно дело в системе ввода/вывода, используемой для бэкапирования, 
			необходимо рассмотреть возможность увеличения ее производительности либо пересмотреть план обслуживания 
			(не выполнять полные бэкапы в короткие технологические перерывы, заменив их дифференциальными))

		041: LCK_M_XX
			Здесь поток просто ждет доступа для наложения блокировки на объект и означает проблемы с блокировками. 
			Это может быть вызвано нежелательной эскалацией блокировок или плохим кодом, но также может быть вызвано тем, 
			что операции ввода/вывода занимают слишком долгое время и держат блокировки дольше, чем обычно. 
			Посмотрите на ресурсы, связанные с блокировками, используя DMV sys.dm_os_waiting_tasks. 
			Не стоит считать, что основная проблема в блокировках.

		032: ONDEMAND_TASK_QUEUE
			Это нормально и является частью системы фоновых задач (таких как отложенный сброс, очистка в фоне). 
			Я бы добавил это ожидание в список исключаемых и заново выполнил запрос со статистикой ожидания.

		031: BACKUPBUFFER
			Показывает, когда вы делаете бэкап напрямую на ленту, что ооочень медленно. 
			Я бы предпочел отфильтровать это ожидание.

		027: IO_COMPLETION
			SQL Server ждет завершения ввода/вывода и этот тип ожидания может быть индикатором проблемы с системой ввода/вывода.

		024: SOS_SCHEDULER_YIELD
			Чаще всего это код, который не попадает в другие типы ожидания, но иногда это может быть конкуренция в циклической блокировке.

		022: DBMIRROR_EVENTS_QUEUE
		022: DBMIRRORING_CMD
			Эти два типа показывают, что система управления зеркальным отображением (database mirroring) сидит и ждет, чем бы ей заняться. 
			Я бы добавил эти ожидания в список исключаемых и заново выполнил запрос со статистикой ожидания.

		018: PAGELATCH_XX
			Это конкуренция за доступ к копиям страниц в памяти. 
			Наиболее известные случаи — это конкуренция PFS, SGAM, и GAM, возникающие в базе tempdb 
			при определенных типах нагрузок (https://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-1230-tempdb-should-always-have-one-data-file-per-processor-core/). 
			Для того, чтобы выяснить, за какие страницы идет конкуренция, вам нужно использовать DMV sys.dm_os_waiting_tasks для того, 
			чтобы выяснить, из-за каких страниц возникают блокировки. 
			По проблемам с базой tempdb Роберт Дэвис (его блог http://www.sqlservercentral.com/blogs/robert_davis/) написал хорошую статью, показывающую, 
			как их решать (http://www.sqlservercentral.com/blogs/robert_davis/2010/03/05/Breaking-Down-TempDB-Contention/).
			Другая частая причина, которую я видел — часто обновляемый индекс с конкурирующими вставками в индекс, использующий последовательный ключ (IDENTITY).

		016: LATCH_XX
			Это конкуренция за какие либо не страничные структуры в SQL Server'е — так что это не связано с вводом/выводом и данными вообще. 
			Причину такого типа задержки может быть достаточно сложно понять и вам необходимо использовать DMV sys.dm_os_latch_stats.

		013: PREEMPTIVE_OS_PIPEOPS
			Здесь SQL Server переключается в режим упреждающего планирования для того, чтобы запросить о чем-то Windows. 
			Этот тип ожидания был добавлен в 2008 версии и еще не был документирован. 
			Самый простой способ выяснить, что он означает — это убрать начальные PREEMPTIVE_OS_ и поискать то, что осталось, в MSDN — это будет название API Windows.

		013: THREADPOOL
			Такой тип говорит, что недостаточно рабочих потоков в системе для того, чтобы удовлетворить запрос. 
			Обычно причина в большом количестве сильно параллелизованных запросов, пытающихся выполниться. 
			(прим. переводчика: также это может быть намеренно урезанное значение параметра сервера «max worker threads»)

		009: BROKER_TRANSMITTER
			Здесь Service Broker ждет новых сообщений для отправки. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		006: SQLTRACE_WAIT_ENTRIES
			Часть слушателя (trace) SQL Server'а. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		005: DBMIRROR_DBM_MUTEX
			Это один из недокументированных типов и в нем конкуренция возникает за отправку буфера, который делится между сессиями зеркального отображения (database mirroring). 
			Может означать, что у вас слишком много сессий зеркального отображения.

		005: RESOURCE_SEMAPHORE
			Здесь запрос ждет память для исполнения (память, используемая для обработки операторов запроса — таких, как сортировка). 
			Это может быть недостаток памяти при конкурентной нагрузке.

		003: PREEMPTIVE_OS_AUTHENTICATIONOPS
		003: PREEMPTIVE_OS_GENERICOPS
			Здесь SQL Server переключается в режим упреждающего планирования для того, чтобы запросить о чем-то Windows. 
			Этот тип ожидания был добавлен в 2008 версии и еще не был документирован. 
			Самый простой способ выяснить, что он означает — это убрать начальные PREEMPTIVE_OS_ и поискать то, что осталось, в MSDN — это будет название API Windows.

		003: SLEEP_BPOOL_FLUSH
			Это ожидание можно часто увидеть и оно означает, что контрольная точка ограничивает себя для того, чтобы избежать перегрузки системы ввода/вывода. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		002: MSQL_DQ
			Здесь SQL Server ожидает, пока выполнится распределенный запрос. 
			Это может означать проблемы с распределенными запросами или может быть просто нормой.

		002: RESOURCE_SEMAPHORE_QUERY_COMPILE
			Когда в системе происходит слишком много конкурирующих перекомпиляций запросов, SQL Server ограничивает их выполнение. 
			Я не помню уровня ограничения, но это ожидание может означать излишнюю перекомпиляцию или, возможно, слишком частое использование одноразовых планов.

		001: DAC_INIT
			Я никогда раньше этого не видел и BOL говорит, что причина в инициализации административного подключения. 
			Я не могу представить, как это может быть преимущественным ожиданием на чьей либо системе...

		001: MSSEARCH
			Этот тип является нормальным при полнотекстовых операциях. 
			Если это преимущественное ожидание, это может означать, что ваша система тратит больше всего времени на выполнение полнотекстовых запросов. 
			Вы можете рассмотреть возможность добавить этот тип ожидания в список исключаемых.

		001: PREEMPTIVE_OS_FILEOPS
		001: PREEMPTIVE_OS_LIBRARYOPS
		001: PREEMPTIVE_OS_LOOKUPACCOUNTSID
		001: PREEMPTIVE_OS_QUERYREGISTRY
			Здесь SQL Server переключается в режим упреждающего планирования для того, чтобы запросить о чем-то Windows. 
			Этот тип ожидания был добавлен в 2008 версии и еще не был документирован. 
			Самый простой способ выяснить, что он означает — это убрать начальные PREEMPTIVE_OS_ и поискать то, что осталось, в MSDN — это будет название API Windows.

		001: SQLTRACE_LOCK
			Часть слушателя (trace) SQL Server'а. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		LCK_M_XXX
		http://sqlcom.ru/waitstats-and-waittypes/lck_m_xxx/
		Это механизм ядра SQL Server, позволяющий организовать одновременную работу с данными в одно и то же время. 
		Другими словами этот механизм поддерживает целостность данных, защищая доступ к объекту базы данных.
		
		ИЗ Book On-Line:
		LCK_M_BU
		Имеет место, когда задача ожидает получения блокировки для массового обновления (BU). 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_IS
		Имеет место, когда задача ожидает получения блокировки с намерением коллективного доступа (IS). 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_IU
		Имеет место, когда задача ожидает получения блокировки с намерением обновления (IU). 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks 
		
		LCK_M_IX
		Имеет место, когда задача ожидает получения блокировки с намерением монопольного доступа (IX). 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_S
		Имеет место, когда задача ожидает получения совмещаемой блокировки. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_SCH_M
		Имеет место, когда задача ожидает получения блокировки на изменение схемы. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_SCH_S
		Имеет место, когда задача ожидает получения совмещаемой блокировки схемы. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_SIU
		Имеет место, когда задача ожидает получения совмещаемой блокировки с намерением обновления. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_SIX
		Имеет место, когда задача ожидает получения совмещаемой блокировки с намерением монопольного доступа. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks 
		
		LCK_M_U
		Имеет место, когда задача ожидает получения блокировки на обновление. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_UIX
		Имеет место, когда задача ожидает получения блокировки на обновление с намерением монопольного доступа. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks 
		
		LCK_M_X
		Имеет место, когда задача ожидает получения блокировки на монопольный доступ. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		Объяснение:
		
		Я считаю, что объяснение этого вида ожиданий очень лёгкое. 
		Когда любое задание ожидает наложения блокировки на любой ресурс, происходит этот вид ожиданий. 
		Основная причина сложности наложения блокировки состоит в том, что на необходимый ресурс уже наложена блокировка и другая операция производится с этими данными. 
		Это вид ожиданий сообщает, что ресурсы не доступны или заняты в данный момент.

		Вы можете использовать следующие методы, чтобы обнаружить блокировки

		EXEC sp_who2
		Быстрый способ найти заблокированные запросы-[srv].[vBlockingQuery]
		DMV – sys.dm_tran_locks
		DMV – sys.dm_os_waiting_tasks
		Устранение LCK_M_XXX:
		
		Проверьте долгие транзакции, постарайтесь разбить их на более мелкие
		Уровень изоляции Serialization может создавать этот вид ожиданий. 
		Изначальный уровень изоляции SQL Server — ‘Read Committed’
		Один из моих клиентов решил этот вопрос с помощью уровня изоляции ‘Read Uncommitted’. 
		Я настоятельно не рекомендую такое решение, так как будет очень много грязного чтения в базе данных
		Найдите заблокированные запросы, изучите почему так происходит и исправьте их
		Секционирование может быть источником проблемы
		Проверьте нет ли проблем с памятью и IO операциями
		Проверить память можно с помощью следующих счётчиков производительности (Perfomance Monitor):
		
		SQLServer: Memory Manager\Memory Grants Pending (Постоянное значение более чем 0-2 свидетельствует о проблеме)
		SQLServer: Memory Manager\Memory Grants Outstanding
		SQLServer: Buffer Manager\Buffer Hit Cache Ratio (Чем больше, тем лучше. Обычно значение долго превышать 90%)
		SQLServer: Buffer Manager\Page Life Expectancy (плохо, когда ниже 300)
		Memory: Available Mbytes
		Memory: Page Faults/sec
		Memory: Pages/sec
		Проверить диск можно с помощью:
		
		Average Disk sec/Read (Постоянное значение более чем 4-8 мс свидетельствует о проблеме)
		Average Disk sec/Write (Постоянное значение более чем 4-8 мс свидетельствует о проблеме)
		Average Disk Read/Write Queue Length
		Заметка: Представленная тут информация является только моим опытом. 
		Я настраиваю, чтобы вы читали Books On-Line. 
		Все мои обсуждения ожиданий здесь носят общий характер и изменяются от системы к системе. 
		Я рекомендую сначала тестировать всё на сервере разработки, прежде чем применять это на рабочем сервере.

		ASYNC_IO_COMPLETION
		http://sqlcom.ru/waitstats-and-waittypes/async_io_completion/

		Для любой хорошей системы есть 3 важные вещи: Процессор, Диск, Память. 
		Из этих трёх, Диск является наиболее критичным для SQL Server. 
		Смотря на случаи из реального мира, я не вижу людей, которые улучшают Процессоры или Память часто, однако Диски меняются достаточно часть 
		(увеличение дискового пространства, пропускной способности). 
		Сегодня мы рассмотрим ещё одно ожидание, которое относится к Диску.

		Из Book On-Line:
		Имеет место, когда для своего завершения задача ожидает ввода-вывода.
		
		Объяснение:
		Любые задания ожидают завершения I/O. 
		Если SQL Server очень медленно обрабатывает данные и клиенты ожидают их, то счётчик ASYNC_IO_COMPLETION будет увеличиваться. 
		Так же это ожидание провоцируется Backup, созданием и редактированием баз данных.
		
		Уменьшение ASYNC_IO_COMPLETION ожиданий:
		
		1. Посмотрите на код и найдите там не оптимальные участки, по возможности перепишите их
		2. Надлежащим образом, на разных дисках, разместите файлы журналов (LDF) и файлы данных (MDF), 
			Tempdb на другом отдельном диске, часто используемые таблицы в разных файловых группах и на разных дисках.
		3. Проверьте статистику использования файлов баз данных, обратите внимание на IO Read Stall и IO Write Stall (fn_virtualfilestats)
		4. Проверьте файл логов на наличие ошибок Диска
		5. Если вы используете SAN (сетевое хранилище данных), то необходимо правильно настроить параметр HBA Queue Depth, почитать о котором можно в интернете
		6. Проверьте наличие нужных индексов
		7. Проверьте показания следующих счётчиков Perfomance Monitor
		SQLServer: Memory Manager\Memory Grants Pending (Постоянное значение более чем 0-2 свидетельствует о проблеме)
		SQLServer: Memory Manager\Memory Grants Outstanding
		SQLServer: Buffer Manager\Buffer Hit Cache Ratio (Чем больше, тем лучше. Обычно значение долго превышать 90%)
		SQLServer: Buffer Manager\Page Life Expectancy (плохо, когда ниже 300)
		Memory: Available Mbytes
		Memory: Page Faults/sec
		Memory: Pages/sec
		Average Disk sec/Read (Постоянное значение более чем 4-8 мс свидетельствует о проблеме)
		Average Disk sec/Write (Постоянное значение более чем 4-8 мс свидетельствует о проблеме)
		Average Disk Read/Write Queue Length
*/
WITH [Waits] AS
    (SELECT
        [wait_type], --имя типа ожидания
        [wait_time_ms] / 1000.0 AS [WaitS],--Общее время ожидания данного типа в миллисекундах. Это время включает signal_wait_time_ms
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],--Общее время ожидания данного типа в миллисекундах без signal_wait_time_ms
        [signal_wait_time_ms] / 1000.0 AS [SignalS],--Разница между временем сигнализации ожидающего потока и временем начала его выполнения
        [waiting_tasks_count] AS [WaitCount],--Число ожиданий данного типа. Этот счетчик наращивается каждый раз при начале ожидания
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats
    WHERE [waiting_tasks_count]>0
		and [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER',         N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP',            N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER',          N'CHECKPOINT_QUEUE',
        N'CHKPT',                       N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT',            N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT',          N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE',       N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL',             N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC',                    N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL',           N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT',        N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK',             N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP',              N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE',                N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK',           N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP',             N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY',         N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED',        N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK',            N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP',         N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES',       N'WAIT_FOR_RESULTS',
        N'WAITFOR',                     N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT',          N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE',         N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT',          N'XE_TIMER_EVENT',
		N'XE_LIVE_TARGET_TVF',
		N'PREEMPTIVE_XE_DISPATCHER',
		N'PREEMPTIVE_OS_ENCRYPTMESSAGE',
		N'PREEMPTIVE_OS_AUTHENTICATIONOPS',
		N'PREEMPTIVE_OS_CRYPTOPS',
		N'PREEMPTIVE_OS_DECRYPTMESSAGE',
		N'PREEMPTIVE_OS_CRYPTACQUIRECONTEXT',
		N'PREEMPTIVE_OS_CRYPTIMPORTKEY',
		N'PREEMPTIVE_OS_DELETESECURITYCONTEXT',
		N'PREEMPTIVE_OS_DEVICEOPS',
		N'PREEMPTIVE_OS_AUTHORIZATIONOPS',
		N'PREEMPTIVE_OS_CLOSEHANDLE',
		N'PREEMPTIVE_OS_COMOPS',
		N'PREEMPTIVE_OS_CREATEFILE',
		N'PREEMPTIVE_CLOSEBACKUPVDIDEVICE',
		N'PREEMPTIVE_COM_COCREATEINSTANCE',
		N'PREEMPTIVE_COM_QUERYINTERFACE',
		N'PREEMPTIVE_FILESIZEGET',
		N'PREEMPTIVE_OLEDBOPS',
		N'PREEMPTIVE_OS_DISCONNECTNAMEDPIPE',
		N'PREEMPTIVE_OS_DOMAINSERVICESOPS',
		N'PREEMPTIVE_OS_DELETEFILE',
		N'PREEMPTIVE_OS_FILEOPS',
		N'PREEMPTIVE_OS_FLUSHFILEBUFFERS',
		N'PREEMPTIVE_OS_GENERICOPS',
		N'PREEMPTIVE_OS_GETDISKFREESPACE',
		N'PREEMPTIVE_OS_GETFILEATTRIBUTES',
		N'PREEMPTIVE_OS_GETPROCADDRESS',
		N'PREEMPTIVE_OS_GETVOLUMEPATHNAME',
		N'PREEMPTIVE_OS_LIBRARYOPS',
		N'PREEMPTIVE_OS_LOADLIBRARY',
		N'PREEMPTIVE_OS_LOOKUPACCOUNTSID',
		N'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICY',
		N'PREEMPTIVE_OS_PIPEOPS',
		N'PREEMPTIVE_OS_QUERYCONTEXTATTRIBUTES',
		N'PREEMPTIVE_OS_QUERYREGISTRY',
		N'PREEMPTIVE_OS_REPORTEVENT',
		N'PREEMPTIVE_OS_REVERTTOSELF',
		N'PREEMPTIVE_OS_SECURITYOPS',
		N'PREEMPTIVE_OS_SQMLAUNCH',
		N'PREEMPTIVE_OS_WAITFORSINGLEOBJECT',
		N'PREEMPTIVE_OS_WRITEFILE',
		N'PREEMPTIVE_OS_WRITEFILEGATHER',
		N'PREEMPTIVE_XE_CALLBACKEXECUTE',
		N'PREEMPTIVE_XE_SESSIONCOMMIT',
		N'PREEMPTIVE_XE_TARGETFINALIZE',
		N'PREEMPTIVE_XE_TARGETINIT',
		N'PREEMPTIVE_OS_AUTHZINITIALIZECONTEXTFROMSID',
		N'PREEMPTIVE_OS_GETVOLUMENAMEFORVOLUMEMOUNTPOINT',
		N'PREEMPTIVE_OS_MOVEFILE',
		N'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICYFREE',
		N'PREEMPTIVE_OS_SETFILEVALIDDATA',
		N'PREEMPTIVE_TRANSIMPORT',
		N'PREEMPTIVE_XE_GETTARGETSTATE',
		N'PREEMPTIVE_OS_GETCOMPRESSEDFILESIZE',
		N'PREEMPTIVE_OS_DEVICEIOCONTROL',
		N'PREEMPTIVE_OS_VERIFYTRUST',
		N'PREEMPTIVE_OS_SETNAMEDSECURITYINFO',
		N'PREEMPTIVE_OLE_UNINIT',
		N'PREEMPTIVE_DTC_BEGINTRANSACTION',
		N'PREEMPTIVE_DTC_ENLIST',
		N'PREEMPTIVE_OLE_UNINIT',
		N'PREEMPTIVE_OS_DTCOPS',
		N'PREEMPTIVE_SB_STOPENDPOINT',
		N'PREEMPTIVE_DTC_COMMITREQUESTDONE',
		N'PREEMPTIVE_DTC_PREPAREREQUESTDONE',
		N'PREEMPTIVE_OS_AUTHZINITIALIZERESOURCEMANAGER',
		N'PREEMPTIVE_OS_AUTHZGETINFORMATIONFROMCONTEXT',
		N'PREEMPTIVE_CREATEPARAM',
		N'PREEMPTIVE_OS_WSASETLASTERROR',
		N'PREEMPTIVE_OS_SQLCLROPS',
		N'PREEMPTIVE_OS_INITIALIZESECURITYCONTEXT',
		N'PREEMPTIVE_OS_GETADDRINFO',
		N'PREEMPTIVE_COM_CREATEACCESSOR',
		N'PREEMPTIVE_COM_SETPARAMETERINFO',
		N'PREEMPTIVE_COM_SETPARAMETERPROPERTIES',
		N'PREEMPTIVE_OS_ACCEPTSECURITYCONTEXT',
		N'PREEMPTIVE_OS_ACQUIRECREDENTIALSHANDLE',
		N'PREEMPTIVE_COM_GETDATA'
		)
    )
, ress as (
	SELECT
	    [W1].[wait_type] AS [WaitType],
	    CAST ([W1].[WaitS] AS DECIMAL (16, 2)) AS [Wait_S],--Общее время ожидания данного типа в миллисекундах. Это время включает signal_wait_time_ms
	    CAST ([W1].[ResourceS] AS DECIMAL (16, 2)) AS [Resource_S],--Общее время ожидания данного типа в миллисекундах без signal_wait_time_ms
	    CAST ([W1].[SignalS] AS DECIMAL (16, 2)) AS [Signal_S],--Разница между временем сигнализации ожидающего потока и временем начала его выполнения
	    [W1].[WaitCount] AS [WaitCount],--Число ожиданий данного типа. Этот счетчик наращивается каждый раз при начале ожидания
	    CAST ([W1].[Percentage] AS DECIMAL (5, 2)) AS [Percentage],
	    CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgWait_S],
	    CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgRes_S],
	    CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgSig_S]
	FROM [Waits] AS [W1]
	INNER JOIN [Waits] AS [W2]
	    ON [W2].[RowNum] <= [W1].[RowNum]
	GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS],
	    [W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
	HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95 -- percentage threshold
)
SELECT [WaitType]
      ,MAX([Wait_S]) as [Wait_S]
      ,MAX([Resource_S]) as [Resource_S]
      ,MAX([Signal_S]) as [Signal_S]
      ,MAX([WaitCount]) as [WaitCount]
      ,MAX([Percentage]) as [Percentage]
      ,MAX([AvgWait_S]) as [AvgWait_S]
      ,MAX([AvgRes_S]) as [AvgRes_S]
      ,MAX([AvgSig_S]) as [AvgSig_S]
  FROM ress
  group by [WaitType]





GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetValRAMTypeWait]
--
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetValRAMTypeWait]
AS
BEGIN
	/*
		Сколько в миллисекундах занимают типы ожиданий по ОЗУ (максимальное значение из всех средних задержках по всем таким типам ожиданий)
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT --sum([Percentage]) as [Percentage]
		   coalesce(max([AvgWait_S])*1000, 0.00)  as [AvgWait_S]
	FROM [inf].[vWaits]
	where [WaitType] in (
    --'PAGEIOLATCH_XX',
    'RESOURCE_SEMAPHORE',
    'RESOURCE_SEMAPHORE_QUERY_COMPILE'
    )
	or [WaitType] like 'PAGEIOLATCH%';
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetValRAMTypeWait]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает сколько в миллисекундах занимают типы ожиданий по ОЗУ (максимальное значение из всех средних задержках по всем таким типам ожиданий)', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetValRAMTypeWait'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetPercRAMTypeWait]
--
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetPercRAMTypeWait]
AS
BEGIN
	/*
		Сколько в процентах занимают типы ожиданий по ОЗУ (сумма по всем таким типам ожиданий)
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT coalesce(sum([Percentage]), 0.00) as [Percentage]
		  --,max([AvgWait_S])  as [AvgWait_S]
	FROM [inf].[vWaits]
	where [WaitType] in (
    --'PAGEIOLATCH_XX',
    'RESOURCE_SEMAPHORE',
    'RESOURCE_SEMAPHORE_QUERY_COMPILE'
    )
	or [WaitType] like 'PAGEIOLATCH%';
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetPercRAMTypeWait]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает сколько в процентах занимают типы ожиданий по ОЗУ (сумма по всем таким типам ожиданий)', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetPercRAMTypeWait'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetOldBackupsCount]
--
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetOldBackupsCount]
	@hours_full int=25 -- старость в часах для полной резервной копии
	,@hours_log int=1 -- старость в часах для резервной копии журнала транзакций
AS
BEGIN
	/*
		Количество тех БД, для которых давно не делались резервные копии
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	--declare @server_name nvarchar(255)=cast(SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS') as nvarchar(255));

	select count(*) as [count]
			from sys.databases as db
			left outer join [inf].[vServerLastBackupDB] as bak on db.[name]=bak.[DBName] and bak.[BackupType]=N'database'
			where db.[name] not in (N'tempdb', N'NewVeeamBackupDB')
			and (bak.BackupStartDate<DateAdd(hour,-@hours_full,GetDate()) or bak.BackupStartDate is null)
			and db.[create_date]<DateAdd(hour,-@hours_full,GetDate());
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetOldBackupsCount]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает количество тех БД, для которых давно не делались резервные копии', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetOldBackupsCount'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetRunnableTasksCount]
--
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetRunnableTasksCount]
AS
BEGIN
	/*
		Максимальное количество ожидающих задач среди свободных ядер
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT max([runnable_tasks_count]) as [runnable_tasks_count]
	from [inf].[vSchedulersOS];
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetRunnableTasksCount]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает максимальное количество ожидающих задач среди свободных ядер', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetRunnableTasksCount'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create view [inf].[vJobStepRunShortInfo]
--
GO







CREATE view [inf].[vJobStepRunShortInfo] as
SELECT sj.[job_id] as Job_GUID
      ,j.[name] as Job_Name
      ,case sj.[last_run_outcome]
		when 0 then 'Ошибка'
		when 1 then 'Успешно'
		when 3 then 'Отменено'
		else case when sj.[last_run_date] is not null and len(sj.[last_run_date])=8 then 'Неопределенное состояние'
				else NULL
				end
	   end as LastFinishRunState
	  ,sj.[last_run_outcome] as LastRunOutcome
	  ,case when sj.[last_run_date] is not null and len(sj.[last_run_date])=8 then
		DATETIMEFROMPARTS(
							substring(cast(sj.[last_run_date] as nvarchar(255)),1,4),
							substring(cast(sj.[last_run_date] as nvarchar(255)),5,2),
							substring(cast(sj.[last_run_date] as nvarchar(255)),7,2),
							case when len(cast(sj.[last_run_time] as nvarchar(255)))>=5 then substring(cast(sj.[last_run_time] as nvarchar(255)),1,len(cast(sj.[last_run_time] as nvarchar(255)))-4)
								else 0
							end,
							case when len(right(cast(sj.[last_run_time] as nvarchar(255)),4))>=4 then substring(right(cast(sj.[last_run_time] as nvarchar(255)),4),1,2)
								 when len(right(cast(sj.[last_run_time] as nvarchar(255)),4))=3  then substring(right(cast(sj.[last_run_time] as nvarchar(255)),4),1,1)
								 else 0
							end,
							right(cast(sj.[last_run_duration] as nvarchar(255)),2),
							0
						)
		else NULL
	   end as LastDateTime
       ,case when len(cast(sj.[last_run_duration] as nvarchar(255)))>5 then substring(cast(sj.[last_run_duration] as nvarchar(255)),1,len(cast(sj.[last_run_duration] as nvarchar(255)))-4)
		    when len(cast(sj.[last_run_duration] as nvarchar(255)))=5 then '0'+substring(cast(sj.[last_run_duration] as nvarchar(255)),1,len(cast(sj.[last_run_duration] as nvarchar(255)))-4)
		    else '00'
	   end
	   +':'
	   +case when len(cast(sj.[last_run_duration] as nvarchar(255)))>=4 then substring(right(cast(sj.[last_run_duration] as nvarchar(255)),4),1,2)
			 when len(cast(sj.[last_run_duration] as nvarchar(255)))=3  then '0'+substring(right(cast(sj.[last_run_duration] as nvarchar(255)),4),1,1)
			 else '00'
	   end
	   +':'
	   +case when len(cast(sj.[last_run_duration] as nvarchar(255)))>=2 then substring(right(cast(sj.[last_run_duration] as nvarchar(255)),2),1,2)
			 when len(cast(sj.[last_run_duration] as nvarchar(255)))=2  then '0'+substring(right(cast(sj.[last_run_duration] as nvarchar(255)),2),1,1)
			 else '00'
	   end as [LastRunDurationString]
	  ,sj.last_run_duration as LastRunDurationInt
	  ,sj.[last_outcome_message] as LastOutcomeMessage
	  ,j.[enabled] as [Enabled]
	  ,sj.[trg_server] as [TargetServer]
	  ,js.[step_id]
	  ,js.[step_name]
	  ,case js.[last_run_outcome]
		when 0 then 'Ошибка'
		when 1 then 'Успешно'
		when 3 then 'Отменено'
		else case when sj.[last_run_date] is not null and len(sj.[last_run_date])=8 then 'Неопределенное состояние'
				else NULL
				end
	   end as LastFinishRunStateStep
	  ,js.[last_run_outcome] as LastRunOutcomeStep
	  ,case when (js.[last_run_date] is not null) and len(js.[last_run_date])=8 then
		DATETIMEFROMPARTS(
							substring(cast(js.[last_run_date] as nvarchar(255)),1,4),
							substring(cast(js.[last_run_date] as nvarchar(255)),5,2),
							substring(cast(js.[last_run_date] as nvarchar(255)),7,2),
							case when len(cast(js.[last_run_time] as nvarchar(255)))>=5 then substring(cast(js.[last_run_time] as nvarchar(255)),1,len(cast(js.[last_run_time] as nvarchar(255)))-4)
								else 0
							end,
							case when len(right(cast(js.[last_run_time] as nvarchar(255)),4))>=4 then substring(right(cast(js.[last_run_time] as nvarchar(255)),4),1,2)
								 when len(right(cast(js.[last_run_time] as nvarchar(255)),4))=3  then substring(right(cast(js.[last_run_time] as nvarchar(255)),4),1,1)
								 else 0
							end,
							right(cast(js.[last_run_duration] as nvarchar(255)),2),
							0
						)
		else NULL
	   end as LastDateTimeStep
       ,case when len(cast(js.[last_run_duration] as nvarchar(255)))>5 then substring(cast(js.[last_run_duration] as nvarchar(255)),1,len(cast(js.[last_run_duration] as nvarchar(255)))-4)
		    when len(cast(js.[last_run_duration] as nvarchar(255)))=5 then '0'+substring(cast(js.[last_run_duration] as nvarchar(255)),1,len(cast(js.[last_run_duration] as nvarchar(255)))-4)
		    else '00'
	   end
	   +':'
	   +case when len(cast(js.[last_run_duration] as nvarchar(255)))>=4 then substring(right(cast(js.[last_run_duration] as nvarchar(255)),4),1,2)
			 when len(cast(js.[last_run_duration] as nvarchar(255)))=3  then '0'+substring(right(cast(js.[last_run_duration] as nvarchar(255)),4),1,1)
			 else '00'
	   end
	   +':'
	   +case when len(cast(js.[last_run_duration] as nvarchar(255)))>=2 then substring(right(cast(js.[last_run_duration] as nvarchar(255)),2),1,2)
			 when len(cast(js.[last_run_duration] as nvarchar(255)))=2  then '0'+substring(right(cast(js.[last_run_duration] as nvarchar(255)),2),1,1)
			 else '00'
	   end as [LastRunDurationStringStep]
	   ,js.last_run_duration as LastRunDurationIntStep
  FROM [inf].[vJobServers] as sj
  inner join [inf].[vJOBS] as j on j.job_id=sj.job_id
  inner join [inf].[vJobSteps] as js on j.job_id=js.job_id




GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on view [inf].[vJobStepRunShortInfo]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Краткая информация о последних выполнениях заданий и их шагов Агента экземпляра MS SQL Server', 'SCHEMA', N'inf', 'VIEW', N'vJobStepRunShortInfo'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter view [inf].[vJobActivity]
--
GO


ALTER view [inf].[vJobActivity] as
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
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [zabbix].[GetJobAgentProblemCount]
--
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetJobAgentProblemCount]
	@run_minutes int = 30 --максимальное время работы задания Агента
AS
BEGIN
	/*
		Количество проблемных заданий Агента (завершившиеся с ошибкой за последние 24 часа или которые выполняются на текущий момент времени более установленных минут)
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	if(@run_minutes<60) set @run_minutes=60;

	;with tbl as (
		SELECT [Job_GUID]
		      ,[Job_Name]
		  FROM [inf].[vJobStepRunShortInfo]
		  where ([LastRunOutcome]<>1 or [LastRunOutcomeStep]<>1)
			 and [LastDateTime]>=DateAdd(day,-1,GetDate())
			 and [LastDateTimeStep]>=DateAdd(day,-1,GetDate())
		union all
		select [job_id]
			  ,[name]
		from [inf].[vJobActivity]
		where [start_execution_date]<=DateAdd(minute, -@run_minutes, GetDate())
	)
	select count(*) as [count]
	from tbl;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [zabbix].[GetJobAgentProblemCount]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Возвращает количество проблемных заданий Агента (завершившиеся с ошибкой за последние 24 часа или которые выполняются на текущий момент времени более установленных минут)', 'SCHEMA', N'zabbix', 'PROCEDURE', N'GetJobAgentProblemCount'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[AutoBigQueryStatistics]
--
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [srv].[AutoBigQueryStatistics]
AS
BEGIN
	/*
		Сбор данных по самым длительным запросам MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT @@SERVERNAME AS [Server]
            ,[creation_time]
			,[last_execution_time]
			,[execution_count]
			,[CPU]
			,[AvgCPUTime]
			,[TotDuration]
			,[AvgDur]
			,[AvgIOLogicalReads]
			,[AvgIOLogicalWrites]
			,[AggIO]
			,[AvgIO]
			,[AvgIOPhysicalReads]
			,[plan_generation_num]
			,[AvgRows]
			,[AvgDop]
			,[AvgGrantKb]
			,[AvgUsedGrantKb]
			,[AvgIdealGrantKb]
			,[AvgReservedThreads]
			,[AvgUsedThreads]
			,[query_text]
			,[database_name]
			,[object_name]
			,[query_plan]
			,[sql_handle]
			,[plan_handle]
			,[query_hash]
			,[query_plan_hash]
			into #tbl
	 FROM [inf].[vBigQuery];

	INSERT INTO [srv].[BigQueryStatistics]
           ([Server]
           ,[creation_time]
           ,[last_execution_time]
           ,[execution_count]
           ,[CPU]
           ,[AvgCPUTime]
           ,[TotDuration]
           ,[AvgDur]
           ,[AvgIOLogicalReads]
           ,[AvgIOLogicalWrites]
           ,[AggIO]
           ,[AvgIO]
           ,[AvgIOPhysicalReads]
           ,[plan_generation_num]
           ,[AvgRows]
           ,[AvgDop]
           ,[AvgGrantKb]
           ,[AvgUsedGrantKb]
           ,[AvgIdealGrantKb]
           ,[AvgReservedThreads]
           ,[AvgUsedThreads]
           ,[query_text]
           ,[database_name]
           ,[object_name]
           ,[query_plan]
           ,[sql_handle]
           ,[plan_handle]
           ,[query_hash]
           ,[query_plan_hash])
	 SELECT [Server]
           ,[creation_time]
           ,[last_execution_time]
           ,[execution_count]
           ,[CPU]
           ,[AvgCPUTime]
           ,[TotDuration]
           ,[AvgDur]
           ,[AvgIOLogicalReads]
           ,[AvgIOLogicalWrites]
           ,[AggIO]
           ,[AvgIO]
           ,[AvgIOPhysicalReads]
           ,[plan_generation_num]
           ,[AvgRows]
           ,[AvgDop]
           ,[AvgGrantKb]
           ,[AvgUsedGrantKb]
           ,[AvgIdealGrantKb]
           ,[AvgReservedThreads]
           ,[AvgUsedThreads]
           ,[query_text]
           ,[database_name]
           ,[object_name]
           ,[query_plan]
           ,[sql_handle]
           ,[plan_handle]
           ,[query_hash]
           ,[query_plan_hash]
	 FROM #tbl;

	 --подсчет общего индикатора производительности по всему экземпляру MS SQL SERVER
	 INSERT INTO [srv].[IndicatorServerDayStatistics]
           ([Server]
           ,[ExecutionCount]
           ,[AvgDur]
           ,[AvgCPUTime]
           ,[AvgIOLogicalReads]
           ,[AvgIOLogicalWrites]
           ,[AvgIOPhysicalReads]
           ,[DATE])
	SELECT	@@SERVERNAME AS [Server],
			SUM([execution_count]),
			AVG([AvgDur]),
			AVG([AvgCPUTime]),
            AVG([AvgIOLogicalReads]),
            AVG([AvgIOLogicalWrites]),
            AVG([AvgIOPhysicalReads]),
			CAST(GETUTCDATE() AS DATE)
	FROM #tbl;

	--группируем по запросам за все время сбора
	truncate table [srv].[BigQueryGroupStatistics];

	INSERT INTO [srv].[BigQueryGroupStatistics]
           ([Server]
           ,[creation_time]
           ,[last_execution_time]
           ,[execution_count]
           ,[CPU]
           ,[AvgCPUTime]
           ,[TotDuration]
           ,[AvgDur]
           ,[AvgIOLogicalReads]
           ,[AvgIOLogicalWrites]
           ,[AggIO]
           ,[AvgIO]
           ,[AvgIOPhysicalReads]
           ,[plan_generation_num]
           ,[AvgRows]
           ,[AvgDop]
           ,[AvgGrantKb]
           ,[AvgUsedGrantKb]
           ,[AvgIdealGrantKb]
           ,[AvgReservedThreads]
           ,[AvgUsedThreads]
           ,[query_text]
           ,[database_name]
           ,[object_name]
           ,[query_plan]
           ,[sql_handle]
           ,[plan_handle]
           ,[query_hash]
           ,[query_plan_hash]
           ,[InsertUTCDate])
	select [Server]
      ,max([creation_time])			as [creation_time]
      ,max([last_execution_time])	as [last_execution_time]
      ,sum([execution_count])		as [execution_count]
      ,max([CPU])					as [CPU]
      ,max([AvgCPUTime])			as [AvgCPUTime]
      ,max([TotDuration])			as [TotDuration]
      ,max([AvgDur])				as [AvgDur]
      ,max([AvgIOLogicalReads])		as [AvgIOLogicalReads]
      ,max([AvgIOLogicalWrites])	as [AvgIOLogicalWrites]
      ,max([AggIO])					as [AggIO]
      ,max([AvgIO])					as [AvgIO]
      ,max([AvgIOPhysicalReads])	as [AvgIOPhysicalReads]
      ,max([plan_generation_num])	as [plan_generation_num]
      ,max([AvgRows])				as [AvgRows]
      ,max([AvgDop])				as [AvgDop]
      ,max([AvgGrantKb])			as [AvgGrantKb]
      ,max([AvgUsedGrantKb])		as [AvgUsedGrantKb]
      ,max([AvgIdealGrantKb])		as [AvgIdealGrantKb]
      ,max([AvgReservedThreads])	as [AvgReservedThreads]
      ,max([AvgUsedThreads])		as [AvgUsedThreads]
      ,[query_text]
      ,max([database_name])			as [database_name]
      ,max([object_name])			as [object_name]
      ,cast(max(cast([query_plan] as nvarchar(max))) as XML) as [query_plan]
      ,max([sql_handle])			as [sql_handle]
      ,max([plan_handle])			as [plan_handle]
      ,max([query_hash])			as [query_hash]
      ,max([query_plan_hash])		as [query_plan_hash]
	  ,max([InsertUTCDate])			as [InsertUTCDate]
	from [srv].[BigQueryStatistics]
	group by [Server], [query_text];

	DROP TABLE #tbl;
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create procedure [srv].[AutoDBFile]
--
GO


CREATE PROCEDURE [srv].[AutoDBFile]
AS
BEGIN
	/*
		автосбор данных о всех файлах всех БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	INSERT INTO [srv].[DBFileStatistics]
           ([DBName]
           ,[FileId]
           ,[NumberReads]
           ,[BytesRead]
           ,[IoStallReadMS]
           ,[NumberWrites]
           ,[BytesWritten]
           ,[IoStallWriteMS]
           ,[IoStallMS]
           ,[BytesOnDisk]
           ,[TimeStamp]
           ,[FileHandle]
           ,[Type_desc]
           ,[FileName]
           ,[Drive]
           ,[Physical_Name]
           ,[Ext]
           ,[CountPage]
           ,[SizeMb]
           ,[SizeGb]
           ,[Growth]
           ,[GrowthMb]
           ,[GrowthGb]
           ,[GrowthPercent]
           ,[is_percent_growth]
           ,[database_id]
           ,[State]
           ,[StateDesc]
           ,[IsMediaReadOnly]
           ,[IsReadOnly]
           ,[IsSpace]
           ,[IsNameReserved]
           ,[CreateLsn]
           ,[DropLsn]
           ,[ReadOnlyLsn]
           ,[ReadWriteLsn]
           ,[DifferentialBaseLsn]
           ,[DifferentialBaseGuid]
           ,[DifferentialBaseTime]
           ,[RedoStartLsn]
           ,[RedoStartForkGuid]
           ,[RedoTargetLsn]
           ,[RedoTargetForkGuid]
           ,[BackupLsn])
     select
           [DBName]
           ,[FileId]
           ,[NumberReads]
           ,[BytesRead]
           ,[IoStallReadMS]
           ,[NumberWrites]
           ,[BytesWritten]
           ,[IoStallWriteMS]
           ,[IoStallMS]
           ,[BytesOnDisk]
           ,[TimeStamp]
           ,[FileHandle]
           ,[Type_desc]
           ,[FileName]
           ,[Drive]
           ,[Physical_Name]
           ,[Ext]
           ,[CountPage]
           ,[SizeMb]
           ,[SizeGb]
           ,[Growth]
           ,[GrowthMb]
           ,[GrowthGb]
           ,[GrowthPercent]
           ,[is_percent_growth]
           ,[database_id]
           ,[State]
           ,[StateDesc]
           ,[IsMediaReadOnly]
           ,[IsReadOnly]
           ,[IsSpace]
           ,[IsNameReserved]
           ,[CreateLsn]
           ,[DropLsn]
           ,[ReadOnlyLsn]
           ,[ReadWriteLsn]
           ,[DifferentialBaseLsn]
           ,[DifferentialBaseGuid]
           ,[DifferentialBaseTime]
           ,[RedoStartLsn]
           ,[RedoStartForkGuid]
           ,[RedoTargetLsn]
           ,[RedoTargetForkGuid]
           ,[BackupLsn]
	from [inf].[vDBFilesOperationsStat];
END


GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on procedure [srv].[AutoDBFile]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'Выполняет сбор данных о всех файлах всех БД', 'SCHEMA', N'srv', 'PROCEDURE', N'AutoDBFile'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter procedure [srv].[AutoDataCollection]
--
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [srv].[AutoDataCollection]
AS
BEGIN
	/*
		Сбор данных
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	EXEC [srv].[AutoStatisticsDiskAndRAMSpace];
	EXEC [srv].[AutoStatisticsFileDB];
    EXEC [srv].[AutoBigQueryStatistics];
	EXEC [srv].[AutoIndexStatistics];
	EXEC [srv].[AutoShortInfoRunJobs];
	EXEC [srv].[AutoStatisticsIOInTempDBStatistics];
	EXEC [srv].[AutoNewIndexOptimizeStatistics];
	EXEC [srv].[AutoWaitStatistics];
	EXEC [srv].[AutoReadWriteTablesStatistics];
	EXEC [srv].[InsertTableStatistics];
	EXEC [srv].[AutoDBFile];
END
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Commit Transaction
--
IF @@TRANCOUNT>0 COMMIT TRANSACTION
GO

--
-- Set NOEXEC to off
--
SET NOEXEC OFF
GO