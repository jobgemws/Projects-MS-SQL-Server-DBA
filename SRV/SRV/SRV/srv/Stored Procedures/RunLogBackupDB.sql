-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[RunLogBackupDB]
  @ClearLog BIT = 1 --усекать ли журнал транзакций
, @IsExtName BIT = 1 --добавлять ли к имени дату и время в формате YYYY_MM_DD_HH_MM_SS в формате UTC
, @IsCHECKDB BIT = 0 --проверять ли базу данных перед резервным копированием
, @IsContinueAfterError BIT = 0 --продолжать ли создание резервной копии при возниакновении ошибок (NULL-по умолчанию)
, @IsCopyOnly BIT = 0 --создать ли резервную копию только для копирования
, @OnlyDBName NVARCHAR(255) = NULL --создать резервную копию для заданной базы данных
AS
BEGIN
	/*
		Создание резервной копии журнала транзакции БД
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
	DECLARE @FileNameLog NVARCHAR(255);
	DECLARE @ContinueAfterError NVARCHAR(255);
	DECLARE @CopyOnly NVARCHAR(255);

	IF (@IsContinueAfterError = 1)
		SET @ContinueAfterError = N', CONTINUE_AFTER_ERROR';
	ELSE IF(@IsContinueAfterError=0)
		SET @ContinueAfterError = N', STOP_ON_ERROR';
	ELSE SET @ContinueAfterError=N'';

	IF (@IsCopyOnly = 1)
		SET @CopyOnly = N'COPY_ONLY, ';
	ELSE
		SET @CopyOnly = N'';

	DECLARE @tbllog TABLE (
		[DBName] [NVARCHAR](255) NOT NULL
	   ,[FileNameLog] [NVARCHAR](255) NOT NULL
	);
	
	declare @tbl table (
		[DBName] [nvarchar](255) NOT NULL,
		[LogPathBackup] [nvarchar](255) NOT NULL
	);
	
	insert into @tbl (
	           [DBName]
	           ,[LogPathBackup]
	)
	select		DB_NAME(b.[DBID])
	           ,b.[LogPathBackup]
	from [srv].[BackupSettings] as b
	inner join sys.databases as d on b.[DBID]=d.[database_id]
	where d.recovery_model<3
	AND ((DB_NAME([DBID])=@OnlyDBName) OR (@OnlyDBName IS NULL))
	and DB_NAME([DBID]) not in (
		N'master',
		N'tempdb',
		N'model',
		N'msdb',
		N'ReportServer',
		N'ReportServerTempDB'
	)
	and [LogPathBackup] is not null;

	INSERT INTO @tbllog ([DBName], [FileNameLog])
	SELECT
		t.[DBName]
	   ,tt.[FileName] AS [FileNameLog]
	FROM @tbl AS t
	INNER JOIN [inf].[ServerDBFileInfo] AS tt
		ON t.[DBName] = DB_NAME(tt.[database_id])
	WHERE tt.[Type_desc] = N'LOG';

	DECLARE db_cursor CURSOR LOCAL
    FOR SELECT [DBName]
	           ,[LogPathBackup]
	FROM @tbl;

	OPEN db_cursor; 
	
	FETCH NEXT FROM db_cursor   
	INTO @DBName, @pathBackup;
	
	while(@@FETCH_STATUS = 0)
	begin
		set @backupSetId=NULL;

		IF (@IsExtName = 1)
		BEGIN
			SET @backupName = @DBName + N'_Log_backup_' + CAST(@year AS NVARCHAR(255)) + N'_' +
				CASE WHEN (@month<10) THEN N'0' ELSE N'' END + CAST(@month AS NVARCHAR(255)) + N'_' + 
				CASE WHEN (@day<10) THEN N'0' ELSE N'' END +CAST(@day AS NVARCHAR(255))+N'_'+
				CASE WHEN (@hour<10) THEN N'0' ELSE N'' END + cast(@hour as nvarchar(255))+N'_'+
				CASE WHEN (@minute<10) THEN N'0' ELSE N'' END + cast(@minute as nvarchar(255))+N'_'+
				CASE WHEN (@second<10) THEN N'0' ELSE N'' END + cast(@second as nvarchar(255));
		END
		ELSE
		BEGIN
			SET @backupName = @DBName;
		END

		SET @pathstr = @pathBackup + @backupName + N'.trn';

		IF (@IsCHECKDB = 1)
		BEGIN
			SET @sql = N'DBCC CHECKDB(N' + N'''' + @DBName + N'''' + N')  WITH NO_INFOMSGS';

			EXEC (@sql);
		END
	
		set @sql=N'BACKUP LOG ['+@DBName+N'] TO DISK = N'+N''''+@pathstr+N''''+
				 N' WITH  ' + @CopyOnly + N'NOFORMAT, NOINIT, NAME = N'+N''''+@backupName+N''''+
				 N', CHECKSUM, SKIP, REWIND, COMPRESSION, STATS = 10'+@ContinueAfterError+N';';
	
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
		END

		IF (@ClearLog = 1)
		BEGIN
			DECLARE log_cursor CURSOR LOCAL
			FOR SELECT [FileNameLog]
			FROM @tbllog
			WHERE DBName = @DBName;

			OPEN log_cursor; 
			
			FETCH NEXT FROM log_cursor   
			INTO @FileNameLog;
			
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				SET @sql = N'USE [' + @DBName + N'];' + N' DBCC SHRINKFILE (N' + N'''' + @FileNameLog + N'''' + N' , 0, TRUNCATEONLY)';

				EXEC (@sql);

				FETCH NEXT FROM log_cursor   
				INTO @FileNameLog;
			END

			CLOSE log_cursor;  
			DEALLOCATE log_cursor;
		END
		
		FETCH NEXT FROM db_cursor   
		INTO @DBName, @pathBackup;
	END

	CLOSE db_cursor;  
	DEALLOCATE db_cursor;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Создание резервной копии журнала транзакции БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'RunLogBackupDB';

