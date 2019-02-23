
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoStatisticsIOInTempDBStatistics]
AS
BEGIN
	/*
		Сбор данных по нагрузке на файлы данных БД tempdb MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	INSERT INTO [srv].[StatisticsIOInTempDBStatistics]
           ([Server]
           ,[physical_name]
           ,[name]
           ,[num_of_writes]
           ,[avg_write_stall_ms]
           ,[num_of_reads]
           ,[avg_read_stall_ms])
	SELECT @@SERVERNAME AS [ServerName]
		  ,[physical_name]
          ,[name]
          ,[num_of_writes]
          ,[avg_write_stall_ms]
          ,[num_of_reads]
          ,[avg_read_stall_ms]
	FROM [srv].[vStatisticsIOInTempDB];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных по нагрузке на файлы данных БД tempdb MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoStatisticsIOInTempDBStatistics';

