USE [<DB_Name>];
go

declare @tbl varchar(255)='table_name'
 
  SELECT DB_NAME() БД,
   o.name AS ObjectName --имя объекта
   , i.name AS IndexName --имя индекса
   , i.index_id AS IndexID
   , dm_ius.user_seeks AS UserSeek --число поисков
   , dm_ius.user_scans AS UserScans --число сканирований
   , dm_ius.user_lookups AS UserLookups --число просмотров индекса
   , dm_ius.user_updates AS UserUpdates --число модификаций
   ,last_user_seek --дата последнего поиска
   ,last_user_scan --дата последнего сканирования
   ,last_user_lookup--дата последнего просмотра
   , p.TableRows --число записей в таблице
   , 'DROP INDEX ' + QUOTENAME(i.name)
   + ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS 'drop statement' --скрипт на удаление
   FROM sys.dm_db_index_usage_stats dm_ius
   INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = i.OBJECT_ID
   INNER JOIN sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
   INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
   INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
   FROM sys.partitions p GROUP BY p.index_id, p.OBJECT_ID) p
   ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
   WHERE OBJECTPROPERTY(dm_ius.OBJECT_ID,'IsUserTable') = 1 --рассматриваем таблицы
   AND dm_ius.database_id = DB_ID()
   AND i.type_desc in('clustered', 'nonclustered') --типы индексов
   AND i.is_unique_constraint = 0
   AND (@tbl='' or o.name=@tbl) --название таблицы
   ORDER BY (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC