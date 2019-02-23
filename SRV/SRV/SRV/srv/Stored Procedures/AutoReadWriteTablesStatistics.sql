CREATE PROCEDURE [srv].[AutoReadWriteTablesStatistics]
AS
BEGIN
	/*
		Сбор данных по чтению/записи таблицы (кучи не рассматриваются, т к у них нет индексов).
		Только те таблицы, к которым обращались после запуска SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	INSERT INTO [srv].[ReadWriteTablesStatistics]
         ([ServerName]
         ,[DBName]
         ,[SchemaTableName]
         ,[TableName]
         ,[Reads]
         ,[Writes]
         ,[Reads&Writes]
         ,[SampleDays]
         ,[SampleSeconds])
	SELECT [ServerName]
         ,[DBName]
         ,[SchemaTableName]
         ,[TableName]
         ,[Reads]
         ,[Writes]
         ,[Reads&Writes]
         ,[SampleDays]
         ,[SampleSeconds]
	FROM [inf].[vReadWriteTables];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных по чтению/записи таблицы (кучи не рассматриваются, т к у них нет индексов).
		Только те таблицы, к которым обращались после запуска SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoReadWriteTablesStatistics';

