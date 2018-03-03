
CREATE view [inf].[vServerFilesDB] as
--основная информация о файлах БД
SELECT  @@SERVERNAME AS Server ,
        d.name AS DBName ,
        create_date ,
        compatibility_level ,
        m.physical_name AS FileName,
		d.create_date as CreateDate
FROM    sys.databases d
        JOIN sys.master_files m ON d.database_id = m.database_id
WHERE   m.[type] = 0 -- data files only
--ORDER BY d.name;


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Основная информация по всем файлам всех БД экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vServerFilesDB';

