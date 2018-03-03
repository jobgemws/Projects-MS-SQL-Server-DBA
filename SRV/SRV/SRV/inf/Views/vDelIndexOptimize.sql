CREATE view [inf].[vDelIndexOptimize] as
/*
	ГЕМ: возвращаются те индексы, которые не использовались в запросах более одного года
		 как пользователями, так и системой.
		 БД master, model, msdb и tempdb не рассматриваются
*/
select DB_NAME(t.database_id)		as [DBName]
	 , SCHEMA_NAME(obj.schema_id)	as [SchemaName]
	 , OBJECT_NAME(t.object_id)		as [ObjectName]
	 , obj.Type						as [ObjectType]
	 , obj.Type_Desc				as [ObjectTypeDesc]
	 , ind.name						as [IndexName]
	 , ind.Type						as IndexType
	 , ind.Type_Desc				as IndexTypeDesc
	 , ind.Is_Unique				as IndexIsUnique
	 , ind.is_primary_key			as IndexIsPK
	 , ind.is_unique_constraint		as IndexIsUniqueConstraint
	 , (t.[USER_SEEKS]+t.[USER_SCANS]+t.[USER_LOOKUPS]+t.[SYSTEM_SEEKS]+t.[SYSTEM_SCANS]+t.[SYSTEM_LOOKUPS])-(t.[USER_UPDATES]+t.[System_Updates]) as [index_advantage]
	 , t.[Database_ID]
	 , t.[Object_ID]
	 , t.[Index_ID]
	 , t.USER_SEEKS
     , t.USER_SCANS 
     , t.USER_LOOKUPS 
     , t.USER_UPDATES
	 , t.SYSTEM_SEEKS
     , t.SYSTEM_SCANS 
     , t.SYSTEM_LOOKUPS 
     , t.SYSTEM_UPDATES
	 , t.Last_User_Seek
	 , t.Last_User_Scan
	 , t.Last_User_Lookup
	 , t.Last_System_Seek
	 , t.Last_System_Scan
	 , t.Last_System_Lookup
	 , ind.Filter_Definition,
		STUFF(
				(
					SELECT N', [' + [name] +N'] '+case ic.[is_descending_key] when 0 then N'ASC' when 1 then N'DESC' end FROM sys.index_columns ic
								   INNER JOIN sys.columns c on c.[object_id] = obj.[object_id] and ic.[column_id] = c.[column_id]
					WHERE ic.[object_id] = obj.[object_id]
					  and ic.[index_id]=ind.[index_id]
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
					  and ic.[index_id]=ind.[index_id]
					  and ic.[is_included_column]=1
					order by ic.[key_ordinal] asc
					FOR XML PATH(''),TYPE
				).value('.','NVARCHAR(MAX)'),1,2,''
			  ) as [IncludeColumns]
from sys.dm_db_index_usage_stats as t
inner join sys.objects as obj on t.[object_id]=obj.[object_id]
inner join sys.indexes as ind on t.[object_id]=ind.[object_id] and t.index_id=ind.index_id
where ((last_user_seek	is null or last_user_seek		<dateadd(year,-1,getdate()))
and (last_user_scan		is null or last_user_scan		<dateadd(year,-1,getdate()))
and (last_user_lookup	is null or last_user_lookup		<dateadd(year,-1,getdate()))
and (last_system_seek	is null or last_system_seek		<dateadd(year,-1,getdate()))
and (last_system_scan	is null or last_system_scan		<dateadd(year,-1,getdate()))
and (last_system_lookup is null or last_system_lookup	<dateadd(year,-1,getdate()))
or (((t.[USER_UPDATES]+t.[System_Updates])>0) and (t.[SYSTEM_SEEKS]<=(t.[USER_UPDATES]+t.[System_Updates]-(t.[USER_SEEKS]+t.[USER_SCANS]+t.[USER_LOOKUPS]+t.[SYSTEM_SCANS]+t.[SYSTEM_LOOKUPS])))))
and t.database_id>4 and t.[object_id]>0
and ind.is_primary_key=0 --не является ограничением первичного ключа
and ind.is_unique_constraint=0 --не является ограничением уникальности
and t.database_id=DB_ID()

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Лишние индексы', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vDelIndexOptimize';

