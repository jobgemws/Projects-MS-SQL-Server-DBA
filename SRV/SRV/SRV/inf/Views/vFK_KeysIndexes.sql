
CREATE view [inf].[vFK_KeysIndexes] as
-- список внешних ключей
-- Foreign Keys missing indexes 
-- Этот скрипт работает только для создания индексов по одному столбцу
-- Внешние ключи, состоящие более чем из одного столбца, не отслеживаются

SELECT  DB_NAME() AS DBName ,
        rc.CONSTRAINT_NAME AS FK_Constraint , 
		rc.CONSTRAINT_CATALOG AS FK_Database, 
		rc.CONSTRAINT_SCHEMA AS FKSchema, 
		ccu.TABLE_SCHEMA as SchemaFK_Table,
        ccu.TABLE_NAME AS FK_Table ,
        ccu.COLUMN_NAME AS FK_Column ,
		ccu2.TABLE_SCHEMA as SchemaParentTable,
        ccu2.TABLE_NAME AS ParentTable ,
        ccu2.COLUMN_NAME AS ParentColumn ,
        i.name AS IndexName ,
        CASE WHEN i.name IS NULL
             THEN 'IF NOT EXISTS (SELECT * FROM sys.indexes
                                    WHERE object_id = OBJECT_ID(N'''
                  + rc.CONSTRAINT_SCHEMA + '.' + ccu.TABLE_NAME
                  + ''') AND name = N''IX_' + ccu.TABLE_NAME + '_'
                  + ccu.COLUMN_NAME + ''') '
                  + 'CREATE NONCLUSTERED INDEX IX_' + ccu.TABLE_NAME + '_'
                  + ccu.COLUMN_NAME + ' ON ' + rc.CONSTRAINT_SCHEMA + '.'
                  + ccu.TABLE_NAME + '( ' + ccu.COLUMN_NAME
                  + ' ASC ) WITH (PAD_INDEX = OFF, 
                                   STATISTICS_NORECOMPUTE = OFF,
                                   SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF,
                                   DROP_EXISTING = OFF, ONLINE = ON);'
             ELSE ''
        END AS SQL
FROM     INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
        JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
         ON rc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
        JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu2
         ON rc.UNIQUE_CONSTRAINT_NAME = ccu2.CONSTRAINT_NAME
        LEFT JOIN sys.columns c ON ccu.COLUMN_NAME = c.name
                                AND ccu.TABLE_NAME = OBJECT_NAME(c.object_id)
        LEFT JOIN sys.index_columns ic ON c.object_id = ic.object_id
                                          AND c.column_id = ic.column_id
                                          AND index_column_id  = 1

                                           -- index found has the foreign key
                                          --  as the first column 

        LEFT JOIN sys.indexes i ON ic.object_id = i.object_id
                                   AND ic.index_id = i.index_id
--WHERE   I.name IS NULL
--ORDER BY FK_table ,
--        ParentTable ,
--        ParentColumn; 




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Внешние ключи с индексами', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vFK_KeysIndexes';

