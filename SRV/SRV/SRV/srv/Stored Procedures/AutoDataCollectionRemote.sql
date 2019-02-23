

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoDataCollectionRemote]
AS
BEGIN
	/*
		Сбор данных с удаленных серверов
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @sql nvarchar(max);
	declare @server sysname;
	declare @dt0 datetime=GetUTCDate();
	declare @dt datetime=DateAdd(hour, -16, @dt0);

	select [name]
	into #tbl
	from sys.servers
	where [is_system]=0
	  and [is_linked]=1;

	while(exists(select top(1) 1 from #tbl))
	begin
		select top(1)
		@server=[name]
		from #tbl;

		set @sql=N'
		if(exists(select top(1) 1 from ['+@server+N'].master.sys.databases where [name]=''SRV''))
		begin
			INSERT INTO [srv].[WaitsStatistics]
				   ([Server]
				   ,[WaitType]
				   ,[Wait_S]
				   ,[Resource_S]
				   ,[Signal_S]
				   ,[WaitCount]
				   ,[Percentage]
				   ,[AvgWait_S]
				   ,[AvgRes_S]
				   ,[AvgSig_S]
				   ,[InsertUTCDate])
			SELECT  [Server]
				   ,[WaitType]
				   ,[Wait_S]
				   ,[Resource_S]
				   ,[Signal_S]
				   ,[WaitCount]
				   ,[Percentage]
				   ,[AvgWait_S]
				   ,[AvgRes_S]
				   ,[AvgSig_S]
				   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[WaitsStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

			INSERT INTO [srv].[ReadWriteTablesStatistics]
			   ([ServerName]
			   ,[DBName]
			   ,[SchemaTableName]
			   ,[TableName]
			   ,[Reads]
			   ,[Writes]
			   ,[Reads&Writes]
			   ,[SampleDays]
			   ,[SampleSeconds]
			   ,[InsertUTCDate])
			SELECT [ServerName]
			   ,[DBName]
			   ,[SchemaTableName]
			   ,[TableName]
			   ,[Reads]
			   ,[Writes]
			   ,[Reads&Writes]
			   ,[SampleDays]
			   ,[SampleSeconds]
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[ReadWriteTablesStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

			INSERT INTO [srv].[OldStatisticsStateStatistics]
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
			   ,[has_filter]
			   ,[InsertUTCDate])
			SELECT [Server]
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
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[OldStatisticsStateStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
		end';

		exec sp_executesql @sql;

		set @sql=N'
		if(exists(select top(1) 1 from ['+@server+N'].master.sys.databases where [name]=''SRV''))
		begin
			INSERT INTO [srv].[NewIndexOptimizeStatistics]
			   ([ServerName]
			   ,[DBName]
			   ,[Schema]
			   ,[Name]
			   ,[index_advantage]
			   ,[group_handle]
			   ,[unique_compiles]
			   ,[last_user_seek]
			   ,[last_user_scan]
			   ,[avg_total_user_cost]
			   ,[avg_user_impact]
			   ,[system_seeks]
			   ,[last_system_scan]
			   ,[last_system_seek]
			   ,[avg_total_system_cost]
			   ,[avg_system_impact]
			   ,[index_group_handle]
			   ,[index_handle]
			   ,[database_id]
			   ,[object_id]
			   ,[equality_columns]
			   ,[inequality_columns]
			   ,[statement]
			   ,[K]
			   ,[Keys]
			   ,[include]
			   ,[sql_statement]
			   ,[user_seeks]
			   ,[user_scans]
			   ,[est_impact]
			   ,[SecondsUptime]
			   ,[InsertUTCDate])
			SELECT [ServerName]
			   ,[DBName]
			   ,[Schema]
			   ,[Name]
			   ,[index_advantage]
			   ,[group_handle]
			   ,[unique_compiles]
			   ,[last_user_seek]
			   ,[last_user_scan]
			   ,[avg_total_user_cost]
			   ,[avg_user_impact]
			   ,[system_seeks]
			   ,[last_system_scan]
			   ,[last_system_seek]
			   ,[avg_total_system_cost]
			   ,[avg_system_impact]
			   ,[index_group_handle]
			   ,[index_handle]
			   ,[database_id]
			   ,[object_id]
			   ,[equality_columns]
			   ,[inequality_columns]
			   ,[statement]
			   ,[K]
			   ,[Keys]
			   ,[include]
			   ,[sql_statement]
			   ,[user_seeks]
			   ,[user_scans]
			   ,[est_impact]
			   ,[SecondsUptime]
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[NewIndexOptimizeStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

			INSERT INTO [srv].[IndicatorServerDayStatistics]
			   ([Server]
			   ,[ExecutionCount]
			   ,[AvgDur]
			   ,[AvgCPUTime]
			   ,[AvgIOLogicalReads]
			   ,[AvgIOLogicalWrites]
			   ,[AvgIOPhysicalReads]
			   ,[DATE])
			SELECT [Server]
			   ,[ExecutionCount]
			   ,[AvgDur]
			   ,[AvgCPUTime]
			   ,[AvgIOLogicalReads]
			   ,[AvgIOLogicalWrites]
			   ,[AvgIOPhysicalReads]
			   ,[DATE]
			FROM ['+@server+N'].[SRV].[srv].[IndicatorServerDayStatistics]
			WHERE [DATE]>='''+cast(cast(DateAdd(day,-1,@dt) as date) as nvarchar(255))+N''';
		end';

		exec sp_executesql @sql;

		set @sql=N'
		if(exists(select top(1) 1 from ['+@server+N'].master.sys.databases where [name]=''SRV''))
		begin
			INSERT INTO [srv].[IndexUsageStatsStatistics]
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
			   ,[IncludeColumns]
			   ,[InsertUTCDate])
			SELECT [SERVER]
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
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[IndexUsageStatsStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

			INSERT INTO [srv].[IndexDefragStatistics]
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
			   ,[func]
			   ,[InsertUTCDate])
			SELECT [Server]
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
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[IndexDefragStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
		end';

		exec sp_executesql @sql;

		set @sql=N'
		if(exists(select top(1) 1 from ['+@server+N'].master.sys.databases where [name]=''SRV''))
		begin
			INSERT INTO [srv].[DelIndexIncludeStatistics]
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
			   ,[ActualIndexName]
			   ,[InsertUTCDate])
			SELECT [Server]
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
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[DelIndexIncludeStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
		end';

		exec sp_executesql @sql;

		set @sql=N'
		if(exists(select top(1) 1 from ['+@server+N'].master.sys.databases where [name]=''SRV''))
		begin
			INSERT INTO [srv].[BigQueryStatistics]
			   ([Server]
			   ,[creation_time]
			   ,[last_execution_time]
			   ,[execution_count]
			   ,[CPU]
			   ,[AvgCPUTime]
			   ,[TotDuration]
			   ,[AvgDur]
			   ,[AvgIOLogicalReads]
			   ,[AvgIOLogicalWrites]
			   ,[AggIO]
			   ,[AvgIO]
			   ,[AvgIOPhysicalReads]
			   ,[plan_generation_num]
			   ,[AvgRows]
			   ,[AvgDop]
			   ,[AvgGrantKb]
			   ,[AvgUsedGrantKb]
			   ,[AvgIdealGrantKb]
			   ,[AvgReservedThreads]
			   ,[AvgUsedThreads]
			   ,[query_text]
			   ,[database_name]
			   ,[object_name]
			   ,[query_plan]
			   ,[sql_handle]
			   ,[plan_handle]
			   ,[query_hash]
			   ,[query_plan_hash]
			   ,[InsertUTCDate])
			SELECT [Server]
			   ,[creation_time]
			   ,[last_execution_time]
			   ,[execution_count]
			   ,[CPU]
			   ,[AvgCPUTime]
			   ,[TotDuration]
			   ,[AvgDur]
			   ,[AvgIOLogicalReads]
			   ,[AvgIOLogicalWrites]
			   ,[AggIO]
			   ,[AvgIO]
			   ,[AvgIOPhysicalReads]
			   ,[plan_generation_num]
			   ,[AvgRows]
			   ,[AvgDop]
			   ,[AvgGrantKb]
			   ,[AvgUsedGrantKb]
			   ,[AvgIdealGrantKb]
			   ,[AvgReservedThreads]
			   ,[AvgUsedThreads]
			   ,[query_text]
			   ,[database_name]
			   ,[object_name]
			   ,cast([query_plan] as XML)
			   ,[sql_handle]
			   ,[plan_handle]
			   ,[query_hash]
			   ,[query_plan_hash]
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[vBigQueryStatisticsRemote]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
		end';

		exec sp_executesql @sql;

		set @sql=N'
		if(exists(select top(1) 1 from ['+@server+N'].master.sys.databases where [name]=''SRV''))
		begin
			INSERT INTO [srv].[TableStatistics]
			   ([ServerName]
			   ,[DBName]
			   ,[SchemaName]
			   ,[TableName]
			   ,[CountRows]
			   ,[DataKB]
			   ,[IndexSizeKB]
			   ,[UnusedKB]
			   ,[ReservedKB]
			   ,[InsertUTCDate]
			   ,[CountRowsBack]
			   ,[CountRowsNext]
			   ,[DataKBBack]
			   ,[DataKBNext]
			   ,[IndexSizeKBBack]
			   ,[IndexSizeKBNext]
			   ,[UnusedKBBack]
			   ,[UnusedKBNext]
			   ,[ReservedKBBack]
			   ,[ReservedKBNext]
			   ,[TotalPageSizeKB]
			   ,[TotalPageSizeKBBack]
			   ,[TotalPageSizeKBNext]
			   ,[UsedPageSizeKB]
			   ,[UsedPageSizeKBBack]
			   ,[UsedPageSizeKBNext]
			   ,[DataPageSizeKB]
			   ,[DataPageSizeKBBack]
			   ,[DataPageSizeKBNext])
			SELECT [ServerName]
			   ,[DBName]
			   ,[SchemaName]
			   ,[TableName]
			   ,[CountRows]
			   ,[DataKB]
			   ,[IndexSizeKB]
			   ,[UnusedKB]
			   ,[ReservedKB]
			   ,[InsertUTCDate]
			   ,[CountRowsBack]
			   ,[CountRowsNext]
			   ,[DataKBBack]
			   ,[DataKBNext]
			   ,[IndexSizeKBBack]
			   ,[IndexSizeKBNext]
			   ,[UnusedKBBack]
			   ,[UnusedKBNext]
			   ,[ReservedKBBack]
			   ,[ReservedKBNext]
			   ,[TotalPageSizeKB]
			   ,[TotalPageSizeKBBack]
			   ,[TotalPageSizeKBNext]
			   ,[UsedPageSizeKB]
			   ,[UsedPageSizeKBBack]
			   ,[UsedPageSizeKBNext]
			   ,[DataPageSizeKB]
			   ,[DataPageSizeKBBack]
			   ,[DataPageSizeKBNext]
			FROM ['+@server+N'].[SRV].[srv].[TableStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

			INSERT INTO [srv].[TableIndexStatistics]
			   ([ServerName]
			   ,[DBName]
			   ,[SchemaName]
			   ,[TableName]
			   ,[IndexUsedForCounts]
			   ,[CountRows]
			   ,[InsertUTCDate])
			SELECT [ServerName]
			   ,[DBName]
			   ,[SchemaName]
			   ,[TableName]
			   ,[IndexUsedForCounts]
			   ,[CountRows]
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[TableIndexStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
		end';

		exec sp_executesql @sql;

		set @sql=N'
		if(exists(select top(1) 1 from ['+@server+N'].master.sys.databases where [name]=''SRV''))
		begin
			INSERT INTO [srv].[ServerDBFileInfoStatistics]
			   ([ServerName]
			   ,[DBName]
			   ,[File_id]
			   ,[Type_desc]
			   ,[FileName]
			   ,[Drive]
			   ,[Ext]
			   ,[CountPage]
			   ,[SizeMb]
			   ,[SizeGb]
			   ,[InsertUTCDate])
			SELECT [ServerName]
			   ,[DBName]
			   ,[File_id]
			   ,[Type_desc]
			   ,[FileName]
			   ,[Drive]
			   ,[Ext]
			   ,[CountPage]
			   ,[SizeMb]
			   ,[SizeGb]
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[ServerDBFileInfoStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

			INSERT INTO [srv].[DefragServers]
			   ([Server]
			   ,[db]
			   ,[shema]
			   ,[table]
			   ,[IndexName]
			   ,[frag_num]
			   ,[frag]
			   ,[page]
			   ,[rec]
			   ,[ts]
			   ,[tf]
			   ,[frag_after]
			   ,[object_id]
			   ,[idx]
			   ,[InsertUTCDate])
			SELECT '''+@server+N''' AS [Server]
			   ,[db]
			   ,[shema]
			   ,[table]
			   ,[IndexName]
			   ,[frag_num]
			   ,[frag]
			   ,[page]
			   ,[rec]
			   ,[ts]
			   ,[tf]
			   ,[frag_after]
			   ,[object_id]
			   ,[idx]
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[Defrag]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
		end';

		exec sp_executesql @sql;

		set @sql=N'
		if(exists(select top(1) 1 from ['+@server+N'].master.sys.databases where [name]=''SRV''))
		begin
			INSERT INTO [srv].[ShortInfoRunJobsServers]
			   ([Job_GUID]
			   ,[Job_Name]
			   ,[LastFinishRunState]
			   ,[LastRunDurationString]
			   ,[LastRunDurationInt]
			   ,[LastOutcomeMessage]
			   ,[LastRunOutcome]
			   ,[Server]
			   ,[InsertUTCDate]
			   ,[TargetServer]
			   ,[LastDateTime])
			SELECT [Job_GUID]
			   ,[Job_Name]
			   ,[LastFinishRunState]
			   ,[LastRunDurationString]
			   ,[LastRunDurationInt]
			   ,[LastOutcomeMessage]
			   ,[LastRunOutcome]
			   ,[Server]
			   ,[InsertUTCDate]
			   ,[TargetServer]
			   ,[LastDateTime]
			FROM ['+@server+N'].[SRV].[srv].[ShortInfoRunJobsServers]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';

			INSERT INTO [srv].[StatisticsIOInTempDBStatistics]
			   ([Server]
			   ,[physical_name]
			   ,[name]
			   ,[num_of_writes]
			   ,[avg_write_stall_ms]
			   ,[num_of_reads]
			   ,[avg_read_stall_ms]
			   ,[InsertUTCDate])
			SELECT [Server]
			   ,[physical_name]
			   ,[name]
			   ,[num_of_writes]
			   ,[avg_write_stall_ms]
			   ,[num_of_reads]
			   ,[avg_read_stall_ms]
			   ,[InsertUTCDate]
			FROM ['+@server+N'].[SRV].[srv].[StatisticsIOInTempDBStatistics]
			WHERE [InsertUTCDate]>='''+cast(@dt as nvarchar(255))+N'''
			  AND [InsertUTCDate]<='''+cast(@dt0 as nvarchar(255))+N''';
		end';

		exec sp_executesql @sql;

		delete from #tbl
		where [name]=@server;
	end

	drop table #tbl;

	INSERT INTO [srv].[DefragServers]
			   ([Server]
			   ,[db]
			   ,[shema]
			   ,[table]
			   ,[IndexName]
			   ,[frag_num]
			   ,[frag]
			   ,[page]
			   ,[rec]
			   ,[ts]
			   ,[tf]
			   ,[frag_after]
			   ,[object_id]
			   ,[idx]
			   ,[InsertUTCDate])
		SELECT @@SERVERNAME AS [Server]
			   ,[db]
			   ,[shema]
			   ,[table]
			   ,[IndexName]
			   ,[frag_num]
			   ,[frag]
			   ,[page]
			   ,[rec]
			   ,[ts]
			   ,[tf]
			   ,[frag_after]
			   ,[object_id]
			   ,[idx]
			   ,[InsertUTCDate]
			FROM [srv].[Defrag]
			WHERE [InsertUTCDate]>=@dt
			  AND [InsertUTCDate]<=@dt0;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных с удаленных серверов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoDataCollectionRemote';

