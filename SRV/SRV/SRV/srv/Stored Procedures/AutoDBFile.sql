

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполняет сбор данных о всех файлах всех БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoDBFile';

