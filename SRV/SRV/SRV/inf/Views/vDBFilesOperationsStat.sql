

CREATE view [inf].[vDBFilesOperationsStat]
as
select	t2.[DB_Name] as [DBName]
			,t1.FileId 
			,t1.NumberReads
			,t1.BytesRead
			,t1.IoStallReadMS
			,t1.NumberWrites
			,t1.BytesWritten
			,t1.IoStallWriteMS 
			,t1.IoStallMS
			,t1.BytesOnDisk
			,t1.[TimeStamp]
			,t1.FileHandle
			,t2.[Type_desc]
			,t2.[FileName]
			,t2.[Drive]
			,t2.[Physical_Name]
			,t2.[Ext]
			,t2.[CountPage]
			,t2.[SizeMb]
			,t2.[SizeGb]
			,t2.[Growth]
			,t2.[GrowthMb]
			,t2.[GrowthGb]
			,t2.[GrowthPercent]
			,t2.[is_percent_growth]
			,t2.[database_id]
			,t2.[State]
			,t2.[StateDesc]
			,t2.[IsMediaReadOnly]
			,t2.[IsReadOnly]
			,t2.[IsSpace]
			,t2.[IsNameReserved]
			,t2.[CreateLsn]
			,t2.[DropLsn]
			,t2.[ReadOnlyLsn]
			,t2.[ReadWriteLsn]
			,t2.[DifferentialBaseLsn]
			,t2.[DifferentialBaseGuid]
			,t2.[DifferentialBaseTime]
			,t2.[RedoStartLsn]
			,t2.[RedoStartForkGuid]
			,t2.[RedoTargetLsn]
			,t2.[RedoTargetForkGuid]
			,t2.[BackupLsn]
from fn_virtualfilestats(NULL, NULL) as t1
inner join [inf].[ServerDBFileInfo] as t2 on t1.[DbId]=t2.[database_id] and t1.[FileId]=t2.[File_Id]
--order by IoStallReadMS desc

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по операциям чтения-записи по всем файлам всех экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vDBFilesOperationsStat';

