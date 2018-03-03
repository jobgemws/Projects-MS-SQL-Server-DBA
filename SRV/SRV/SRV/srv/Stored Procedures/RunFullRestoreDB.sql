
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[RunFullRestoreDB]
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
	declare @pathBackup nvarchar(255);
	declare @pathstr nvarchar(255);
	declare @DBName nvarchar(255);
	declare @backupName nvarchar(255);
	declare @sql nvarchar(max);
	declare @backupSetId as int;
	declare @FileNameLog nvarchar(255);
	declare @SourcePathRestore nvarchar(255);
	declare @TargetPathRestore nvarchar(255);
	declare @Ext nvarchar(255);
	
	declare @tbl table (
		[DBName] [nvarchar](255) NOT NULL,
		[FullPathRestore] [nvarchar](255) NOT NULL
	);

	declare @tbl_files table (
		[DBName] [nvarchar](255) NOT NULL,
		[SourcePathRestore] [nvarchar](255) NOT NULL,
		[TargetPathRestore] [nvarchar](255) NOT NULL,
		[Ext] [nvarchar](255) NOT NULL
	);
	
	insert into @tbl (
	           [DBName]
	           ,[FullPathRestore]
	)
	select		[DBName]
	           ,[FullPathRestore]
	from [srv].[RestoreSettings];

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
	from [srv].[RestoreSettingsDetail];
	
	while(exists(select top(1) 1 from @tbl))
	begin
		set @backupSetId=NULL;

		select top(1)
		@DBName=[DBName],
		@pathBackup=[FullPathRestore]
		from @tbl;
	
		set @backupName=@DBName+N'_Full_backup_'+cast(@year as nvarchar(255))+N'_'+cast(@month as nvarchar(255))+N'_'+cast(@day as nvarchar(255))--+N'_'
						--+cast(@hour as nvarchar(255))+N'_'+cast(@minute as nvarchar(255))+N'_'+cast(@second as nvarchar(255));
		set @pathstr=@pathBackup+@backupName+N'.bak';

		set @sql=N'RESTORE DATABASE ['+@DBName+N'_Restore] FROM DISK = N'+N''''+@pathstr+N''''+
				 N' WITH FILE = 1,';

		while(exists(select top(1) 1 from @tbl_files where [DBName]=@DBName))
		begin
			select top(1)
			@SourcePathRestore=[SourcePathRestore],
			@TargetPathRestore=[TargetPathRestore],
			@Ext=[Ext]
			from @tbl_files
			where [DBName]=@DBName;

			set @sql=@sql+N' MOVE N'+N''''+@SourcePathRestore+N''''+N' TO N'+N''''+@TargetPathRestore+N'_Restore.'+@Ext+N''''+N',';

			delete from @tbl_files
			where [DBName]=@DBName
			and [SourcePathRestore]=@SourcePathRestore
			and [Ext]=@Ext;
		end

		set @sql=@sql+N' NOUNLOAD,  REPLACE,  STATS = 5';

		exec(@sql);

		set @sql=N'DBCC CHECKDB(N'+N''''+@DBName+'_Restore'+N''''+N')  WITH NO_INFOMSGS';
	
		exec(@sql);
		
		delete from @tbl
		where [DBName]=@DBName;
	end
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Восстановление из полной резервной копии БД с последующей проверкой на целостность самой БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'RunFullRestoreDB';

