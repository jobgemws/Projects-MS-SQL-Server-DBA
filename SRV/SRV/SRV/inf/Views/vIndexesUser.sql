CREATE view [inf].[vIndexesUser] as
-- Пользовательские индексы
SELECT  @@Servername AS ServerName ,
        DB_NAME() AS DB_Name ,
        obj.Name AS TableName ,
        i.Name AS IndexName ,
		i.Filter_Definition,
		STUFF(
				(
					SELECT N', [' + [name] +N'] '+case ic.[is_descending_key] when 0 then N'ASC' when 1 then N'DESC' end FROM sys.index_columns ic
								   INNER JOIN sys.columns c on c.[object_id] = obj.[object_id] and ic.[column_id] = c.[column_id]
					WHERE ic.[object_id] = obj.[object_id]
					  and ic.[index_id]=i.[index_id]
					  and ic.[is_included_column]=0
					order by ic.[key_ordinal] asc
					FOR XML PATH(''),TYPE
				).value('.','NVARCHAR(MAX)'),1,2,''
			  ) as [Columns],
		STUFF(
				(
					SELECT N', [' + [name] +N']' FROM sys.index_columns ic
								   INNER JOIN sys.columns c on c.[object_id] = obj.[object_id] and ic.[column_id] = c.[column_id]
					WHERE ic.[object_id] = obj.[object_id]
					  and ic.[index_id]=i.[index_id]
					  and ic.[is_included_column]=1
					order by ic.[key_ordinal] asc
					FOR XML PATH(''),TYPE
				).value('.','NVARCHAR(MAX)'),1,2,''
			  ) as [IncludeColumns]
FROM    sys.objects obj
        INNER JOIN sys.indexes i ON obj.[object_id] = i.[object_id]
WHERE   obj.[Type] = 'U' -- User table 
        AND LEFT(i.Name, 1) <> '_' -- Remove hypothetical indexes 
--ORDER BY o.NAME ,
--        i.name; 

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пользовательские индексы', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vIndexesUser';

