
CREATE PROCEDURE [srv].[AutoShrinkLog]
	@max_size_mb int=16000 --при каком размере в МБ сжимать журнал транзакции БД
AS
BEGIN
	/*
		автосжатие журналов транзакций БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @sql nvarchar(max);
	declare @db nvarchar(255);
	declare @file nvarchar(255);
	
	select db.[name] as [db], mf.[name] as [file]
	into #files
	from [master].[sys].[databases] as db
	inner join [master].[sys].[master_files] as mf on db.[database_id]=mf.[database_id]
	where db.[is_read_only]=0				--WRITE
	and	  db.[state]=0						--ONLINE
	and	  db.[user_access]=0				--MULTI_USER
	and	  mf.[type]=1						--LOG
	and   mf.[state]=0						--ONLINE
	and	  mf.[size]>=@max_size_mb*1024/8	--SIZE FILE>=16 GB
	;
	
	DECLARE sql_cursor CURSOR LOCAL FOR
	select [db], [file]
	from #files;
	
	OPEN sql_cursor;
	  
	FETCH NEXT FROM sql_cursor   
	INTO @db, @file;
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		set @sql=N'USE ['+@db+N'];DBCC SHRINKFILE (N'''+@file+N''', '+cast(@max_size_mb as nvarchar(255))+N', TRUNCATEONLY);';

		begin try
		execute sp_executesql @sql;
		end try
		begin catch
		end catch
	
		FETCH NEXT FROM sql_cursor
		INTO @db, @file;
	END   
	
	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
	
	drop table #files;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполняет автосжатие журналов транзакций БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoShrinkLog';

