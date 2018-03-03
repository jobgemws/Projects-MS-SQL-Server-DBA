CREATE view [inf].[vIndexUsageStats] as
SELECT   SCHEMA_NAME(obj.schema_id) as [SCHEMA_NAME],
		 OBJECT_NAME(s.object_id) AS [OBJECT NAME], 
		 i.name AS [INDEX NAME], 
		 ([USER_SEEKS]+[USER_SCANS]+[USER_LOOKUPS])-([USER_UPDATES]+[System_Updates]) as [index_advantage],
         s.USER_SEEKS, 
         s.USER_SCANS, 
         s.USER_LOOKUPS, 
         s.USER_UPDATES,
		 s.Last_User_Seek,
		 s.Last_User_Scan,
		 s.Last_User_Lookup,
		 s.Last_User_Update,
		 s.System_Seeks,
		 s.System_Scans,
		 s.System_Lookups,
		 s.System_Updates,
		 s.Last_System_Seek,
		 s.Last_System_Scan,
		 s.Last_System_Lookup,
		 s.Last_System_Update,
		 obj.schema_id,
		 i.object_id,
		 i.index_id,
		 obj.[type] as [ObjectType],
		 obj.[type_desc] as TYPE_DESC_OBJECT,
		 i.[type] as [IndexType],
		 i.[type_desc] as TYPE_DESC_INDEX,
		 i.Is_Unique,
		 i.Data_Space_ID,
		 i.[Ignore_Dup_Key],
		 i.Is_Primary_Key,
		 i.Is_Unique_Constraint,
		 i.Fill_Factor,
		 i.Is_Padded,
		 i.Is_Disabled,
		 i.Is_Hypothetical,
		 i.[Allow_Row_Locks],
		 i.[Allow_Page_Locks],
		 i.Has_Filter,
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
FROM     sys.dm_db_index_usage_stats AS s 
         INNER JOIN sys.indexes AS i 
           ON i.object_id = s.object_id 
              AND i.index_id = s.index_id
		 inner join sys.objects as obj on obj.object_id=i.object_id
--WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Использование индексов', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vIndexUsageStats';

