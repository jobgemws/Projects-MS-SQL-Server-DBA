


CREATE PROCEDURE [srv].[AutoAllDBForDurabilityForced]
AS
BEGIN
	/*
		перевод всех несистемных БД в режим полностью отложенных транзакций (неустойчивых)
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @sql nvarchar(max);
	declare @db nvarchar(255);
	
	select [name]
	into #tbl_db
	from sys.databases
	where [source_database_id] is null
	  and [database_id]>4
	  and [state]=0
	  and [is_read_only]=0
	  and [delayed_durability]<>2;
	
	DECLARE sql_cursor CURSOR LOCAL FOR
	select [name]
	from #tbl_db;
		
	OPEN sql_cursor;
		  
	FETCH NEXT FROM sql_cursor   
	INTO @db;
	
	while (@@FETCH_STATUS = 0 )
	begin
		select @sql='ALTER DATABASE ['+@db+'] SET DELAYED_DURABILITY = FORCED WITH NO_WAIT';
	
		print @sql
	
		exec sp_executesql @sql;
		
		FETCH NEXT FROM sql_cursor
			INTO @db;
	end
	
	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
	
	drop table #tbl_db;
END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполняет перевод всех несистемных БД в режим полностью отложенных транзакций (неустойчивых)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoAllDBForDurabilityForced';

