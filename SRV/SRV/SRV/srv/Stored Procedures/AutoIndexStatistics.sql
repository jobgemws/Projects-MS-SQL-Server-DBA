

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoIndexStatistics]
AS
BEGIN
	/*
		Сбор информацию по индексам и статистикам по всем помеченным БД экземпляра MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @dt date=CAST(GetUTCDate() as date);
    declare @dbs nvarchar(255);
	declare @sql nvarchar(max);

	--сбор фрагментации индексов
	select [name]
	into #dbs3
	from [master].sys.databases;

	while(exists(select top(1) 1 from #dbs3))
	begin
		select top(1)
		@dbs=[name]
		from #dbs3;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[inf].[vIndexDefrag]'+N''''+N') is not null) BEGIN '
		+N'insert into [SRV].[srv].[IndexDefragStatistics]
	         ([Server]
			 ,[db]
			 ,[shema]
			 ,[tb]
			 ,[idx]
			 ,[database_id]
			 ,[index_name]
			 ,[index_type_desc]
			 ,[level]
			 ,[object_id]
			 ,[frag_num]
			 ,[frag]
			 ,[frag_page]
			 ,[page]
			 ,[rec]
			 ,[ghost]
			 ,[func])
		SELECT @@SERVERNAME AS [Server]
		     ,[db]
			 ,[shema]
			 ,[tb]
			 ,[idx]
			 ,[database_id]
			 ,[index_name]
			 ,[index_type_desc]
			 ,[level]
			 ,[object_id]
			 ,[frag_num]
			 ,[frag]
			 ,[frag_page]
			 ,[page]
			 ,[rec]
			 ,[ghost]
			 ,[func]
		  FROM [inf].[vIndexDefrag]; END';

		exec sp_executesql @sql;

		delete from #dbs3
		where [name]=@dbs;
	end

	--сбор использования индексов
	select [name]
	into #dbs
	from sys.databases;

	while(exists(select top(1) 1 from #dbs))
	begin
		select top(1)
		@dbs=[name]
		from #dbs;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[inf].[vIndexUsageStats]'+N''''+N') is not null) BEGIN '
		+N'INSERT INTO [SRV].[srv].[IndexUsageStatsStatistics]
	         ([SERVER]
			,[SCHEMA_NAME]
			,[OBJECT NAME]
			,[INDEX NAME]
			,[index_advantage]
			,[USER_SEEKS]
			,[USER_SCANS]
			,[USER_LOOKUPS]
			,[USER_UPDATES]
			,[Last_User_Seek]
			,[Last_User_Scan]
			,[Last_User_Lookup]
			,[Last_User_Update]
			,[System_Seeks]
			,[System_Scans]
			,[System_Lookups]
			,[System_Updates]
			,[Last_System_Seek]
			,[Last_System_Scan]
			,[Last_System_Lookup]
			,[Last_System_Update]
			,[schema_id]
			,[object_id]
			,[index_id]
			,[ObjectType]
			,[TYPE_DESC_OBJECT]
			,[IndexType]
			,[TYPE_DESC_INDEX]
			,[Is_Unique]
			,[Data_Space_ID]
			,[Ignore_Dup_Key]
			,[Is_Primary_Key]
			,[Is_Unique_Constraint]
			,[Fill_Factor]
			,[Is_Padded]
			,[Is_Disabled]
			,[Is_Hypothetical]
			,[Allow_Row_Locks]
			,[Allow_Page_Locks]
			,[Has_Filter]
			,[Filter_Definition]
			,[Columns]
			,[IncludeColumns])
	   SELECT @@SERVERNAME AS [Server]
			,[SCHEMA_NAME]
			,[OBJECT NAME]
			,[INDEX NAME]
			,[index_advantage]
			,[USER_SEEKS]
			,[USER_SCANS]
			,[USER_LOOKUPS]
			,[USER_UPDATES]
			,[Last_User_Seek]
			,[Last_User_Scan]
			,[Last_User_Lookup]
			,[Last_User_Update]
			,[System_Seeks]
			,[System_Scans]
			,[System_Lookups]
			,[System_Updates]
			,[Last_System_Seek]
			,[Last_System_Scan]
			,[Last_System_Lookup]
			,[Last_System_Update]
			,[schema_id]
			,[object_id]
			,[index_id]
			,[ObjectType]
			,[TYPE_DESC_OBJECT]
			,[IndexType]
			,[TYPE_DESC_INDEX]
			,[Is_Unique]
			,[Data_Space_ID]
			,[Ignore_Dup_Key]
			,[Is_Primary_Key]
			,[Is_Unique_Constraint]
			,[Fill_Factor]
			,[Is_Padded]
			,[Is_Disabled]
			,[Is_Hypothetical]
			,[Allow_Row_Locks]
			,[Allow_Page_Locks]
			,[Has_Filter]
			,[Filter_Definition]
			,[Columns]
			,[IncludeColumns]
		FROM ['+@dbs+'].[inf].[vIndexUsageStats]; END';

		exec sp_executesql @sql;

		delete from #dbs
		where [name]=@dbs;
	end

	--сбор перекрывающихся индексов
	select [name]
	into #dbs4
	from sys.databases;

	while(exists(select top(1) 1 from #dbs4))
	begin
		select top(1)
		@dbs=[name]
		from #dbs4;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[srv].[vDelIndexInclude]'+N''''+N') is not null) BEGIN '
		+N'INSERT INTO [SRV].[srv].[DelIndexIncludeStatistics]
	         ([Server]
			,[SchemaName]
			,[ObjectName]
			,[ObjectType]
			,[ObjectCreateDate]
			,[DelIndexName]
			,[IndexIsPrimaryKey]
			,[IndexType]
			,[IndexFragmentation]
			,[IndexFragmentCount]
			,[IndexAvgFragmentSizeInPages]
			,[IndexPages]
			,[IndexKeyColumns]
			,[IndexIncludedColumns]
			,[ActualIndexName])
	   SELECT @@SERVERNAME AS [Server]
			,[SchemaName]
			,[ObjectName]
			,[ObjectType]
			,[ObjectCreateDate]
			,[DelIndexName]
			,[IndexIsPrimaryKey]
			,[IndexType]
			,[IndexFragmentation]
			,[IndexFragmentCount]
			,[IndexAvgFragmentSizeInPages]
			,[IndexPages]
			,[IndexKeyColumns]
			,[IndexIncludedColumns]
			,[ActualIndexName]
		FROM ['+@dbs+'].[srv].[vDelIndexInclude]; END';

		exec sp_executesql @sql;

		delete from #dbs4
		where [name]=@dbs;
	end

	--сбор устаревших статистик
	select [name]
	into #dbs5
	from sys.databases;

	while(exists(select top(1) 1 from #dbs5))
	begin
		select top(1)
		@dbs=[name]
		from #dbs5;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[inf].[vOldStatisticsState]'+N''''+N') is not null) BEGIN '
		+N'INSERT INTO [SRV].[srv].[OldStatisticsStateStatistics]
	         ([Server]
			,[object_id]
			,[SchemaName]
			,[ObjectName]
			,[stats_id]
			,[StatName]
			,[row_count]
			,[ProcModified]
			,[ObjectSizeMB]
			,[type_desc]
			,[create_date]
			,[last_updated]
			,[ModificationCounter]
			,[ProcSampled]
			,[Func]
			,[IsScanned]
			,[ColumnType]
			,[auto_created]
			,[IndexName]
			,[has_filter])
	   SELECT @@SERVERNAME AS [Server]
			,[object_id]
			,[SchemaName]
			,[ObjectName]
			,[stats_id]
			,[StatName]
			,[row_count]
			,[ProcModified]
			,[ObjectSizeMB]
			,[type_desc]
			,[create_date]
			,[last_updated]
			,[ModificationCounter]
			,[ProcSampled]
			,[Func]
			,[IsScanned]
			,[ColumnType]
			,[auto_created]
			,[IndexName]
			,[has_filter]
		FROM ['+@dbs+'].[inf].[vOldStatisticsState]; END';

		exec sp_executesql @sql;

		delete from #dbs5
		where [name]=@dbs;
	end

	drop table #dbs;
	drop table #dbs3;
	drop table #dbs4;
	drop table #dbs5;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор информацию по индексам и статистикам по всем помеченным БД экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoIndexStatistics';

