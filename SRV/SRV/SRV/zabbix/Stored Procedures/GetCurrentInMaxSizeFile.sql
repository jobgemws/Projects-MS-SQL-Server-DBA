




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [zabbix].[GetCurrentInMaxSizeFile]
AS
BEGIN
	/*
		Текущий размер файла БД приблизился к максимально установленному значению
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	SELECT
		COUNT(*) AS [count]
	FROM sys.master_files
	WHERE [size] >= ([max_size] * 0.9)
	AND [max_size] > 0;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает количество файлов БД, текущие размеры которых приблизились к максимально установленным значениям', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetCurrentInMaxSizeFile';

