CREATE view [inf].[vOldStatisticsState] as
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
	where obj.[type_desc] <> 'SYSTEM_TABLE'
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
		AND ((st.[ProcModified]>=10.0) OR (st.[Func]>=10.0) OR (st.[ProcSampled]<=50))

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Устаревшие статистики', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vOldStatisticsState';

