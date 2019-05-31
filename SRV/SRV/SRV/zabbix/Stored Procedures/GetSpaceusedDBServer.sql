




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetSpaceusedDBServer]
AS
BEGIN
	/*
		информация о занятом месте в БД (данные+индексы) в МБ
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;

	declare @db_name nvarchar(255);
	declare @sql nvarchar(max);
	declare @tbl table ([DBName] nvarchar(255), [DBSizeMB] decimal(18,3), [UnallocatedSpaceMB] decimal(18,3), [ReservedMB] decimal(18,3), [DataMB] decimal(18,3), [IndexSizeMB] decimal(18,3), [UnusedMB] decimal(18,3));

	select [name]
	into #tbls
	from sys.databases
	where [is_read_only]=0
	and [state]=0 --ONLINE
	and [user_access]=0--MULTI_USER
	and [database_id]>4;

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

	select SUM([DataMB]+[IndexSizeMB]) as [value]
	from @tbl;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию о занятом месте в БД (данные+индексы) в МБ', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetSpaceusedDBServer';

