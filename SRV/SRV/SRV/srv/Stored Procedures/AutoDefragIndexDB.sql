
CREATE PROCEDURE [srv].[AutoDefragIndexDB]
	@DB nvarchar(255)=NULL, --по конкретной БД или по всем
	@count int=NULL, --кол-во индексов для рассмотрения в каждой БД
	@IsTempdb bit=0 --включать ли БД tempdb
AS
BEGIN
	/*
		вызов оптимизации индексов для заданной БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;

	declare @db_name nvarchar(255);
	declare @sql nvarchar(max);
	declare @ParmDefinition nvarchar(255)= N'@count int';

	truncate table [SRV].[srv].[ListDefragIndex];
	
	if(@DB is null)
	begin
		select [name]
		into #tbls
		from sys.databases
		where [is_read_only]=0
		and [state]=0 --ONLINE
		and [user_access]=0--MULTI_USER
		and (((@IsTempdb=0 or @IsTempdb is null) and [name]<>N'tempdb') or (@IsTempdb=1));

		while(exists(select top(1) 1 from #tbls))
		begin
			select top(1)
			@db_name=[name]
			from #tbls;

			set @sql=N'USE ['+@db_name+']; '+
			N'IF(object_id('+N''''+N'[srv].[AutoDefragIndex]'+N''''+N') is not null) EXEC [srv].[AutoDefragIndex] @count=@count;';

			exec sp_executesql @sql, @ParmDefinition, @count=@count;

			delete from #tbls
			where [name]=@db_name;
		end

		drop table #tbls;
	end
	else
	begin
		set @sql=N'USE ['+@DB+']; '+
			N'IF(object_id('+N''''+N'[srv].[AutoDefragIndex]'+N''''+N') is not null) EXEC [srv].[AutoDefragIndex] @count=@count;';

		exec sp_executesql @sql, @ParmDefinition, @count=@count;
	end
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вызов оптимизации индексов для заданной БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoDefragIndexDB';

