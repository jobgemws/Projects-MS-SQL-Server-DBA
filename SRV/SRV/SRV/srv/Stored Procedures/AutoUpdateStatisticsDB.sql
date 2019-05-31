
CREATE PROCEDURE [srv].[AutoUpdateStatisticsDB]
	@DB nvarchar(255)=NULL, --по конкретной БД или по всем
	@ObjectSizeMB numeric (16,3) = NULL,
	--Максимальное кол-во строк в секции
	@row_count numeric (16,3) = NULL,
	@IsTempdb bit=0 --включать ли БД tempdb
AS
BEGIN
	/*
		вызов тонкой оптимизации статистики для заданной БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;

	declare @db_name nvarchar(255);
	declare @sql nvarchar(max);
	declare @ParmDefinition nvarchar(255)= N'@ObjectSizeMB numeric (16,3), @row_count numeric (16,3)';
	
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
			N'IF(object_id('+N''''+N'[srv].[AutoUpdateStatistics]'+N''''+N') is not null) EXEC [srv].[AutoUpdateStatistics] @ObjectSizeMB=@ObjectSizeMB, @row_count=@row_count;';

			exec sp_executesql @sql, @ParmDefinition, @ObjectSizeMB=@ObjectSizeMB, @row_count=@row_count;

			delete from #tbls
			where [name]=@db_name;
		end

		drop table #tbls;
	end
	else
	begin
		set @sql=N'USE ['+@DB+']; '+
		N'IF(object_id('+N''''+N'[srv].[AutoUpdateStatistics]'+N''''+N') is not null) EXEC [srv].[AutoUpdateStatistics] @ObjectSizeMB=@ObjectSizeMB, @row_count=@row_count;';

		exec sp_executesql @sql, @ParmDefinition, @ObjectSizeMB=@ObjectSizeMB, @row_count=@row_count;
	end
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполняет тонкое обновление статистики выбранной БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoUpdateStatisticsDB';

