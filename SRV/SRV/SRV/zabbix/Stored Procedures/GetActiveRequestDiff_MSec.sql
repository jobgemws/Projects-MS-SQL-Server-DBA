CREATE   PROCEDURE [zabbix].[GetActiveRequestDiff_MSec]
AS
BEGIN
	/*
		Максимальное время работы активных запросов в мсек по скульным входам кроме системных
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	;WITH tbl AS (
		SELECT [name]
		FROM srv.vLoginEnable
		WHERE [type_desc]=N'SQL_LOGIN'
		OR [name] IN (
			N'MONOPOLY\prd-c2wts',
			N'MONOPOLY\prd-spadmin',
			N'MONOPOLY\prd-spcontent',
			N'MONOPOLY\prd-spfarm',
			N'MONOPOLY\prd-spservices'
		)
	)
	SELECT COALESCE(MAX(DATEDIFF(MILLISECOND, ER.[start_time], GETDATE())), 0) AS Diff_MSec
	FROM tbl AS t
	INNER JOIN sys.dm_exec_sessions AS ES WITH(READUNCOMMITTED) ON ES.[login_name]=t.[name]
	INNER JOIN sys.dm_exec_requests AS ER WITH(READUNCOMMITTED) ON ES.session_id = ER.session_id
	WHERE ER.[start_time]>=0;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает максимальное время работы активных запросов в мсек по скульным входам кроме системных', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetActiveRequestDiff_MSec';

