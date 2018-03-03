-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[RunFullBackupDB]
	@ClearLog bit=1 --усекать ли журнал транзакций
AS
BEGIN
	/*
		Создание полной резервной копии БД с предварительной проверкой на целостность самой БД
	*/
	SET NOCOUNT ON;

    declare @dt datetime=getdate();
	declare @year int=YEAR(@dt);
	declare @month int=MONTH(@dt);
	declare @day int=DAY(@dt);
	declare @hour int=DatePart(hour, @dt);
	declare @minute int=DatePart(minute, @dt);
	declare @second int=DatePart(second, @dt);
	declare @pathBackup nvarchar(255);
	declare @pathstr nvarchar(255);
	declare @DBName nvarchar(255);
	declare @backupName nvarchar(255);
	declare @sql nvarchar(max);
	declare @backupSetId as int;
	declare @FileNameLog nvarchar(255);

	declare @tbllog table(
		[DBName] [nvarchar](255) NOT NULL,
		[FileNameLog] [nvarchar](255) NOT NULL
	);
	
	declare @tbl table (
		[DBName] [nvarchar](255) NOT NULL,
		[FullPathBackup] [nvarchar](255) NOT NULL
	);
	
	insert into @tbl (
	           [DBName]
	           ,[FullPathBackup]
	)
	select		DB_NAME([DBID])
	           ,[FullPathBackup]
	from [srv].[BackupSettings];

	insert into @tbllog([DBName], [FileNameLog])
	select t.[DBName], tt.[FileName] as [FileNameLog]
	from @tbl as t
	inner join [inf].[ServerDBFileInfo] as tt on t.[DBName]=DB_NAME(tt.[database_id])
	where tt.[Type_desc]='LOG';
	
	while(exists(select top(1) 1 from @tbl))
	begin
		set @backupSetId=NULL;

		select top(1)
		@DBName=[DBName],
		@pathBackup=[FullPathBackup]
		from @tbl;
	
		set @backupName=@DBName+N'_Full_backup_'+cast(@year as nvarchar(255))+N'_'+cast(@month as nvarchar(255))+N'_'+cast(@day as nvarchar(255))--+N'_'
						--+cast(@hour as nvarchar(255))+N'_'+cast(@minute as nvarchar(255))+N'_'+cast(@second as nvarchar(255));
		set @pathstr=@pathBackup+@backupName+N'.bak';

		set @sql=N'DBCC CHECKDB(N'+N''''+@DBName+N''''+N')  WITH NO_INFOMSGS';

		exec(@sql);
	
		set @sql=N'BACKUP DATABASE ['+@DBName+N'] TO DISK = N'+N''''+@pathstr+N''''+
				 N' WITH NOFORMAT, NOINIT, NAME = N'+N''''+@backupName+N''''+
				 N', CHECKSUM, STOP_ON_ERROR, SKIP, REWIND, COMPRESSION, STATS = 10;';
	
		exec(@sql);

		select @backupSetId = position
		from msdb..backupset where database_name=@DBName
		and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=@DBName);

		set @sql=N'Ошибка верификации. Сведения о резервном копировании для базы данных "'+@DBName+'" не найдены.';

		if @backupSetId is null begin raiserror(@sql, 16, 1) end
		else
		begin
			set @sql=N'RESTORE VERIFYONLY FROM DISK = N'+''''+@pathstr+N''''+N' WITH FILE = '+cast(@backupSetId as nvarchar(255));

			exec(@sql);
		end

		if(@ClearLog=1)
		begin
			while(exists(select top(1) 1 from @tbllog where [DBName]=@DBName))
			begin
				select top(1)
				@FileNameLog=FileNameLog
				from @tbllog
				where DBName=@DBName;
			
				set @sql=N'USE ['+@DBName+N'];'+N' DBCC SHRINKFILE (N'+N''''+@FileNameLog+N''''+N' , 0, TRUNCATEONLY)';

				exec(@sql);

				delete from @tbllog
				where FileNameLog=@FileNameLog
				and DBName=@DBName;
			end
		end
		
		delete from @tbl
		where [DBName]=@DBName;
	end
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Создание полной резервной копии БД с предварительной проверкой на целостность самой БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'RunFullBackupDB';

