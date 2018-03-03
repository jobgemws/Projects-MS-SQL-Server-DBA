
CREATE PROCEDURE [srv].[ExcelGetQueryRequestGroupStatistics]
as
begin
	/*
		возвращает сгруппированные все запросы
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	
	SELECT @@SERVERNAME as [ServerName]
	  ,[DBName]
      ,[Count]
      ,[mintotal_elapsed_timeSec]
      ,[maxtotal_elapsed_timeSec]
      ,[mincpu_timeSec]
      ,[maxcpu_timeSec]
      ,[minwait_timeSec]
      ,[maxwait_timeSec]
      ,[row_count]
      ,[SumCountRows]
      ,[min_reads]
      ,[max_reads]
      ,[min_writes]
      ,[max_writes]
      ,[min_logical_reads]
      ,[max_logical_reads]
      ,[min_open_transaction_count]
      ,[max_open_transaction_count]
      ,[min_transaction_isolation_level]
      ,[max_transaction_isolation_level]
      ,[Unique_nt_user_name]
      ,[Unique_nt_domain]
      ,[Unique_login_name]
      ,[Unique_program_name]
      ,[Unique_host_name]
      ,[Unique_client_tcp_port]
      ,[Unique_client_net_address]
      ,[Unique_client_interface_name]
      ,[InsertUTCDate]
	  ,[TSQL]
  FROM [srv].[vQueryRequestGroupStatistics];
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает сгруппированные все запросы', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetQueryRequestGroupStatistics';

