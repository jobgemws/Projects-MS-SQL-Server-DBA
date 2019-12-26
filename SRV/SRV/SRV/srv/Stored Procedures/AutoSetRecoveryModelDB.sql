

CREATE   PROCEDURE [srv].[AutoSetRecoveryModelDB]
	@recovery_model NVARCHAR(255)=N'SIMPLE'
AS
BEGIN
	/*
		автоперевод всех несистемных БД в указанную модель восстановления
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @sql NVARCHAR(max);
	DECLARE @server NVARCHAR(255);
	
	SELECT
		[name] INTO #tbl
	FROM sys.databases
	WHERE [database_id]>4
	  AND recovery_model_desc <> @recovery_model;
	
	DECLARE sql_cursor CURSOR LOCAL FOR SELECT
		[name]
	FROM #tbl;
	
	OPEN sql_cursor;
	
	FETCH NEXT FROM sql_cursor
	INTO @server;
	
	WHILE (@@fetch_status = 0)
	BEGIN
		SET @sql=N'ALTER DATABASE ['+@server+N'] SET RECOVERY '+@recovery_model+N' WITH NO_WAIT';
	
		exec sp_executesql @sql;
		
		FETCH NEXT FROM sql_cursor
		INTO @server;
	END
	
	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
	
	DROP TABLE #tbl;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполняет автоперевод всех несистемных БД в указанную модель восстановления', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoSetRecoveryModelDB';

