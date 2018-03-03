CREATE PROCEDURE [srv].[RunLogShippingFailover]
	@isfailover			bit=1,
	@login				nvarchar(255)=N'домен\логин',
	@backup_directory	nvarchar(255)=N'D:\Shared'
AS
	/*
		переводит резервный сервер в основной режим при потере боевого сервера при @isfailover=1 полностью автоматизировано
		при @isfailover=0 ничего не проиходит-здесь нужно создать заново журнал доставки журналов с резервного на основной
			, а затем сделать переход на основной сервер и далее уже там вновь настроить доставку журналов транзакций заново.
		Считается, что данный резервный сервер принимает только от одного сервера резервные копии журналов транзакций
	*/
BEGIN
	--если совершается переход на резервный сервер, то выполнить все задания по копированию последних файлов с источника
	if(@isfailover=1)
	begin
		select [job_id]
		into #jobs
		from [msdb].[dbo].[sysjobs]
		where [name] like 'LSCopy%';
	
		declare @job_id uniqueidentifier;
	
		while(exists(select top(1) 1 from #jobs))
		begin
			select top(1)
			@job_id=[job_id]
			from #jobs;
	
			begin try
				EXEC [msdb].dbo.sp_start_job @job_id=@job_id;
			end try
			begin catch
			end catch
	
			delete from #jobs
			where [job_id]=@job_id;
		end
		
		drop table #jobs;
	end
	
	--выключить все задания по копированию файлов с источника при переходе на резервный сервер
	--включить все задания по копированию файлов с источника при возврате на боевой сервер
	update [msdb].[dbo].[sysjobs]
	set [enabled]=case when (@isfailover=1) then 0 else 1 end
	where [name] like 'LSCopy%';
	
	--если совершается переход на резервный сервер, то выполнить все задания по восстановлению БД по последним файлам с источника
	if(@isfailover=1)
	begin
		select [job_id]
		into #jobs2
		from [msdb].[dbo].[sysjobs]
		where [name] like 'LSRestore%';
	
		while(exists(select top(1) 1 from #jobs2))
		begin
			select top(1)
			@job_id=[job_id]
			from #jobs2;
	
			begin try
				EXEC [msdb].dbo.sp_start_job @job_id=@job_id;
				EXEC [msdb].dbo.sp_start_job @job_id=@job_id;
			end try
			begin catch
			end catch
	
			delete from #jobs2
			where [job_id]=@job_id;
		end
		drop table #jobs2;
	end
	
	--выключить все задания по восстановлению БД по последним файлам с источника при переходе на резервный сервер
	--включить все задания по восстановлению БД по последним файлам с источника при возврате на боевой сервер
	update [msdb].[dbo].[sysjobs]
	set [enabled]=case when (@isfailover=1) then 0 else 1 end
	where [name] like 'LSRestore%';
	
	--при переходе на резервный сервер, делаем БД восстановленными и основными по доставкам журнала, но без получателя
	if(@isfailover=1)
	begin
		select [secondary_database] as [name]
		into #dbs
		from msdb.dbo.log_shipping_monitor_secondary
		where [secondary_server]=@@SERVERNAME;
	
		declare @db nvarchar(255);
	
		while(exists(select top(1) 1 from #dbs))
		begin
			select top(1)
			@db=[name]
			from #dbs;
	
			begin try
				RESTORE DATABASE @db WITH RECOVERY;
			end try
			begin catch
			end catch
	
			delete from #dbs
			where [name]=@db;
		end
	
		drop table #dbs;
	
		select [secondary_database] as [name]
		into #dbs2
		from msdb.dbo.log_shipping_monitor_secondary
		where [secondary_server]=@@SERVERNAME;
	
		declare @jobId BINARY(16);
		declare @command nvarchar(max);
	
		declare @dt nvarchar(255)=cast(YEAR(GetDate()) as nvarchar(255))
							  +'_'+cast(MONTH(GetDate()) as nvarchar(255))
							  +'_'+cast(DAY(GetDate()) as nvarchar(255))
							  +'_'+cast(DatePart(hour,GetDate()) as nvarchar(255))
							  +'_'+cast(DatePart(minute,GetDate()) as nvarchar(255))
							  +'.trn';
	
		declare @backup_job_name		nvarchar(255);
		declare @schedule_name			nvarchar(255);
		declare @disk					nvarchar(255);
		declare @uid					uniqueidentifier;
	
		while(exists(select top(1) 1 from #dbs2))
		begin
			select top(1)
			@db=[name]
			from #dbs2;
	
			set @disk=@backup_directory+N'\'+@db+N'.bak';
			set @backup_job_name=N'LSBackup_'+@db;
			set @schedule_name=N'LSBackupSchedule_'+@@SERVERNAME+N'_'+@db;
			set @command=N'declare @disk nvarchar(max)='+N''''+@backup_directory+N'\'+@db+'_'+@dt+N''''
						+N'BACKUP LOG ['+@db+'] TO DISK = @disk
							WITH NOFORMAT, NOINIT,  NAME = '+N''''+@db+N''''+N', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;';
			set @uid=newid();
			
			begin try
				BACKUP DATABASE @db TO  DISK = @disk 
				WITH NOFORMAT, NOINIT,  NAME = @db, SKIP, NOREWIND, NOUNLOAD,  STATS = 10;
				
				EXEC msdb.dbo.sp_add_job @job_name=@backup_job_name, 
				@enabled=1, 
				@notify_level_eventlog=0, 
				@notify_level_email=0, 
				@notify_level_netsend=0, 
				@notify_level_page=0, 
				@delete_level=0, 
				@description=N'No description available.', 
				@category_name=N'[Uncategorized (Local)]', 
				@owner_login_name=@login, @job_id = @jobId OUTPUT;
		
				EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=@backup_job_name, 
				@step_id=1, 
				@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N'TSQL', 
				@command=@command, 
				@database_name=N'master', 
				@flags=0;
	
				EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;
	
				EXEC msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=@backup_job_name, 
				@enabled=1, 
				@freq_type=4, 
				@freq_interval=1, 
				@freq_subday_type=4, 
				@freq_subday_interval=5, 
				@freq_relative_interval=0, 
				@freq_recurrence_factor=0, 
				@active_start_date=20171009, 
				@active_end_date=99991231, 
				@active_start_time=0, 
				@active_end_time=235959, 
				@schedule_uid=@uid;
	
				EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)';
			end try
			begin catch
			end catch
	
			delete from #dbs2
			where [name]=@db;
		end
	
		drop table #dbs2;
	end
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отработка отказа при доставке журналов транзакций', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'RunLogShippingFailover';

