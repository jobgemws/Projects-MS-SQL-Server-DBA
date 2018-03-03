
CREATE PROCEDURE [srv].[ExcelGetDBFilesOperationsStat]
as
begin
	/*
		возвращает информацию по БД
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	
	SELECT @@SERVERNAME as [ServerName]
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
      ,[StateDesc]
      ,[IsMediaReadOnly]
      ,[IsReadOnly]
      ,[IsSpace]
      ,[IsNameReserved]
  FROM [inf].[vDBFilesOperationsStat];
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetDBFilesOperationsStat';

