create view [inf].[vDBFileInfo] as
--информация о файлах БД
SELECT  @@Servername AS Server ,
        DB_NAME() AS DB_Name ,
        File_id ,
        Type_desc ,
        Name ,
        LEFT(Physical_Name, 1) AS Drive ,
        Physical_Name ,
        RIGHT(physical_name, 3) AS Ext ,
        Size ,
        Growth
FROM    sys.database_files
--ORDER BY File_id; 



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о файлах БД', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vDBFileInfo';

