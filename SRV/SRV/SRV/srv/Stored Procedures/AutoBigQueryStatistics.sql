
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoBigQueryStatistics]
AS
BEGIN
	/*
		Сбор данных по самым длительным запросам MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT @@SERVERNAME AS [Server]
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
	SELECT	@@SERVERNAME AS [Server],
			SUM([execution_count]),
			AVG([AvgDur]),
			AVG([AvgCPUTime]),
            AVG([AvgIOLogicalReads]),
            AVG([AvgIOLogicalWrites]),
            AVG([AvgIOPhysicalReads]),
			CAST(GETUTCDATE() AS DATE)
	FROM #tbl;

	DROP TABLE #tbl;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных по самым длительным запросам MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoBigQueryStatistics';

