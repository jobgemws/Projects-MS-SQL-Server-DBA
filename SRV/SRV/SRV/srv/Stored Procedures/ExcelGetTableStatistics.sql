CREATE PROCEDURE [srv].[ExcelGetTableStatistics]
as
begin
	/*
		возвращает информацию по таблицам
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	
	SELECT [ServerName]
      ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,[MinCountRows]
      ,[MaxCountRows]
      ,[AvgCountRows]
      ,[AbsDiffCountRows]
      ,[MinDataKB]
      ,[MaxDataKB]
      ,[AvgDataKB]
      ,[AbsDiffDataKB]
      ,[MinIndexSizeKB]
      ,[MaxIndexSizeKB]
      ,[AvgIndexSizeKB]
      ,[AbsDiffIndexSizeKB]
      ,[MinUnusedKB]
      ,[MaxUnusedKB]
      ,[AvgUnusedKB]
      ,[AbsDiffUnusedKB]
      ,[MinReservedKB]
      ,[MaxReservedKB]
      ,[AvgReservedKB]
      ,[AbsDiffReservedKB]
      ,[CountRowsStatistic]
      ,[StartInsertUTCDate]
      ,[FinishInsertUTCDate]
  FROM [srv].[vTableStatistics];
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по таблицам', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetTableStatistics';

