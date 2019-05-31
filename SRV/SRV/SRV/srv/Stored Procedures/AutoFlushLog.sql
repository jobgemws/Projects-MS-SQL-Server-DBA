
CREATE PROCEDURE [srv].[AutoFlushLog]
AS
BEGIN
	/*
		фиксация всех отложенных транзакций всех БД экземпляра MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @db nvarchar(255);
	declare @sql nvarchar(max);

	select [name]
	into #tbl
	from sys.databases
	where [delayed_durability]<>0;
	
	DECLARE sql_cursor CURSOR LOCAL FOR
	select [name]
	from #tbl;
	
	OPEN sql_cursor;
	  
	FETCH NEXT FROM sql_cursor   
	INTO @db;
	
	while (@@FETCH_STATUS = 0 )
	begin
		set @sql='EXEC ['+@db+'].[sys].[sp_flush_log];';
		
		begin try
			exec sp_executesql @sql;
		end try
		begin catch
		end catch
	
		FETCH NEXT FROM sql_cursor
		INTO @db;
	end
	
	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
	
	drop table #tbl;
END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фиксирует все отложенные транзакции всех БД экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoFlushLog';

