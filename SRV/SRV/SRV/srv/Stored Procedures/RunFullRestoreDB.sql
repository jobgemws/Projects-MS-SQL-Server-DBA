
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[RunFullRestoreDB]
	@OnlyDBName NVARCHAR(255) = NULL, --восстановить только заданную базу данных
	@IsNameAddRestore BIT = 1 --добавлять ли в конец именам базы данных и файлов строку "_Restore"
AS
BEGIN
	/*
		Восстановление из полной резервной копии БД с последующей проверкой на целостность самой БД
	*/
	SET NOCOUNT ON;

    declare @dt datetime=DateAdd(day,-2,getdate());
	declare @year int=YEAR(@dt);
	declare @month int=MONTH(@dt);
	declare @day int=DAY(@dt);
	declare @hour int=DatePart(hour, @dt);
	declare @minute int=DatePart(minute, @dt);
	declare @second int=DatePart(second, @dt);
	declare @pathFullBackup nvarchar(255);
	declare @pathDiffBackup nvarchar(255);
	declare @pathLogBackup nvarchar(255);
	declare @fileFullBackup nvarchar(255);
	declare @fileDiffBackup nvarchar(255);
	declare @DBName nvarchar(255);
	declare @backupName nvarchar(255);
	declare @sql nvarchar(max);
	declare @backupSetId as int;
	declare @FileNameLog nvarchar(255);
	declare @SourcePathRestore nvarchar(255);
	declare @TargetPathRestore nvarchar(255);
	declare @Ext nvarchar(255);
	DECLARE @cmd VARCHAR(2000);
	declare @file_index_ext int;
	DECLARE @file_ext nvarchar(8);
	DECLARE @file_temp NVARCHAR(255);
	DECLARE @file_dt_str NCHAR(19);
	DECLARE @file_type NVARCHAR(4);
	DECLARE @dt_log DATETIME;
	DECLARE @file NVARCHAR(255);
	DECLARE @count_trn_files INT;
	DECLARE @ind_trn_files INT=1;
	
	declare @tbl table (
		[DBName] NVARCHAR(255) NOT NULL,
		[FullPathRestore] NVARCHAR(255) NOT NULL,
		[DiffPathRestore] NVARCHAR(255) NULL,
	    [LogPathRestore] NVARCHAR(255) NULL
	);

	declare @tbl_files table (
		[DBName] [nvarchar](255) NOT NULL,
		[SourcePathRestore] [nvarchar](255) NOT NULL,
		[TargetPathRestore] [nvarchar](255) NOT NULL,
		[Ext] [nvarchar](255) NOT NULL
	);

	DECLARE @files TABLE ([file] NVARCHAR(255));

	DECLARE @files_in_dir TABLE ([DBName] NVARCHAR(255), [BackupType] NVARCHAR(4), [DT] DATETIME, [file] NVARCHAR(255));

	DECLARE @file_full_backup NVARCHAR(255);
	DECLARE @file_diff_backup NVARCHAR(255);

	DECLARE @trn_files TABLE ([file] NVARCHAR(255), [dt] DATETIME);
	
	insert into @tbl (
	           [DBName]
	           ,[FullPathRestore]
			   ,[DiffPathRestore]
			   ,[LogPathRestore]
	)
	select		[DBName]
	           ,[FullPathRestore]
			   ,[DiffPathRestore]
			   ,[LogPathRestore]
	from [srv].[RestoreSettings]
	WHERE (([DBName]=@OnlyDBName) OR (@OnlyDBName IS NULL));

	insert into @tbl_files (
	           [DBName]
	           ,[SourcePathRestore]
			   ,[TargetPathRestore]
			   ,[Ext]
	)
	select		[DBName]
	           ,[SourcePathRestore]
			   ,[TargetPathRestore]
			   ,[Ext]
	from [srv].[RestoreSettingsDetail]
	WHERE (([DBName]=@OnlyDBName) OR (@OnlyDBName IS NULL));
	
	DECLARE db_cursor CURSOR LOCAL
    FOR SELECT [DBName]
	           ,[FullPathRestore]
			   ,[DiffPathRestore]
			   ,[LogPathRestore]
	FROM @tbl;

	OPEN db_cursor; 
	
	FETCH NEXT FROM db_cursor   
	INTO @DBName, @pathFullBackup, @pathDiffBackup, @pathLogBackup;
	
	while(@@FETCH_STATUS = 0)
	BEGIN
		set @backupSetId=NULL;

		DELETE FROM @files;

		SET @cmd='dir "'+@pathFullBackup+N'" /b';

		INSERT INTO @files([file])
		EXECUTE xp_cmdshell @cmd;

		DECLARE file_cursor CURSOR LOCAL
		FOR SELECT [file]
		FROM @files;

		OPEN file_cursor; 
		
		FETCH NEXT FROM file_cursor   
		INTO @file;

		DELETE FROM @files_in_dir;
		
		while(@@FETCH_STATUS = 0)
		BEGIN
			IF(LEN(@file)>=34)
			BEGIN
				SET @file_index_ext=CHARINDEX('.', @file);
				
				SET @file_ext=SUBSTRING(@file, @file_index_ext+1, LEN(@file)-@file_index_ext);
			
				SET @file_temp=SUBSTRING(@file, 1, @file_index_ext-1);
			
				SET @file_dt_str=SUBSTRING(@file_temp, LEN(@file_temp)-18, 19);
			
				SET @file_temp=SUBSTRING(@file_temp, 1, LEN(@file_temp)-20);
			
				IF(SUBSTRING(@file_temp, LEN(@file_temp)-LEN(N'backup')+1, LEN(N'backup'))=N'backup')
				BEGIN
					SET @file_temp=SUBSTRING(@file_temp,1, LEN(@file_temp)-LEN(N'backup')-1);
			
					BEGIN TRY
						SET @year=CAST(SUBSTRING(@file_dt_str,1,4) AS INT);
						SET @month=CAST(SUBSTRING(@file_dt_str,6,2) AS INT);
						SET @day=CAST(SUBSTRING(@file_dt_str,9,2) AS INT);
						SET @hour=CAST(SUBSTRING(@file_dt_str,12,2) AS INT);
						SET @minute=CAST(SUBSTRING(@file_dt_str,15,2) AS INT);
						SET @second=CAST(SUBSTRING(@file_dt_str,18,2) AS INT);
			
						SET @file_type=REPLACE(SUBSTRING(@file_temp, LEN(@file_temp)-3, 4), N'_', N'');
			
						SET @file_temp=SUBSTRING(@file_temp, 1, LEN(@file_temp)-LEN(@file_type)-1);

						IF((@DBName=@file_temp) AND (@file_type=N'Full'))
						BEGIN
							INSERT INTO @files_in_dir ([DBName], [BackupType], [DT], [file])
							SELECT @file_temp, @file_type, DATETIMEFROMPARTS(@year, @month, @day, @hour, @minute, @second, 0), @file;
						END
					END TRY
					BEGIN CATCH
					END CATCH
				END
			END
			
			FETCH NEXT FROM file_cursor   
			INTO @file;
		END

		CLOSE file_cursor;  
		DEALLOCATE file_cursor;

		DELETE FROM @files;

		SELECT TOP(1)
		@file_full_backup=[file],
		@dt_log=[DT]
		FROM @files_in_dir
		ORDER BY [DT] DESC;

		SET @cmd='dir "'+@pathDiffBackup+N'" /b';

		INSERT INTO @files([file])
		EXECUTE xp_cmdshell @cmd;

		DECLARE file_cursor CURSOR LOCAL
		FOR SELECT [file]
		FROM @files;

		OPEN file_cursor; 
		
		FETCH NEXT FROM file_cursor   
		INTO @file;

		DELETE FROM @files_in_dir;
		
		while(@@FETCH_STATUS = 0)
		BEGIN
			IF(LEN(@file)>=34)
			BEGIN
				SET @file_index_ext=CHARINDEX('.', @file);
				
				SET @file_ext=SUBSTRING(@file, @file_index_ext+1, LEN(@file)-@file_index_ext);
			
				SET @file_temp=SUBSTRING(@file, 1, @file_index_ext-1);
			
				SET @file_dt_str=SUBSTRING(@file_temp, LEN(@file_temp)-18, 19);
			
				SET @file_temp=SUBSTRING(@file_temp, 1, LEN(@file_temp)-20);
			
				IF(SUBSTRING(@file_temp, LEN(@file_temp)-LEN(N'backup')+1, LEN(N'backup'))=N'backup')
				BEGIN
					SET @file_temp=SUBSTRING(@file_temp,1, LEN(@file_temp)-LEN(N'backup')-1);
			
					BEGIN TRY
						SET @year=CAST(SUBSTRING(@file_dt_str,1,4) AS INT);
						SET @month=CAST(SUBSTRING(@file_dt_str,6,2) AS INT);
						SET @day=CAST(SUBSTRING(@file_dt_str,9,2) AS INT);
						SET @hour=CAST(SUBSTRING(@file_dt_str,12,2) AS INT);
						SET @minute=CAST(SUBSTRING(@file_dt_str,15,2) AS INT);
						SET @second=CAST(SUBSTRING(@file_dt_str,18,2) AS INT);
			
						SET @file_type=REPLACE(SUBSTRING(@file_temp, LEN(@file_temp)-3, 4), N'_', N'');
			
						SET @file_temp=SUBSTRING(@file_temp, 1, LEN(@file_temp)-LEN(@file_type)-1);

						IF((@DBName=@file_temp) AND (@file_type=N'Diff'))
						BEGIN
							INSERT INTO @files_in_dir ([DBName], [BackupType], [DT], [file])
							SELECT @file_temp, @file_type, DATETIMEFROMPARTS(@year, @month, @day, @hour, @minute, @second, 0), @file;
						END
					END TRY
					BEGIN CATCH
					END CATCH
				END
			END
			
			FETCH NEXT FROM file_cursor   
			INTO @file;
		END

		CLOSE file_cursor;  
		DEALLOCATE file_cursor;

		DELETE FROM @files;

		SELECT TOP(1)
		@file_diff_backup=[file],
		@dt_log=[DT]
		FROM @files_in_dir
		WHERE [DT]>=@dt_log
		ORDER BY [DT] DESC;

		SET @cmd='dir "'+@pathLogBackup+N'" /b';

		INSERT INTO @files([file])
		EXECUTE xp_cmdshell @cmd;

		DECLARE file_cursor CURSOR LOCAL
		FOR SELECT [file]
		FROM @files;

		OPEN file_cursor; 
		
		FETCH NEXT FROM file_cursor   
		INTO @file;

		DELETE FROM @files_in_dir;
		
		while(@@FETCH_STATUS = 0)
		BEGIN
			IF(LEN(@file)>=34)
			BEGIN
				SET @file_index_ext=CHARINDEX('.', @file);
				
				SET @file_ext=SUBSTRING(@file, @file_index_ext+1, LEN(@file)-@file_index_ext);
			
				SET @file_temp=SUBSTRING(@file, 1, @file_index_ext-1);
			
				SET @file_dt_str=SUBSTRING(@file_temp, LEN(@file_temp)-18, 19);
			
				SET @file_temp=SUBSTRING(@file_temp, 1, LEN(@file_temp)-20);
			
				IF(SUBSTRING(@file_temp, LEN(@file_temp)-LEN(N'backup')+1, LEN(N'backup'))=N'backup')
				BEGIN
					SET @file_temp=SUBSTRING(@file_temp,1, LEN(@file_temp)-LEN(N'backup')-1);
			
					BEGIN TRY
						SET @year=CAST(SUBSTRING(@file_dt_str,1,4) AS INT);
						SET @month=CAST(SUBSTRING(@file_dt_str,6,2) AS INT);
						SET @day=CAST(SUBSTRING(@file_dt_str,9,2) AS INT);
						SET @hour=CAST(SUBSTRING(@file_dt_str,12,2) AS INT);
						SET @minute=CAST(SUBSTRING(@file_dt_str,15,2) AS INT);
						SET @second=CAST(SUBSTRING(@file_dt_str,18,2) AS INT);
			
						SET @file_type=REPLACE(SUBSTRING(@file_temp, LEN(@file_temp)-3, 4), N'_', N'');
			
						SET @file_temp=SUBSTRING(@file_temp, 1, LEN(@file_temp)-LEN(@file_type)-1);

						IF((@DBName=@file_temp) AND (@file_type=N'Log'))
						BEGIN
							INSERT INTO @files_in_dir ([DBName], [BackupType], [DT], [file])
							SELECT @file_temp, @file_type, DATETIMEFROMPARTS(@year, @month, @day, @hour, @minute, @second, 0), @file;
						END
					END TRY
					BEGIN CATCH
					END CATCH
				END
			END
			
			FETCH NEXT FROM file_cursor   
			INTO @file;
		END

		CLOSE file_cursor;  
		DEALLOCATE file_cursor;

		DELETE FROM @files;

		INSERT INTO @trn_files([file], [dt])
		SELECT [file], [DT]
		FROM @files_in_dir
		WHERE [DT]>=@dt_log;

		SET @count_trn_files=(SELECT COUNT(*) FROM @trn_files);
	
		set @fileFullBackup=@pathFullBackup+@file_full_backup;
		SET @fileDiffBackup=@pathDiffBackup+@file_diff_backup;

		IF(@fileFullBackup IS NOT NULL)
		BEGIN

			set @sql=N'RESTORE DATABASE ['+@DBName+CASE WHEN (@IsNameAddRestore=1) THEN N'_Restore' ELSE N'' END+N'] FROM DISK = N'+N''''+@fileFullBackup+N''''+
					 N' WITH FILE = 1,';

			DECLARE file_cursor CURSOR LOCAL
			FOR SELECT [SourcePathRestore], [TargetPathRestore], [Ext]
			FROM @tbl_files
			WHERE [DBName] = @DBName;

			OPEN file_cursor; 
			
			FETCH NEXT FROM file_cursor   
			INTO @SourcePathRestore, @TargetPathRestore, @Ext;
			
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				set @sql=@sql+N' MOVE N'+N''''+@SourcePathRestore+N''''+N' TO N'+N''''+@TargetPathRestore++CASE WHEN (@IsNameAddRestore=1) THEN N'_Restore' ELSE N'' END+N'.'+@Ext+N''''+N',';

				FETCH NEXT FROM file_cursor   
				INTO @SourcePathRestore, @TargetPathRestore, @Ext;
			END

			CLOSE file_cursor;  
			DEALLOCATE file_cursor;

			set @sql=@sql+N' NOUNLOAD,  REPLACE,  STATS = 5';

			IF(@count_trn_files>0)
			BEGIN
				set @sql=@sql+N', NORECOVERY';
			END

			SET @sql=@sql+N';';

			exec(@sql);

			IF(@fileDiffBackup IS NOT NULL)
			BEGIN
				set @sql=N'RESTORE DATABASE ['+@DBName++CASE WHEN (@IsNameAddRestore=1) THEN N'_Restore' ELSE N'' END+N'] FROM DISK = N'+N''''+@fileDiffBackup+N''''+
						 N' WITH FILE = 1,';

				DECLARE file_cursor CURSOR LOCAL
				FOR SELECT [SourcePathRestore], [TargetPathRestore], [Ext]
				FROM @tbl_files
				WHERE [DBName] = @DBName;

				OPEN file_cursor; 
				
				FETCH NEXT FROM file_cursor   
				INTO @SourcePathRestore, @TargetPathRestore, @Ext;
				
				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					set @sql=@sql+N' MOVE N'+N''''+@SourcePathRestore+N''''+N' TO N'+N''''+@TargetPathRestore++CASE WHEN (@IsNameAddRestore=1) THEN N'_Restore' ELSE N'' END+N'.'+@Ext+N''''+N',';

					FETCH NEXT FROM file_cursor   
					INTO @SourcePathRestore, @TargetPathRestore, @Ext;
				END

				CLOSE file_cursor;  
				DEALLOCATE file_cursor;

				set @sql=@sql+N' NOUNLOAD,  REPLACE,  STATS = 5';

				IF(@count_trn_files>0)
				BEGIN
					set @sql=@sql+N', NORECOVERY';
				END

				SET @sql=@sql+N';';

				exec(@sql);
			END

			DECLARE trn_cursor CURSOR LOCAL
			FOR SELECT [file]
			FROM @trn_files
			ORDER BY [DT] ASC;

			OPEN trn_cursor;

			SET @ind_trn_files=1;
			
			FETCH NEXT FROM trn_cursor   
			INTO @file;
			
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				set @sql=N'RESTORE LOG ['+@DBName++CASE WHEN (@IsNameAddRestore=1) THEN N'_Restore' ELSE N'' END+N'] FROM DISK = N'+N''''+@pathLogBackup+@file+N''''+
					 N' WITH FILE = 1, NOUNLOAD,  REPLACE,  STATS = 5, ';

				IF(@ind_trn_files=@count_trn_files) SET @sql+=N'RECOVERY;';
				ELSE SET @sql+=N'NORECOVERY;';

				exec(@sql);

				SET @ind_trn_files+=1;
				
				FETCH NEXT FROM trn_cursor   
				INTO @file;
			END

			CLOSE trn_cursor;  
			DEALLOCATE trn_cursor;

			set @sql=N'DBCC CHECKDB(N'+N''''+@DBName+CASE WHEN (@IsNameAddRestore=1) THEN N'_Restore' ELSE N'' END+N''''+N')  WITH NO_INFOMSGS';
	
			exec(@sql);
		END
		
		FETCH NEXT FROM db_cursor   
		INTO @DBName, @pathFullBackup, @pathDiffBackup, @pathLogBackup;
	END

	CLOSE db_cursor;  
	DEALLOCATE db_cursor;
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Восстановление базы данных из резервных копий', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'RunFullRestoreDB';

