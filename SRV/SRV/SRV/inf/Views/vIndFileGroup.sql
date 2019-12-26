CREATE   VIEW [inf].[vIndFileGroup] AS
SELECT
	obj.[NAME] AS [parent_name]
   ,obj.[type] AS [parent_type]
   ,obj.[type_desc] AS [paretn_type_desc]
   ,SCHEMA_NAME(obj.[schema_id]) AS [schema_name]
   ,ind.[NAME] AS [index_name]
   ,ind.[index_id] AS [index_id]
   ,ind.[object_id] AS [parent_object_id]
   ,ind.[type_desc] AS [index_type_desc]
   ,f.[NAME] AS [filegroup_name]
   ,f.[data_space_id]
   ,f.[type] AS [filegroup_type]
   ,f.[type_desc] AS [filegroup_type_desc]
   ,f.[filegroup_guid]
   ,f.[is_read_only]
   ,f.[is_system]
   ,f.[is_default]
FROM sys.indexes AS ind
INNER JOIN sys.filegroups AS f
	ON ind.[data_space_id] = f.[data_space_id]
INNER JOIN sys.all_objects AS obj
	ON ind.[object_id] = obj.[object_id]
WHERE ind.[data_space_id] = f.[data_space_id]
--AND obj.[type] = 'U' -- User Created Tables
