CREATE PROCEDURE [srv].[DropSessionLocalTempTables]
	@table_name NVARCHAR(255) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @tbl_name NVARCHAR(255);
	DECLARE @object_id INT;
	DECLARE @tsql NVARCHAR(2000);
	
	DECLARE sql_cursor CURSOR LOCAL FOR
	SELECT [t].[name], [t].[object_id]
	FROM [tempdb].[sys].[tables] as [t] WITH (READUNCOMMITTED)
	WHERE [t].[name] LIKE '#[^#]%'
	AND OBJECT_ID(N'tempdb..' + QUOTENAME([t].[name])) IS NOT NULL
	AND [t].[type] = 'U'
	AND (([t].[object_id] = object_id(N'tempdb..' + @table_name)) OR(@table_name IS NULL));
		
	OPEN sql_cursor;
			  
	FETCH NEXT FROM sql_cursor   
	INTO @tbl_name,
	     @object_id;
		
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	  SET @tsql=N'DROP TABLE '+QUOTENAME(@tbl_name);
	
	  EXEC [sys].[sp_executesql] @tsql;
	
	  FETCH NEXT FROM sql_cursor   
	  INTO @tbl_name,
	       @object_id;
	END
	
	CLOSE sql_cursor;
	DEALLOCATE sql_cursor;
END
GO

