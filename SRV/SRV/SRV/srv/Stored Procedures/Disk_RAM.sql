
CREATE   proc [srv].[Disk_RAM]
as
begin
	set xact_abort on;
	set nocount on;

	--Вывод данных по видимым MS SQL логическим дискам
	SELECT  volume_mount_point as [Disk]
		  ,cast(((MAX(s.total_bytes))/1024.0)/1024.0 as numeric(11,2))as  Disk_Space_Mb
		  ,cast(((MIN(s.available_bytes))/1024.0)/1024.0 as numeric(11,2)) as Available_Mb
		  ,cast((MIN(available_bytes)/cast(MAX(total_bytes) as float))*100 as numeric(11,2)) as [Available_Percent]
	FROM sys.master_files AS f  
	CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) as s
	GROUP BY volume_mount_point; 

	--Вывод данным о использование RAM на сервере
	select ceiling(physical_memory_kb/1024.0) as [physical_memory_Mb]
		  ,ceiling(committed_target_kb/1024.0) as [committed_target_Mb]
		  ,ceiling(physical_memory_in_use_kb/1024.0) as [physical_memory_in_use_Mb]
		  ,ceiling(available_physical_memory_kb/1024.0) as [available_physical_memory_Mb]
		  ,cast((available_physical_memory_kb/cast(physical_memory_kb as float))*100 as numeric(10,2)) as [Avail RAM (%)]  
	from sys.dm_os_process_memory as a
	cross join sys.dm_os_sys_info as b
	cross join sys.dm_os_sys_memory as v;
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вывод данных по видимым MS SQL логическим дискам.Вывод данным о использование RAM на сервере', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'Disk_RAM';

