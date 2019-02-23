
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoNewIndexOptimizeStatistics]
AS
BEGIN
	/*
		Сбор данных по недостающим индексам MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

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
           ,[SecondsUptime])
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
	FROM [inf].[vNewIndexOptimize];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных по недостающим индексам MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoNewIndexOptimizeStatistics';

