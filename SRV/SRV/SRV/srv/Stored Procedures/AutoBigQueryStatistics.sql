

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [srv].[AutoBigQueryStatistics]
AS
BEGIN
	/*
		Сбор данных по самым длительным запросам MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

	SELECT @servername AS [Server]
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
			into #tbl
	 FROM [inf].[vBigQuery];

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
           ,[query_plan_hash])
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
           ,[query_plan]
           ,[sql_handle]
           ,[plan_handle]
           ,[query_hash]
           ,[query_plan_hash]
	 FROM #tbl;

	 --подсчет общего индикатора производительности по всему экземпляру MS SQL SERVER
	 INSERT INTO [srv].[IndicatorServerDayStatistics]
           ([Server]
           ,[ExecutionCount]
           ,[AvgDur]
           ,[AvgCPUTime]
           ,[AvgIOLogicalReads]
           ,[AvgIOLogicalWrites]
           ,[AvgIOPhysicalReads]
           ,[DATE])
	SELECT	@servername AS [Server],
			SUM([execution_count]),
			AVG([AvgDur]),
			AVG([AvgCPUTime]),
            AVG([AvgIOLogicalReads]),
            AVG([AvgIOLogicalWrites]),
            AVG([AvgIOPhysicalReads]),
			CAST(GETUTCDATE() AS DATE)
	FROM #tbl;

	--группируем по запросам за все время сбора
	truncate table [srv].[BigQueryGroupStatistics];

	INSERT INTO [srv].[BigQueryGroupStatistics]
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
	select [Server]
      ,max([creation_time])			as [creation_time]
      ,max([last_execution_time])	as [last_execution_time]
      ,sum([execution_count])		as [execution_count]
      ,max([CPU])					as [CPU]
      ,max([AvgCPUTime])			as [AvgCPUTime]
      ,max([TotDuration])			as [TotDuration]
      ,max([AvgDur])				as [AvgDur]
      ,max([AvgIOLogicalReads])		as [AvgIOLogicalReads]
      ,max([AvgIOLogicalWrites])	as [AvgIOLogicalWrites]
      ,max([AggIO])					as [AggIO]
      ,max([AvgIO])					as [AvgIO]
      ,max([AvgIOPhysicalReads])	as [AvgIOPhysicalReads]
      ,max([plan_generation_num])	as [plan_generation_num]
      ,max([AvgRows])				as [AvgRows]
      ,max([AvgDop])				as [AvgDop]
      ,max([AvgGrantKb])			as [AvgGrantKb]
      ,max([AvgUsedGrantKb])		as [AvgUsedGrantKb]
      ,max([AvgIdealGrantKb])		as [AvgIdealGrantKb]
      ,max([AvgReservedThreads])	as [AvgReservedThreads]
      ,max([AvgUsedThreads])		as [AvgUsedThreads]
      ,[query_text]
      ,max([database_name])			as [database_name]
      ,max([object_name])			as [object_name]
      ,cast(max(cast([query_plan] as nvarchar(max))) as XML) as [query_plan]
      ,max([sql_handle])			as [sql_handle]
      ,max([plan_handle])			as [plan_handle]
      ,max([query_hash])			as [query_hash]
      ,max([query_plan_hash])		as [query_plan_hash]
	  ,max([InsertUTCDate])			as [InsertUTCDate]
	from [srv].[BigQueryStatistics]
	group by [Server], [query_text];

	DROP TABLE #tbl;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных по самым длительным запросам MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoBigQueryStatistics';

