
CREATE PROCEDURE [srv].[ExcelGetDelIndexOptimize]
as
begin
	/*
		возвращает неиспользуемые индексы
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	
	SELECT @@SERVERNAME as [ServerName]
			,[DBName]
			,[SchemaName]
			,[ObjectName]
			,[ObjectType]
			,[ObjectTypeDesc]
			,[IndexName]
			,[IndexType]
			,[IndexTypeDesc]
			,[IndexIsUnique]
			,[IndexIsPK]
			,[IndexIsUniqueConstraint]
			,[Database_ID]
			,[Object_ID]
			,[Index_ID]
			,[Last_User_Seek]
			,[Last_User_Scan]
			,[Last_User_Lookup]
			,[Last_System_Seek]
			,[Last_System_Scan]
			,[Last_System_Lookup]
	  FROM [inf].[vDelIndexOptimize];
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает неиспользуемые индексы', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetDelIndexOptimize';

