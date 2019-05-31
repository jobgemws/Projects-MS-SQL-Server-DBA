




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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает признак существования в журнале ошибок MS SQL Server подозрительных записей', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetExistsErrorInLog';

