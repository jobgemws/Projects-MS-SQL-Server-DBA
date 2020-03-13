declare @rows int=100 --Показатель число записей в таблице >= 1000 - начинающая БД(FortisDataStore), 5000 - БД Trucks
declare @user_seeks int=100 --пользовательских обращений к таблице >= 1000 - начинающая БД (FortisDataStore), 10000 - БД Trucks
declare @avg_user_impact float=90.0 -- % возможного улучшения >=
--доп параметры avg_user_impact<@avg_user_impact, но при этом все же высокий показатель @est_impact
declare @dop_avg_user_impact float=15.0
declare @est_impact int=1000 --более ранние значения 1 000 000 (БД Trucks), другие БД как из вариантов 100000
declare @max_new int=3--максимум новых индексов на таблицу
declare @last_seek int=3--хотя бы три дня
 
SELECT *
FROM
(SELECT  @@ServerName AS ServerName ,
        DB_NAME() AS DBName ,
        s.name+'.'+t.name AS 'Affected_table' ,
        row_number() over (partition by s.name+'.'+t.name order by (ddmigs.user_seeks+ddmigs.user_scans)*ddmigs.avg_user_impact DESC) Rang,
        COALESCE(ddmid.equality_columns, '')
        + CASE WHEN ddmid.equality_columns IS NOT NULL
                    AND ddmid.inequality_columns IS NOT NULL THEN ','
               ELSE ''
          END + COALESCE(ddmid.inequality_columns, '') AS Keys ,
        COALESCE(ddmid.included_columns, '') AS [include] ,
        ddmid.[statement] ,
        'Create NonClustered Index IX_' + t.name+'_'+ CONVERT(varchar(8),getdate(),112)+'_'+ cast(row_number() over (partition by s.name+'.'+t.name order by (ddmigs.user_seeks+ddmigs.user_scans)*ddmigs.avg_user_impact DESC) as varchar(5))
        --+ CAST(ddmid.index_handle AS VARCHAR(20))
        + ' On ' + ddmid.[statement] COLLATE database_default
        + ' (' + ISNULL(ddmid.equality_columns, '')
        + CASE WHEN ddmid.equality_columns IS NOT NULL
                    AND ddmid.inequality_columns IS NOT NULL THEN ','
               ELSE ''
          END + ISNULL(ddmid.inequality_columns, '') + ')'
        + ISNULL(' Include (' + ddmid.included_columns + ');', ';')
                                                  AS sql_statement ,
        ddmigs.user_seeks ,
        last_user_seek,
        last_user_scan,
        ind.Rows,
        CAST(( ddmigs.user_seeks + ddmigs.user_scans )
        * ddmigs.avg_user_impact AS BIGINT) AS 'est_impact',
        avg_user_impact
FROM    sys.dm_db_missing_index_groups ddmig
        INNER JOIN sys.dm_db_missing_index_group_stats ddmigs
               ON ddmigs.group_handle = ddmig.index_group_handle
        INNER JOIN sys.dm_db_missing_index_details ddmid
               ON ddmig.index_handle = ddmid.index_handle
        INNER JOIN sys.tables t ON ddmid.OBJECT_ID = t.OBJECT_ID
        INNER JOIN sys.schemas s on(t.schema_id=s.schema_id)
        INNER JOIN
        (SELECT --Индексы,таблицы,записи в таблицах
        OBJECT_SCHEMA_NAME(p.object_id)+'.'+OBJECT_NAME(p.object_id) AS TableName ,
        SUM(p.Rows) AS Rows
FROM    sys.partitions p
        JOIN sys.indexes i ON     i.object_id = p.object_id
                              AND i.index_id  = p.index_id
WHERE   i.type_desc IN ( 'CLUSTERED', 'HEAP' ) -- HEAP - куча,без ключа; CLUSTERED - обычно первичный ключ
        AND OBJECT_SCHEMA_NAME(p.object_id) <> 'sys' --выбираем не системные таблицы
GROUP BY p.object_id ,
        i.type_desc ,
        i.Name
HAVING  SUM(p.Rows)>=@rows/*больше указанного числа записей*/) as ind on (s.name+'.'+t.name=ind.TableName)
WHERE   ddmid.database_id = DB_ID()
    and ddmigs.user_seeks>=@user_seeks --число пользовательских поисков
    and (avg_user_impact>=@avg_user_impact -- >= указанного процента улучшения
     or (avg_user_impact>=@dop_avg_user_impact and ((ddmigs.user_seeks + ddmigs.user_scans)*ddmigs.avg_user_impact)>=@est_impact)
     or CAST(( ddmigs.user_seeks + ddmigs.user_scans ) * ddmigs.avg_user_impact AS BIGINT)>=@est_impact*10)
) as a --показатель возможного улучшения
WHERE Rang<=@max_new
  and (
        cast(last_user_seek AS DATE)>=dateadd(DAY,-@last_seek,cast(getdate() AS DATE))
     or cast(last_user_scan AS DATE)>=dateadd(DAY,-@last_seek,cast(getdate() AS DATE))
  )
ORDER BY [Rows],
         user_seeks DESC,
         Affected_table,
         est_impact DESC;--Изначально в базовом примере утверждается,что est_impact самый главный параметр на улучшение