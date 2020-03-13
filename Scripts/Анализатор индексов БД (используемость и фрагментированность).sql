-----Анализ индексов
declare @DB varchar(255)='MonopolySunTemp' --БД для анализа
,@k int=5 --кратность Danger по превышению scans_lookups над seeks
,@kk int=10 --updates >= reads*@kk
,@frag int=8 --пороговая логическая фрагментированность от 8%
,@TableRows int=500 --перестраиваем индексы от 100 строк
,@MaxTableRows int=10000000
,@MI int=120 --последний select @MI минут и менее
,@MI2 int=180 --последняя модификации @MI минут и менее
, @page int=10 --рассматриваем индексы от @p страниц и более
,@index_frag float=3--коэффициент @frag*@index_frag = пороговая фргаментированность для некластеризованных индексов
,@lock_timeout int=5000 --максимальный период блокировки 5000 мс
,@K_TableRows int=50 --коэффициент для определения REORAGNIZE/REBUILD для больших таблиц,  TableRows>=@TableRows*@K_TableRows
,@FillFactor tinyint=95
,@stats_upd int=1 --0 --простое обновление статистики, 1 FULLSCAN
,@table varchar(255)='' --можно делать уточнение на таблицу
,@script int=0 --1 - вверху которая нужно переиндексировать 0 - по проблемности индекса
   
declare @tbl table([index] nvarchar(2000), [schema] varchar(255) ,[tbl] nvarchar(2000),index_id int,object_id int,[type] int,user_seeks bigint
,user_scans bigint,user_lookups bigint,user_updates bigint,last_user_seek datetime,last_user_scan datetime,last_user_lookup datetime,last_user_update datetime,TableRows bigint)
     
