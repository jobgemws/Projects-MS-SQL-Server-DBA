
CREATE PROCEDURE [srv].[AutoCHECKDB]
	@data_base nvarchar(max)=NULL --все БД или заданная
AS
BEGIN
	/*
		Проверка целостности данных БД
		https://www.sqlservercentral.com/blogs/run-dbcc-checkdb-on-a-regular-basis
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @dbName nvarchar(255);

	DECLARE @sqlCommand nvarchar(max);
	DECLARE @errorMsg	nvarchar(max);
	DECLARE @Return		int;
	
	DECLARE myCursor CURSOR FAST_FORWARD FOR 
	SELECT a.[name] AS LogicalName
	from SYS.databases as a
	WHERE (a.[name]=@data_base)
	   OR (@data_base IS NULL)
	--WHERE a.database_id > 4 --Only User DB 
	ORDER BY name DESC;
	
	OPEN myCursor;
	  
	FETCH NEXT FROM myCursor INTO @dbName;
	
	WHILE (@@FETCH_STATUS <> -1) 
	BEGIN
		SET @errorMsg = 'DB ['+@dbName+'] is corrupt'
		SET @sqlCommand = 'Use ['+@dbName+']'
	
		SET @sqlCommand += 'DBCC CHECKDB (['+@dbName +']) WITH PHYSICAL_ONLY,NO_INFOMSGS, ALL_ERRORMSGS';
	
		EXEC @Return = sp_executesql @sqlCommand;
	
		IF @Return <> 0 RAISERROR (@errorMsg , 11, 1);
	
		FETCH NEXT FROM myCursor INTO @dbName;
	END
	
	CLOSE myCursor;
	DEALLOCATE myCursor;
END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполняет проверку целостности данных БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoCHECKDB';

