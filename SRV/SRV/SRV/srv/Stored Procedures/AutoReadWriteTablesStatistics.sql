CREATE   PROCEDURE [srv].[AutoReadWriteTablesStatistics]
AS
BEGIN
	/*
		Сбор данных по чтению/записи таблицы (кучи не рассматриваются, т к у них нет индексов).
		Только те таблицы, к которым обращались после запуска SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @dt date=CAST(GetUTCDate() as date);
    declare @dbs nvarchar(255);
	declare @sql nvarchar(max);

	select [name]
	into #dbs3
	from [master].sys.databases;

	DECLARE sql_cursor CURSOR LOCAL FOR
	select [name]
	from #dbs3;
	
	OPEN sql_cursor;
	  
	FETCH NEXT FROM sql_cursor   
	INTO @dbs;

	while (@@FETCH_STATUS = 0 )
	begin
		set @sql=N'USE ['+@dbs+N'];
		if(exists(select top(1) 1 from sys.views where [name]=''vReadWriteTables'' and [schema_id]=schema_id(''inf'')))
		begin
			INSERT INTO [FortisAdmin].[srv].[ReadWriteTablesStatistics]
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
			FROM ['+@dbs+N'].[inf].[vReadWriteTables];
		end';

		exec sp_executesql @sql;

		FETCH NEXT FROM sql_cursor
		INTO @dbs;
	end

	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных по чтению/записи таблицы (кучи не рассматриваются, т к у них нет индексов).
		Только те таблицы, к которым обращались после запуска SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoReadWriteTablesStatistics';

