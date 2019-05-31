




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetReadStallMSTempDB]
AS
BEGIN
	/*
		Максимальное из средних значений по задержке чтения на файлы БД TempDB в МС
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	SELECT max([avg_read_stall_ms]) as [valueMS]
	FROM [srv].[vStatisticsIOInTempDB];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает максимальное из средних значений по задержке чтения на файлы БД TempDB в МС', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetReadStallMSTempDB';

