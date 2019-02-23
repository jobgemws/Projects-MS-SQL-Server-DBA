CREATE view [inf].[vIndexDefrag]
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
		N'LIMITED') as ps
		inner join sys.indexes as i on i.[object_id]=ps.[object_id] and i.[index_id]=ps.[index_id]
		where ps.index_level = 0
		and ps.avg_fragmentation_in_percent >= 10
		and ps.index_type_desc <> 'HEAP'
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
	inner join [sys].[all_objects]	as t	on i.[object_id] = t.[object_id];

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Уровень фрагментации тех индексов, размер которых не менее 1 экстента (8 страниц) и фрагментация которых более 10% (детальный обход узлов) и только для таблиц-не куч (т е определен кластерный индекс). Берутся в расчёт только корневые индексы', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vIndexDefrag';

