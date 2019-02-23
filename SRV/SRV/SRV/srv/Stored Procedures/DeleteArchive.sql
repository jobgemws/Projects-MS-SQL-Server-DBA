



CREATE PROCEDURE [srv].[DeleteArchive]
	@day int=14 -- кол-во дней, по которым определяется старость записи
AS
BEGIN
	/*
		удаление старых архивных записей из архивов
	*/
	SET NOCOUNT ON;

	while(exists(select top(1) 1 from [srv].[ErrorInfoArchive] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ErrorInfoArchive]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ddl_log_all] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ddl_log_all]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[Defrag] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[Defrag]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[TableIndexStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[TableIndexStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[TableStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[TableStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[RequestStatisticsArchive] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[RequestStatisticsArchive]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ActiveConnectionStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ActiveConnectionStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ServerDBFileInfoStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ServerDBFileInfoStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[KillSession] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[KillSession]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[WaitsStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[WaitsStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[BigQueryStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[BigQueryStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[IndexDefragStatistics]	where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[IndexDefragStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[DefragServers]	where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[DefragServers]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ServerDBFileInfoStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ServerDBFileInfoStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[IndexUsageStatsStatistics]	where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[IndexUsageStatsStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[OldStatisticsStateStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[OldStatisticsStateStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[NewIndexOptimizeStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[NewIndexOptimizeStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[StatisticsIOInTempDBStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[StatisticsIOInTempDBStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[DelIndexIncludeStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[DelIndexIncludeStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ShortInfoRunJobsServers] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ShortInfoRunJobsServers]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end

	while(exists(select top(1) 1 from [srv].[ReadWriteTablesStatistics] where InsertUTCDate<=dateadd(day,-@day,getUTCDate())))
	begin
		delete
		from [srv].[ReadWriteTablesStatistics]
		where InsertUTCDate<=dateadd(day,-@day,getUTCDate());
	end
END




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Удаление старых архивных записей из архивов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'DeleteArchive';

