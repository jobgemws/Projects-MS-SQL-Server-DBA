-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoStatisticsFileDB]
AS
BEGIN
	/*
		Автосбор статистики роста файлов БД
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    INSERT INTO [SRV].[srv].[ServerDBFileInfoStatistics]
           ([ServerName]
		   ,[DBName]
           ,[File_id]
           ,[Type_desc]
           ,[FileName]
           ,[Drive]
           ,[Ext]
           ,[CountPage]
           ,[SizeMb]
           ,[SizeGb])
     SELECT [Server]
	  ,[DB_Name]
      ,[File_id]
      ,[Type_desc]
      ,[FileName]
      ,[Drive]
      ,[Ext]
      ,[CountPage]
      ,[SizeMb]
      ,[SizeGb]
	FROM [SRV].[inf].[ServerDBFileInfo];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Автосбор статистики роста файлов БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoStatisticsFileDB';

