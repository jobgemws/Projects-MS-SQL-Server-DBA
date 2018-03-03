create view [inf].[vReadWriteTables] as
-- Чтение/запись таблицы
-- Кучи не рассматриваются, у них нет индексов
-- Только те таблицы, к которым обращались после запуска SQL Server

SELECT  @@ServerName AS ServerName ,
        DB_NAME() AS DBName ,
		s.name AS SchemaTableName ,
        OBJECT_NAME(ddius.object_id) AS TableName ,
        SUM(ddius.user_seeks + ddius.user_scans + ddius.user_lookups)
                                                               AS  Reads ,
        SUM(ddius.user_updates) AS Writes ,
        SUM(ddius.user_seeks + ddius.user_scans + ddius.user_lookups
            + ddius.user_updates) AS [Reads&Writes] ,
        ( SELECT    DATEDIFF(s, create_date, GETDATE()) / 86400.0
          FROM      master.sys.databases
          WHERE     name = 'tempdb'
        ) AS SampleDays ,
        ( SELECT    DATEDIFF(s, create_date, GETDATE()) AS SecoundsRunnig
          FROM      master.sys.databases
          WHERE     name = 'tempdb'
        ) AS SampleSeconds
FROM    sys.dm_db_index_usage_stats ddius
		inner join sys.tables as t on t.object_id=ddius.object_id
		inner join sys.schemas as s on t.schema_id=s.schema_id
		INNER JOIN sys.indexes i ON ddius.object_id = i.object_id
                                     AND i.index_id = ddius.index_id
WHERE    OBJECTPROPERTY(ddius.object_id, 'IsUserTable') = 1
        AND ddius.database_id = DB_ID()
GROUP BY s.name, OBJECT_NAME(ddius.object_id)
--ORDER BY [Reads&Writes] DESC;



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Данные по чтению/записи таблицы (кучи не рассматриваются, т к у них нет индексов).
Только те таблицы, к которым обращались после запуска SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vReadWriteTables';

