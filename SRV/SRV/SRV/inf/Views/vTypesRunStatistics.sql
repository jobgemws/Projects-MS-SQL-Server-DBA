
CREATE view [inf].[vTypesRunStatistics] as
-- Информация по используемым типам данных

SELECT  @@Servername AS ServerName ,
        DB_NAME() AS DBName ,
        Data_Type ,
        Numeric_Precision AS  Prec ,
        Numeric_Scale AS  Scale ,
        Character_Maximum_Length AS [Length] ,
        COUNT(*) AS COUNT
FROM    INFORMATION_SCHEMA.COLUMNS isc
        INNER JOIN  INFORMATION_SCHEMA.TABLES ist
               ON isc.table_name = ist.table_name
WHERE   Table_type = 'BASE TABLE'
GROUP BY Data_Type ,
        Numeric_Precision ,
        Numeric_Scale ,
        Character_Maximum_Length
--ORDER BY Data_Type ,
--        Numeric_Precision ,
--        Numeric_Scale ,
--        Character_Maximum_Length  


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по используемым типам данных', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vTypesRunStatistics';

