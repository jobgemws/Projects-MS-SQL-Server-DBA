

CREATE view [inf].[vComputedColumns] as
-- Вычисляемые столбцы

SELECT  @@Servername AS ServerName ,
        DB_NAME() AS DBName ,
        OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName ,
        OBJECT_NAME(t.object_id) AS Tablename ,
        t.Column_id ,
        t.Name AS  Computed_Column ,
        t.[Definition] ,
        t.is_persisted 
FROM    sys.computed_columns as t
--ORDER BY SchemaName ,
--        Tablename ,
--        [Definition];





GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вычисляемые столбцы', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vComputedColumns';

