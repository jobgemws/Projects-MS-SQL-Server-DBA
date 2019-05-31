

CREATE PROCEDURE [srv].[SpaceusedDBServer]
	@DB nvarchar(255)=NULL, --по конкретной БД или по всем
	@IsSystem bit=0 --включать ли системные БД
AS
BEGIN
	/*
		информация о распределении места в БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;

	declare @db_name nvarchar(255);
	declare @sql nvarchar(max);
	declare @tbl table ([DBName] nvarchar(255), [DBSizeMB] decimal(18,3), [UnallocatedSpaceMB] decimal(18,3), [ReservedMB] decimal(18,3), [DataMB] decimal(18,3), [IndexSizeMB] decimal(18,3), [UnusedMB] decimal(18,3));

	
	if(@DB is null)
	begin
		select [name]
		into #tbls
		from sys.databases
		where [is_read_only]=0
		and [state]=0 --ONLINE
		and [user_access]=0--MULTI_USER
		and (((@IsSystem=0 or @IsSystem is null) and [database_id]>4) or ([database_id] is not null));

		while(exists(select top(1) 1 from #tbls))
		begin
			select top(1)
			@db_name=[name]
			from #tbls;

			set @sql=N'USE ['+@db_name+']; '+
			N'IF(object_id('+N''''+N'[inf].[SpaceusedDB]'+N''''+N') is not null) select [DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB] from [inf].[SpaceusedDB]();';

			insert into @tbl([DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB])
			exec sp_executesql @sql;

			delete from #tbls
			where [name]=@db_name;
		end

		drop table #tbls;
	end
	else
	begin
		set @sql=N'USE ['+@DB+']; '+
			N'IF(object_id('+N''''+N'[inf].[SpaceusedDB]'+N''''+N') is not null) select [DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB] from [inf].[SpaceusedDB]();';

		insert into @tbl([DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB])
		exec sp_executesql @sql;
	end

	select [DBSizeMB],
		   [UnallocatedSpaceMB],
		   [ReservedMB],
		   [DataMB],
		   [IndexSizeMB],
		   [UnusedMB]
	from @tbl;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию о распределении места в БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'SpaceusedDBServer';

