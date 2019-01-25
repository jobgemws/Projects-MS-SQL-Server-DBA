--ХП srv.AutoDefragIndex и srv.AutoUpdateStatistics отдельно, т к они содержат в себе динамический T-SQL, а вложенность динамических запросов запрещена
declare @str nvarchar(max);
declare @iscreated bit=0;

set @str=null;
if(not exists(select top(1) 1 from sys.schemas where [name]=N'inf'))
begin
	set @str='CREATE SCHEMA [inf];';
end

if(@str is not null)
begin
	exec sp_executesql @str;
end

if(not exists(select top(1) 1 from sys.schemas where [name]=N'srv'))
begin
	set @str='CREATE SCHEMA [srv];';
end

if(@str is not null)
begin
	exec sp_executesql @str;
end

set @str=null;
set @iscreated=0;
if(not exists(select top(1) 1 from sys.views where [name]=N'vTableSize' and [schema_id]=SCHEMA_ID(N'inf')))
begin
	set @iscreated=1;
	
	set @str='CREATE view [inf].[vTableSize] as
	with pagesizeKB as (
		SELECT low / 1024 as PageSizeKB
		FROM master.dbo.spt_values
		WHERE number = 1 AND type = ''E''
	)
	,f_size as (
		select p.[object_id], 
			   sum([total_pages]) as TotalPageSize,
			   sum([used_pages])  as UsedPageSize,
			   sum([data_pages])  as DataPageSize
		from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
		left join sys.internal_tables it on p.object_id = it.object_id
		WHERE OBJECTPROPERTY(p.[object_id], N''IsUserTable'') = 1
		group by p.[object_id]
	)
	,tbl as (
		SELECT
		  t.[schema_id],
		  t.[object_id],
		  i1.rowcnt as CountRows,
		  (COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0)) * (select top(1) PageSizeKB from pagesizeKB) as ReservedKB,
		  (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0)) * (select top(1) PageSizeKB from pagesizeKB) as DataKB,
		  ((COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))
		    - (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as IndexSizeKB,
		  ((COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0))
		    - (COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as UnusedKB
		FROM sys.tables as t
		LEFT OUTER JOIN sysindexes as i1 ON i1.id = t.[object_id] AND i1.indid < 2
		LEFT OUTER JOIN sysindexes as i2 ON i2.id = t.[object_id] AND i2.indid = 255
		WHERE OBJECTPROPERTY(t.[object_id], N''IsUserTable'') = 1
		OR (OBJECTPROPERTY(t.[object_id], N''IsView'') = 1 AND OBJECTPROPERTY(t.[object_id], N''IsIndexed'') = 1)
		GROUP BY t.[schema_id], t.[object_id], i1.rowcnt
	)
	SELECT
	  @@Servername AS Server,
	  DB_NAME() AS DBName,
	  SCHEMA_NAME(t.[schema_id]) as SchemaName,
	  OBJECT_NAME(t.[object_id]) as TableName,
	  t.CountRows,
	  t.ReservedKB,
	  t.DataKB,
	  t.IndexSizeKB,
	  t.UnusedKB,
	  f.TotalPageSize*(select top(1) PageSizeKB from pagesizeKB) as TotalPageSizeKB,
	  f.UsedPageSize*(select top(1) PageSizeKB from pagesizeKB) as UsedPageSizeKB,
	  f.DataPageSize*(select top(1) PageSizeKB from pagesizeKB) as DataPageSizeKB
	FROM f_size as f
	inner join tbl as t on t.[object_id]=f.[object_id]';
end
else
begin
	set @str='ALTER view [inf].[vTableSize] as
	with pagesizeKB as (
		SELECT low / 1024 as PageSizeKB
		FROM master.dbo.spt_values
		WHERE number = 1 AND type = ''E''
	)
	,f_size as (
		select p.[object_id], 
			   sum([total_pages]) as TotalPageSize,
			   sum([used_pages])  as UsedPageSize,
			   sum([data_pages])  as DataPageSize
		from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
		left join sys.internal_tables it on p.object_id = it.object_id
		WHERE OBJECTPROPERTY(p.[object_id], N''IsUserTable'') = 1
		group by p.[object_id]
	)
	,tbl as (
		SELECT
		  t.[schema_id],
		  t.[object_id],
		  i1.rowcnt as CountRows,
		  (COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0)) * (select top(1) PageSizeKB from pagesizeKB) as ReservedKB,
		  (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0)) * (select top(1) PageSizeKB from pagesizeKB) as DataKB,
		  ((COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))
		    - (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as IndexSizeKB,
		  ((COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0))
		    - (COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as UnusedKB
		FROM sys.tables as t
		LEFT OUTER JOIN sysindexes as i1 ON i1.id = t.[object_id] AND i1.indid < 2
		LEFT OUTER JOIN sysindexes as i2 ON i2.id = t.[object_id] AND i2.indid = 255
		WHERE OBJECTPROPERTY(t.[object_id], N''IsUserTable'') = 1
		OR (OBJECTPROPERTY(t.[object_id], N''IsView'') = 1 AND OBJECTPROPERTY(t.[object_id], N''IsIndexed'') = 1)
		GROUP BY t.[schema_id], t.[object_id], i1.rowcnt
	)
	SELECT
	  @@Servername AS Server,
	  DB_NAME() AS DBName,
	  SCHEMA_NAME(t.[schema_id]) as SchemaName,
	  OBJECT_NAME(t.[object_id]) as TableName,
	  t.CountRows,
	  t.ReservedKB,
	  t.DataKB,
	  t.IndexSizeKB,
	  t.UnusedKB,
	  f.TotalPageSize*(select top(1) PageSizeKB from pagesizeKB) as TotalPageSizeKB,
	  f.UsedPageSize*(select top(1) PageSizeKB from pagesizeKB) as UsedPageSizeKB,
	  f.DataPageSize*(select top(1) PageSizeKB from pagesizeKB) as DataPageSizeKB
	FROM f_size as f
	inner join tbl as t on t.[object_id]=f.[object_id]';
end

if(@str is not null)
begin
	exec sp_executesql @str;

	if(@iscreated=1)
	begin
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Размеры таблиц' , @level0type=N'SCHEMA',@level0name=N'inf', @level1type=N'VIEW',@level1name=N'vTableSize';
	end
end

set @str=null;
set @iscreated=0;
if(not exists(select top(1) 1 from sys.views where [name]=N'vIndexDefrag' and [schema_id]=SCHEMA_ID(N'inf')))
begin
	set @iscreated=1;

	set @str='CREATE view [inf].[vIndexDefrag]
	as
	with info as 
	(SELECT
		ps.[object_id],
		ps.database_id,
		ps.index_id,
		ps.index_type_desc,
		ps.index_level,
		ps.fragment_count,
		ps.avg_fragmentation_in_percent,
		ps.avg_fragment_size_in_pages,
		ps.page_count,
		ps.record_count,
		ps.ghost_record_count
		FROM sys.dm_db_index_physical_stats
	    (DB_ID()
		, NULL, NULL, NULL ,
		N''LIMITED'') as ps
		inner join sys.indexes as i on i.[object_id]=ps.[object_id] and i.[index_id]=ps.[index_id]
		where ps.index_level = 0
		and ps.avg_fragmentation_in_percent >= 10
		and ps.index_type_desc <> ''HEAP''
		and ps.page_count>=8 --1 экстент
		and i.is_disabled=0
		)
	SELECT
		DB_NAME(i.database_id) as db,
		SCHEMA_NAME(t.[schema_id]) as shema,
		t.name as tb,
		i.index_id as idx,
		i.database_id,
		(select top(1) idx.[name] from [sys].[indexes] as idx where t.[object_id] = idx.[object_id] and idx.[index_id] = i.[index_id]) as index_name,
		i.index_type_desc,i.index_level as [level],
		i.[object_id],
		i.fragment_count as frag_num,
		round(i.avg_fragmentation_in_percent,2) as frag,
		round(i.avg_fragment_size_in_pages,2) as frag_page,
		i.page_count as [page],
		i.record_count as rec,
		i.ghost_record_count as ghost,
		round(i.avg_fragmentation_in_percent*i.page_count,0) as func
	FROM info as i
	inner join [sys].[all_objects]	as t	on i.[object_id] = t.[object_id]';
end
else
begin
	set @str='ALTER view [inf].[vIndexDefrag]
	as
	with info as 
	(SELECT
		ps.[object_id],
		ps.database_id,
		ps.index_id,
		ps.index_type_desc,
		ps.index_level,
		ps.fragment_count,
		ps.avg_fragmentation_in_percent,
		ps.avg_fragment_size_in_pages,
		ps.page_count,
		ps.record_count,
		ps.ghost_record_count
		FROM sys.dm_db_index_physical_stats
	    (DB_ID()
		, NULL, NULL, NULL ,
		N''LIMITED'') as ps
		inner join sys.indexes as i on i.[object_id]=ps.[object_id] and i.[index_id]=ps.[index_id]
		where ps.index_level = 0
		and ps.avg_fragmentation_in_percent >= 10
		and ps.index_type_desc <> ''HEAP''
		and ps.page_count>=8 --1 экстент
		and i.is_disabled=0
		)
	SELECT
		DB_NAME(i.database_id) as db,
		SCHEMA_NAME(t.[schema_id]) as shema,
		t.name as tb,
		i.index_id as idx,
		i.database_id,
		(select top(1) idx.[name] from [sys].[indexes] as idx where t.[object_id] = idx.[object_id] and idx.[index_id] = i.[index_id]) as index_name,
		i.index_type_desc,i.index_level as [level],
		i.[object_id],
		i.fragment_count as frag_num,
		round(i.avg_fragmentation_in_percent,2) as frag,
		round(i.avg_fragment_size_in_pages,2) as frag_page,
		i.page_count as [page],
		i.record_count as rec,
		i.ghost_record_count as ghost,
		round(i.avg_fragmentation_in_percent*i.page_count,0) as func
	FROM info as i
	inner join [sys].[all_objects]	as t	on i.[object_id] = t.[object_id];';
end

if(@str is not null)
begin
	exec sp_executesql @str;

	if(@iscreated=1)
	begin
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Уровень фрагментации тех индексов, размер которых не менее 1 экстента (8 страниц) и фрагментация которых более 10% (детальный обход узлов) и только для таблиц-не куч (т е определен кластерный индекс). Берутся в расчёт только корневые индексы' , @level0type=N'SCHEMA',@level0name=N'inf', @level1type=N'VIEW',@level1name=N'vIndexDefrag';
	end
end

set @str=null;
set @iscreated=0;
if(not exists(select top(1) 1 from sys.views where [name]=N'vCountRows' and [schema_id]=SCHEMA_ID(N'inf')))
begin
	set @iscreated=1;

	set @str='CREATE view [inf].[vCountRows] as
-- Метод получения количества записей с использованием DMV dm_db_partition_stats 
SELECT  @@ServerName AS ServerName ,
        DB_NAME() AS DBName ,
        OBJECT_SCHEMA_NAME(ddps.object_id) AS SchemaName ,
        OBJECT_NAME(ddps.object_id) AS TableName ,
        i.Type_Desc ,
        i.Name AS IndexUsedForCounts ,
        SUM(ddps.row_count) AS Rows
FROM    sys.dm_db_partition_stats ddps
        JOIN sys.indexes i ON i.object_id = ddps.object_id
                              AND i.index_id = ddps.index_id
WHERE   i.type_desc IN ( ''CLUSTERED'', ''HEAP'' )
                              -- This is key (1 index per table) 
        AND OBJECT_SCHEMA_NAME(ddps.object_id) <> ''sys''
GROUP BY ddps.object_id ,
        i.type_desc ,
        i.Name
--ORDER BY SchemaName ,
--        TableName;';
end
else
begin
	set @str='ALTER view [inf].[vCountRows] as
-- Метод получения количества записей с использованием DMV dm_db_partition_stats 
SELECT  @@ServerName AS ServerName ,
        DB_NAME() AS DBName ,
        OBJECT_SCHEMA_NAME(ddps.object_id) AS SchemaName ,
        OBJECT_NAME(ddps.object_id) AS TableName ,
        i.Type_Desc ,
        i.Name AS IndexUsedForCounts ,
        SUM(ddps.row_count) AS Rows
FROM    sys.dm_db_partition_stats ddps
        JOIN sys.indexes i ON i.object_id = ddps.object_id
                              AND i.index_id = ddps.index_id
WHERE   i.type_desc IN ( ''CLUSTERED'', ''HEAP'' )
                              -- This is key (1 index per table) 
        AND OBJECT_SCHEMA_NAME(ddps.object_id) <> ''sys''
GROUP BY ddps.object_id ,
        i.type_desc ,
        i.Name
--ORDER BY SchemaName ,
--        TableName;';
end

if(@str is not null)
begin
	exec sp_executesql @str;

	if(@iscreated=1)
	begin
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Метод получения количества записей с использованием DMV dm_db_partition_stats' , @level0type=N'SCHEMA',@level0name=N'inf', @level1type=N'VIEW',@level1name=N'vCountRows';
	end
end

set @str=null;
set @iscreated=0;
if(not exists(select top(1) 1 from sys.views where [name]=N'vIndexUsageStats' and [schema_id]=SCHEMA_ID(N'inf')))
begin
	set @iscreated=1;

	set @str='CREATE view [inf].[vIndexUsageStats] as
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
					SELECT N'', ['' + [name] +N''] ''+case ic.[is_descending_key] when 0 then N''ASC'' when 1 then N''DESC'' end FROM sys.index_columns ic
								   INNER JOIN sys.columns c on c.[object_id] = obj.[object_id] and ic.[column_id] = c.[column_id]
					WHERE ic.[object_id] = obj.[object_id]
					  and ic.[index_id]=i.[index_id]
					  and ic.[is_included_column]=0
					order by ic.[key_ordinal] asc
					FOR XML PATH(''''),TYPE
				).value(''.'',''NVARCHAR(MAX)''),1,2,''''
			  ) as [Columns],
		STUFF(
				(
					SELECT N'', ['' + [name] +N'']'' FROM sys.index_columns ic
								   INNER JOIN sys.columns c on c.[object_id] = obj.[object_id] and ic.[column_id] = c.[column_id]
					WHERE ic.[object_id] = obj.[object_id]
					  and ic.[index_id]=i.[index_id]
					  and ic.[is_included_column]=1
					order by ic.[key_ordinal] asc
					FOR XML PATH(''''),TYPE
				).value(''.'',''NVARCHAR(MAX)''),1,2,''''
			  ) as [IncludeColumns]
FROM     sys.dm_db_index_usage_stats AS s 
         INNER JOIN sys.indexes AS i 
           ON i.object_id = s.object_id 
              AND i.index_id = s.index_id
		 inner join sys.objects as obj on obj.object_id=i.object_id
--WHERE    OBJECTPROPERTY(S.[OBJECT_ID],''IsUserTable'') = 1 ';
end
else
begin
	set @str='ALTER view [inf].[vIndexUsageStats] as
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
					SELECT N'', ['' + [name] +N''] ''+case ic.[is_descending_key] when 0 then N''ASC'' when 1 then N''DESC'' end FROM sys.index_columns ic
								   INNER JOIN sys.columns c on c.[object_id] = obj.[object_id] and ic.[column_id] = c.[column_id]
					WHERE ic.[object_id] = obj.[object_id]
					  and ic.[index_id]=i.[index_id]
					  and ic.[is_included_column]=0
					order by ic.[key_ordinal] asc
					FOR XML PATH(''''),TYPE
				).value(''.'',''NVARCHAR(MAX)''),1,2,''''
			  ) as [Columns],
		STUFF(
				(
					SELECT N'', ['' + [name] +N'']'' FROM sys.index_columns ic
								   INNER JOIN sys.columns c on c.[object_id] = obj.[object_id] and ic.[column_id] = c.[column_id]
					WHERE ic.[object_id] = obj.[object_id]
					  and ic.[index_id]=i.[index_id]
					  and ic.[is_included_column]=1
					order by ic.[key_ordinal] asc
					FOR XML PATH(''''),TYPE
				).value(''.'',''NVARCHAR(MAX)''),1,2,''''
			  ) as [IncludeColumns]
FROM     sys.dm_db_index_usage_stats AS s 
         INNER JOIN sys.indexes AS i 
           ON i.object_id = s.object_id 
              AND i.index_id = s.index_id
		 inner join sys.objects as obj on obj.object_id=i.object_id
--WHERE    OBJECTPROPERTY(S.[OBJECT_ID],''IsUserTable'') = 1 ';
end

if(@str is not null)
begin
	exec sp_executesql @str;

	if(@iscreated=1)
	begin
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Использование индексов' , @level0type=N'SCHEMA',@level0name=N'inf', @level1type=N'VIEW',@level1name=N'vIndexUsageStats';
	end
end

set @str=null;
set @iscreated=0;
if(not exists(select top(1) 1 from sys.views where [name]=N'vOldStatisticsState' and [schema_id]=SCHEMA_ID(N'inf')))
begin
	set @iscreated=1;

	set @str='CREATE view [inf].[vOldStatisticsState] as
with st AS(
select DISTINCT 
obj.[object_id]
, obj.[create_date]
, OBJECT_SCHEMA_NAME(obj.[object_id]) as [SchemaName]
, obj.[name] as [ObjectName]
, CAST(
		(
		   --общее число страниц, зарезервированных в секции (по 8 КБ на 1024 поделить=поделить на 128)
			SELECT SUM(ps2.[reserved_page_count])/128.
			from sys.dm_db_partition_stats as ps2
			where ps2.[object_id] = obj.[object_id]
		) as numeric (38,2)
	  ) as [ObjectSizeMB] --размер объекта в МБ
, s.[stats_id]
, s.[name] as [StatName]
, sp.[last_updated]
, i.[index_id]
, i.[type_desc]
, i.[name] as [IndexName]
, ps.[row_count]
, s.[has_filter]
, s.[no_recompute]
, sp.[rows]
, sp.[rows_sampled]
--кол-во изменений вычисляется как:
--сумма общего кол-ва изменений в начальном столбце статистики с момента последнего обновления статистики
--и разности приблизительного кол-ва строк в секции и общего числа строк в таблице или индексированном представлении при последнем обновлении статистики
, sp.[modification_counter]+ABS(ps.[row_count]-sp.[rows]) as [ModificationCounter]
--% количества строк, выбранных для статистических вычислений,
--к общему числу строк в таблице или индексированном представлении при последнем обновлении статистики
, NULLIF(CAST( sp.[rows_sampled]*100./sp.[rows] as numeric(18,3)), 100.00) as [ProcSampled]
--% общего кол-ва изменений в начальном столбце статистики с момента последнего обновления статистики
--к приблизительному количество строк в секции
, CAST(sp.[modification_counter]*100./(case when (ps.[row_count]=0) then 1 else ps.[row_count] end) as numeric (18,3)) as [ProcModified]
--Вес объекта:
--[ProcModified]*десятичный логарифм от приблизительного кол-ва строк в секции
, CAST(sp.[modification_counter]*100./(case when (ps.[row_count]=0) then 1 else ps.[row_count] end) as numeric (18,3))
							* case when (ps.[row_count]<=10) THEN 1 ELSE LOG10 (ps.[row_count]) END as [Func]
--было ли сканирование:
--общее количество строк, выбранных для статистических вычислений, не равно
--общему числу строк в таблице или индексированном представлении при последнем обновлении статистики
, CASE WHEN sp.[rows_sampled]<>sp.[rows] THEN 0 ELSE 1 END as [IsScanned]
, tbl.[name] as [ColumnType]
, s.[auto_created]	
from sys.objects as obj
inner join sys.stats as s on s.[object_id] = obj.[object_id]
left outer join sys.indexes as i on i.[object_id] = obj.[object_id] and (i.[name] = s.[name] or i.[index_id] in (0,1) 
				and not exists(select top(1) 1 from sys.indexes i2 where i2.[object_id] = obj.[object_id] and i2.[name] = s.[name]))
left outer join sys.dm_db_partition_stats as ps on ps.[object_id] = obj.[object_id] and ps.[index_id] = i.[index_id]
outer apply sys.dm_db_stats_properties (s.[object_id], s.[stats_id]) as sp
left outer join sys.stats_columns as sc on s.[object_id] = sc.[object_id] and s.[stats_id] = sc.[stats_id]
left outer join sys.columns as col on col.[object_id] = s.[object_id] and col.[column_id] = sc.[column_id]
left outer join sys.types as tbl on col.[system_type_id] = tbl.[system_type_id] and col.[user_type_id] = tbl.[user_type_id]
where obj.[type_desc] <> ''SYSTEM_TABLE''
)
SELECT
	st.[object_id]
	, st.[SchemaName]
	, st.[ObjectName]
	, st.[stats_id]
	, st.[StatName]
	, st.[row_count]
	, st.[ProcModified]
	, st.[ObjectSizeMB]
	, st.[type_desc]
	, st.[create_date]
	, st.[last_updated]
	, st.[ModificationCounter]
	, st.[ProcSampled]
	, st.[Func]
	, st.[IsScanned]
	, st.[ColumnType]
	, st.[auto_created]
	, st.[IndexName]
	, st.[has_filter]
	--INTO #tbl
FROM st
WHERE NOT (st.[row_count] = 0 AND st.[last_updated] IS NULL)--если нет данных и статистика не обновлялась
	--если нечего обновлять
	AND NOT (st.[row_count] = st.[rows] AND st.[row_count] = st.[rows_sampled] AND st.[ModificationCounter]=0)
	--если есть что обновлять (и данные существенно менялись)
	AND ((st.[ProcModified]>=10.0) OR (st.[Func]>=10.0) OR (st.[ProcSampled]<=50))';
end
else
begin
	set @str='ALTER view [inf].[vOldStatisticsState] as
with st AS(
select DISTINCT 
obj.[object_id]
, obj.[create_date]
, OBJECT_SCHEMA_NAME(obj.[object_id]) as [SchemaName]
, obj.[name] as [ObjectName]
, CAST(
		(
		   --общее число страниц, зарезервированных в секции (по 8 КБ на 1024 поделить=поделить на 128)
			SELECT SUM(ps2.[reserved_page_count])/128.
			from sys.dm_db_partition_stats as ps2
			where ps2.[object_id] = obj.[object_id]
		) as numeric (38,2)
	  ) as [ObjectSizeMB] --размер объекта в МБ
, s.[stats_id]
, s.[name] as [StatName]
, sp.[last_updated]
, i.[index_id]
, i.[type_desc]
, i.[name] as [IndexName]
, ps.[row_count]
, s.[has_filter]
, s.[no_recompute]
, sp.[rows]
, sp.[rows_sampled]
--кол-во изменений вычисляется как:
--сумма общего кол-ва изменений в начальном столбце статистики с момента последнего обновления статистики
--и разности приблизительного кол-ва строк в секции и общего числа строк в таблице или индексированном представлении при последнем обновлении статистики
, sp.[modification_counter]+ABS(ps.[row_count]-sp.[rows]) as [ModificationCounter]
--% количества строк, выбранных для статистических вычислений,
--к общему числу строк в таблице или индексированном представлении при последнем обновлении статистики
, NULLIF(CAST( sp.[rows_sampled]*100./sp.[rows] as numeric(18,3)), 100.00) as [ProcSampled]
--% общего кол-ва изменений в начальном столбце статистики с момента последнего обновления статистики
--к приблизительному количество строк в секции
, CAST(sp.[modification_counter]*100./(case when (ps.[row_count]=0) then 1 else ps.[row_count] end) as numeric (18,3)) as [ProcModified]
--Вес объекта:
--[ProcModified]*десятичный логарифм от приблизительного кол-ва строк в секции
, CAST(sp.[modification_counter]*100./(case when (ps.[row_count]=0) then 1 else ps.[row_count] end) as numeric (18,3))
							* case when (ps.[row_count]<=10) THEN 1 ELSE LOG10 (ps.[row_count]) END as [Func]
--было ли сканирование:
--общее количество строк, выбранных для статистических вычислений, не равно
--общему числу строк в таблице или индексированном представлении при последнем обновлении статистики
, CASE WHEN sp.[rows_sampled]<>sp.[rows] THEN 0 ELSE 1 END as [IsScanned]
, tbl.[name] as [ColumnType]
, s.[auto_created]	
from sys.objects as obj
inner join sys.stats as s on s.[object_id] = obj.[object_id]
left outer join sys.indexes as i on i.[object_id] = obj.[object_id] and (i.[name] = s.[name] or i.[index_id] in (0,1) 
				and not exists(select top(1) 1 from sys.indexes i2 where i2.[object_id] = obj.[object_id] and i2.[name] = s.[name]))
left outer join sys.dm_db_partition_stats as ps on ps.[object_id] = obj.[object_id] and ps.[index_id] = i.[index_id]
outer apply sys.dm_db_stats_properties (s.[object_id], s.[stats_id]) as sp
left outer join sys.stats_columns as sc on s.[object_id] = sc.[object_id] and s.[stats_id] = sc.[stats_id]
left outer join sys.columns as col on col.[object_id] = s.[object_id] and col.[column_id] = sc.[column_id]
left outer join sys.types as tbl on col.[system_type_id] = tbl.[system_type_id] and col.[user_type_id] = tbl.[user_type_id]
where obj.[type_desc] <> ''SYSTEM_TABLE''
)
SELECT
	st.[object_id]
	, st.[SchemaName]
	, st.[ObjectName]
	, st.[stats_id]
	, st.[StatName]
	, st.[row_count]
	, st.[ProcModified]
	, st.[ObjectSizeMB]
	, st.[type_desc]
	, st.[create_date]
	, st.[last_updated]
	, st.[ModificationCounter]
	, st.[ProcSampled]
	, st.[Func]
	, st.[IsScanned]
	, st.[ColumnType]
	, st.[auto_created]
	, st.[IndexName]
	, st.[has_filter]
	--INTO #tbl
FROM st
WHERE NOT (st.[row_count] = 0 AND st.[last_updated] IS NULL)--если нет данных и статистика не обновлялась
	--если нечего обновлять
	AND NOT (st.[row_count] = st.[rows] AND st.[row_count] = st.[rows_sampled] AND st.[ModificationCounter]=0)
	--если есть что обновлять (и данные существенно менялись)
	AND ((st.[ProcModified]>=10.0) OR (st.[Func]>=10.0) OR (st.[ProcSampled]<=50))';
end

if(@str is not null)
begin
	exec sp_executesql @str;

	if(@iscreated=1)
	begin
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Устаревшие статистики' , @level0type=N'SCHEMA',@level0name=N'inf', @level1type=N'VIEW',@level1name=N'vOldStatisticsState';
	end
end