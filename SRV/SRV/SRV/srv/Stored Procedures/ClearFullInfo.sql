-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[ClearFullInfo]
AS
BEGIN
	/*
		очищает все собранные данные
	*/
	SET NOCOUNT ON;

	--truncate table [srv].[BlockRequest];
	truncate table [srv].[DBFile];
	truncate table [srv].[ddl_log];
	truncate table [srv].[ddl_log_all];
	truncate table [srv].[Deadlocks];
	truncate table [srv].[Defrag];

	update [srv].[DefragRun]
	set [Run]=0;

    truncate table [srv].[ErrorInfo];
	truncate table [srv].[ErrorInfoArchive];
	truncate table [srv].[ListDefragIndex];

	truncate table [srv].[TableIndexStatistics];
	truncate table [srv].[TableStatistics];
	truncate table [srv].[RequestStatistics];
	truncate table [srv].[RequestStatisticsArchive];
	truncate table [srv].[QueryStatistics];
	truncate table [srv].[PlanQuery];
	truncate table [srv].[SQLQuery];
	truncate table [srv].[QueryRequestGroupStatistics];
	truncate table [srv].[ActiveConnectionStatistics];
	truncate table [srv].[ServerDBFileInfoStatistics];
	truncate table [srv].[ShortInfoRunJobs];

	truncate table [srv].[TSQL_DAY_Statistics];
	truncate table [srv].[IndicatorStatistics];
	truncate table [srv].[KillSession];
	truncate table [srv].[SessionTran];

	truncate table [srv].[WaitsStatistics];
	truncate table [srv].[BigQueryStatistics];
	truncate table [srv].[IndexDefragStatistics];
	truncate table [srv].[DefragServers];
	truncate table [srv].[ServerDBFileInfoStatistics];
	truncate table [srv].[IndexUsageStatsStatistics];
	truncate table [srv].[OldStatisticsStateStatistics];
	truncate table [srv].[NewIndexOptimizeStatistics];
	truncate table [srv].[StatisticsIOInTempDBStatistics];
	truncate table [srv].[DelIndexIncludeStatistics];
	truncate table [srv].[ShortInfoRunJobsServers];
	truncate table [srv].[ReadWriteTablesStatistics];
	truncate table [srv].[DiskSpaceStatistics];
	truncate table [srv].[RAMSpaceStatistics];

	truncate table [srv].[IndicatorServerDayStatistics];
	truncate table [srv].[DBFileStatistics];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Очистка всех собранных данных', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ClearFullInfo';

