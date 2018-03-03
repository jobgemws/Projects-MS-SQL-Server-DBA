
CREATE view [inf].[vColumnsStatisticsCount] as
-- Имена столбцов и количество повторов
-- Используется для поиска одноимённых столбцов с разными типами данных/длиной

SELECT  @@Servername AS Server ,
        DB_NAME() AS DBName ,
        Column_Name ,
        Data_Type ,
        Numeric_Precision AS  Prec ,
        Numeric_Scale AS  Scale ,
        Character_Maximum_Length ,
        COUNT(*) AS Count
FROM     INFORMATION_SCHEMA.COLUMNS isc
        INNER JOIN  INFORMATION_SCHEMA.TABLES ist
               ON isc.table_name = ist.table_name
WHERE   Table_type = 'BASE TABLE'
GROUP BY Column_Name ,
        Data_Type ,
        Numeric_Precision ,
        Numeric_Scale ,
        Character_Maximum_Length; 


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имена столбцов и количество повторов
Используется для поиска одноимённых столбцов с разными типами данных/длиной', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vColumnsStatisticsCount';

