create view [srv].[vStatisticsIOInTempDB] as
/*
	Если время записи данных (avg_write_stall_ms) меньше 5 мс, то это значит хороший уровень производительности. 
	Между 5 и 10 мс  — приемлемый уровень. 
	Более 10 мс — низкая производительность, необходимо сделать детальный анализ, имеются проблемы с вводом-выводом для временной базы данных
	https://minyurov.com/2016/07/24/mssql-tempdb-opt/
*/
SELECT files.physical_name, files.name,
stats.num_of_writes, (1.0 * stats.io_stall_write_ms / stats.num_of_writes) AS avg_write_stall_ms,
stats.num_of_reads, (1.0 * stats.io_stall_read_ms / stats.num_of_reads) AS avg_read_stall_ms
FROM sys.dm_io_virtual_file_stats(2, NULL) as stats
INNER JOIN master.sys.master_files AS files 
ON stats.database_id = files.database_id
AND stats.file_id = files.file_id
WHERE files.type_desc = 'ROWS'

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о времени записи в файлы БД tempdb экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vStatisticsIOInTempDB';

