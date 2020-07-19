-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[RunDiffBackupDB]
  @ClearLog BIT = 1 --усекать ли журнал транзакций
, @IsExtName BIT = 1 --добавлять ли к имени дату и время в формате YYYY_MM_DD_HH_MM_SS в формате UTC
, @IsCHECKDB BIT = 0 --проверять ли базу данных перед резервным копированием
, @IsContinueAfterError BIT = 0 --продолжать ли создание резервной копии при возниакновении ошибок (NULL-по умолчанию)
, @IsAllDB BIT = 0 --брать ли в обработку все БД
, @DiffPathBackup NVARCHAR(4000) = N'\\Shared\Backup\'--полный путь к каталогу для создания резервных копий (работает при @IsAllDB=1)
, @OnlyDBName NVARCHAR(255) = NULL --создать резервную копию для заданной базы данных (если этот параметр задан и @IsAllDB=1, то поиск идет по всем базам данных)
AS
BEGIN
	/*
		Создание полной резервной копии БД с предварительной проверкой на целостность самой БД
	*/
	SET NOCOUNT ON;

	DECLARE @dt DATETIME = GETUTCDATE();
	DECLARE @year INT = YEAR(@dt);
	DECLARE @month INT = MONTH(@dt);
	DECLARE @day INT = DAY(@dt);
	DECLARE @hour INT = DATEPART(HOUR, @dt);
	DECLARE @minute INT = DATEPART(MINUTE, @dt);
	DECLARE @second INT = DATEPART(SECOND, @dt);
	DECLARE @pathBackup NVARCHAR(255);
	DECLARE @pathstr NVARCHAR(255);
	DECLARE @DBName NVARCHAR(255);
	DECLARE @backupName NVARCHAR(255);
	DECLARE @sql NVARCHAR(MAX);
	DECLARE @backupSetId AS INT;
	DECLARE @FileNameLog NVARCHAR(255);
	DECLARE @ContinueAfterError NVARCHAR(255);

	IF (@IsContinueAfterError = 1)
		SET @ContinueAfterError = N', CONTINUE_AFTER_ERROR';
	ELSE IF(@IsContinueAfterError=0)
		SET @ContinueAfterError = N', STOP_ON_ERROR';
	ELSE SET @ContinueAfterError=N'';

	DECLARE @tbllog TABLE (
		[DBName] [NVARCHAR](255) NOT NULL
	   ,[FileNameLog] [NVARCHAR](255) NOT NULL
	);

	DECLARE @tbl TABLE (
		[DBName] [NVARCHAR](255) NOT NULL
	   ,[DiffPathBackup] [NVARCHAR](255) NOT NULL
	);

	IF (@IsAllDB = 1)
	BEGIN
		INSERT INTO @tbl ([DBName]
		, [DiffPathBackup])
			SELECT
				[name] AS [DBName]
			   ,@DiffPathBackup
			FROM sys.databases
			WHERE [database_id] > 4
			AND [State] = 0
			AND [user_access] = 0
			AND [is_in_standby] = 0
			AND (([name]=@OnlyDBName) OR (@OnlyDBName IS NULL));
	END
	ELSE
	BEGIN
		INSERT INTO @tbl ([DBName]
		, [DiffPathBackup])
			SELECT
				DB_NAME([DBID])
			   ,[DiffPathBackup]
			FROM [srv].[BackupSettings]
			WHERE ((DB_NAME([DBID])=@OnlyDBName) OR (@OnlyDBName IS NULL));
	END

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
	           ,[DiffPathBackup]
	FROM @tbl;

	OPEN db_cursor; 
	
	FETCH NEXT FROM db_cursor   
	INTO @DBName, @pathBackup;
	
	while(@@FETCH_STATUS = 0)
	BEGIN
		SET @backupSetId = NULL;

		SELECT TOP (1)
			@DBName = [DBName]
		   ,@pathBackup = [DiffPathBackup]
		FROM @tbl;

		IF (@IsExtName = 1)
		BEGIN
			SET @backupName = @DBName + N'_Diff_backup_' + CAST(@year AS NVARCHAR(255)) + N'_' +
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

		SET @pathstr = @pathBackup + @backupName + N'.bak';

		IF (@IsCHECKDB = 1)
		BEGIN
			SET @sql = N'DBCC CHECKDB(N' + N'''' + @DBName + N'''' + N')  WITH NO_INFOMSGS';

			EXEC (@sql);
		END

		SET @sql = N'BACKUP DATABASE [' + @DBName + N'] TO DISK = N' + N'''' + @pathstr + N'''' +
		N' WITH DIFFERENTIAL, NOFORMAT, NOINIT, NAME = N' + N'''' + @backupName + N'''' +
		N', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10, CHECKSUM' + @ContinueAfterError + N';';

		EXEC (@sql);

		SELECT
			@backupSetId = position
		FROM msdb..backupset
		WHERE database_name = @DBName
		AND backup_set_id = (SELECT
				MAX(backup_set_id)
			FROM msdb..backupset
			WHERE database_name = @DBName);

		SET @sql = N'Ошибка верификации. Сведения о резервном копировании для базы данных "' + @DBName + '" не найдены.';

		IF (@backupSetId IS NULL)
		BEGIN
			RAISERROR (@sql, 16, 1);
		END
		ELSE
		BEGIN
			SET @sql = N'RESTORE VERIFYONLY FROM DISK = N' + '''' + @pathstr + N'''' + N' WITH FILE = ' + CAST(@backupSetId AS NVARCHAR(255));

			EXEC (@sql);
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
EXECUTE sp_addextendedproperty @name = N'MS_Description'
							  ,@value = N'Создание дифференциальной резервной копии БД с предварительной проверкой на целостность самой БД'
							  ,@level0type = N'SCHEMA'
							  ,@level0name = N'srv'
							  ,@level1type = N'PROCEDURE'
							  ,@level1name = N'RunDiffBackupDB';