declare @SQL nvarchar(2000)--SQL контэйнер
     
    SET @SQL='SELECT i.name [index],sch.name,o.name as [tbl],i.index_id,o.object_id,i.[type],user_seeks,user_scans,user_lookups,user_updates,last_user_seek,last_user_scan,last_user_lookup,last_user_update,TableRows
     FROM ['+@DB+'].sys.dm_db_index_usage_stats dm_ius
     INNER JOIN ['+@DB+'].sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = i.OBJECT_ID
     INNER JOIN ['+@DB+'].sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
     INNER JOIN ['+@DB+'].sys.schemas sch ON o.SCHEMA_ID = sch.SCHEMA_ID
     INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
     FROM ['+@DB+'].sys.partitions p GROUP BY p.index_id, p.OBJECT_ID) p
     ON ('''+@table+'''='''' or o.name='''+@table+''') and p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
     WHERE i.type_desc in(''clustered'', ''nonclustered'')'
     
    insert into @tbl([index],[schema],[tbl],index_id,[object_id],[type],user_seeks,user_scans,user_lookups,user_updates,last_user_seek,last_user_scan,last_user_lookup,last_user_update,TableRows)
    exec sp_executesql @SQL
     
    set @SQL=''
     
 SELECT [Status],[Need Rebuild],
 script=(case when [Need Rebuild]<>'' then 'ALTER INDEX ['+[index]+'] ON ['+@DB+'].['+[schema]+'].['+tbl+'] '+[Need Rebuild]+'' else ''  end)
 ,'['+[schema]+'].['+tbl+']' tbl,[index],[type],frag_percent,TableRows,page_count,user_seeks,user_scans,user_lookups,user_updates,last_user_seek,last_user_scan,last_user_lookup,last_user_update
 INTO #RESULT
 FROM
 (SELECT [Status]=(case when user_seeks*@k<=(user_scans+user_lookups) and user_seeks*@kk>(user_scans+user_lookups) and TableRows>=@TableRows
 and ((user_seeks>0 or user_scans>0 or user_lookups>0) or (last_user_seek<=dateadd(MI,-@MI,getdate())
 or last_user_scan<=dateadd(MI,-@MI,getdate())
 or last_user_lookup<=dateadd(MI,-@MI,getdate())))  then 'Warning'
 when user_seeks*@kk<=(user_scans+user_lookups) and TableRows>=@TableRows and ((user_seeks>0 or user_scans>0 or user_lookups>0) or (last_user_seek<=dateadd(MI,-@MI,getdate())
 or last_user_scan<=dateadd(MI,-@MI,getdate())
 or last_user_lookup<=dateadd(MI,-@MI,getdate())))
 then 'Danger'
 when ((user_seeks=0 and user_scans=0 and user_lookups=0 and user_updates>0) or (user_updates>=(user_seeks+user_scans+user_lookups)*@kk))
 and (last_user_seek>0 or last_user_scan>0 or last_user_lookup>0) and ((frag_percent>=@frag and type=1/*кластеризованный индекс*/)
 or (frag_percent>=@frag*@index_frag and type=2/*некластеризованный индекс*/)) and TableRows>=@TableRows then 'Critical'
 when ((user_seeks=0 and user_scans=0 and user_lookups=0) or (last_user_seek is null and last_user_scan is null and last_user_lookup is null))
 and type=2 --для некластеризованных индексов
 then 'Drop index'
 else 'Normal'  end),[Need Rebuild]=(case when (TableRows<=@TableRows or TableRows>=@MaxTableRows)
  then '' when TableRows<=@TableRows*@K_TableRows and (last_user_seek>=dateadd(MI,-@MI,getdate())
 or last_user_scan>=dateadd(MI,-@MI,getdate())
 or last_user_lookup>=dateadd(MI,-@MI,getdate())) and ((frag_percent>@frag and type=1 /*кластеризованный индекс*/)
 or (frag_percent>@frag*@index_frag and type=2 /*некластеризованный индекс*/))
 and last_user_update>=dateadd(MI,-@MI2,getdate()) and page_count>@page then 'REBUILD'
 when TableRows>=@TableRows*@K_TableRows  and (last_user_seek>=dateadd(MI,-@MI,getdate())
 or last_user_scan>=dateadd(MI,-@MI,getdate())
 or last_user_lookup>=dateadd(MI,-@MI,getdate())) and ((frag_percent>@frag and type=1) or (frag_percent>@frag*@index_frag and type=2))
 and last_user_update>=dateadd(MI,-@MI2,getdate()) and page_count>@page  then 'REORGANIZE' else '' end)
 ,* FROM (  SELECT * FROM @tbl a
 CROSS APPLY (select top 1 cast(avg_fragmentation_in_percent as numeric(3,1)) as frag_percent,page_count
 from sys.dm_db_index_physical_stats(DB_ID(@DB), a.object_id, a.index_id, NULL, NULL)) tbl) t) TBL
   
 --Параметры для перестроения индекса
 DECLARE @DOP_PAR varchar(500)=' PARTITION = ALL WITH (SORT_IN_TEMPDB = ON,ALLOW_ROW_LOCKS = ON, FILLFACTOR = '+cast(@FillFactor as varchar(2))+')'
  
 if @script=0
 SELECT [Status],[Need Rebuild],
 script=case when isnull(@lock_timeout,0)>0 and [Need Rebuild]<>'' then 'SET LOCK_TIMEOUT '+cast(@lock_timeout as varchar(50))+';' else '' end+script
 + case when [Need Rebuild]='REBUILD' then @DOP_PAR else '' end+ case when [Need Rebuild]<>'' then ';' else '' end+
 +case when @stats_upd=1 then 'UPDATE STATISTICS ['+@DB+'].'+tbl+'  WITH FULLSCAN'
 when @stats_upd=0 then 'UPDATE STATISTICS ['+@DB+'].'+tbl+' ' else '' end
 ,tbl,[index],[type],frag_percent,TableRows,page_count,user_seeks,user_scans,user_lookups,user_updates,last_user_seek,last_user_scan,last_user_lookup,last_user_update
 FROM #RESULT
 ORDER BY (case when [Status]='Drop index' then 5 when [Status]='Critical' then 4
 when [Status]='Danger' then 3 when [Status]='Warning' then 2 when [Status]='Normal' then 1 end) desc,
 tbl,(user_seeks + user_scans + user_lookups) desc,user_updates desc
   
 if @script=1
 SELECT [Status],[Need Rebuild],
 script=case when isnull(@lock_timeout,0)>0 and [Need Rebuild]<>'' then 'SET LOCK_TIMEOUT '+cast(@lock_timeout as varchar(50))+';' else '' end+script
  + case when [Need Rebuild]='REBUILD' then @DOP_PAR else '' end+ case when [Need Rebuild]<>'' then ';' else '' end+
   +case when @stats_upd=1 and [Need Rebuild]<>'' then 'UPDATE STATISTICS ['+@DB+'].'+tbl+'  WITH FULLSCAN'
 when @stats_upd=0 and [Need Rebuild]<>'' then 'UPDATE STATISTICS ['+@DB+'].'+tbl+' ' else '' end
 ,tbl,[index],[type],frag_percent,TableRows,page_count,user_seeks,user_scans,user_lookups,user_updates,last_user_seek,last_user_scan,last_user_lookup,last_user_update
 FROM #RESULT
 ORDER BY [Need Rebuild] DESC, TableRows*frag_percent DESC
   
 IF OBJECT_ID('tempdb..#RESULT','U') IS NOT NULL
 DROP TABLE #RESULT