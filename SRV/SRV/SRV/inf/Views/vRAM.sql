

CREATE view [inf].[vRAM] as
select a.[TotalAvailOSRam_Mb]						--сколько свободно ОЗУ на сервере в МБ
		 , a.[RAM_Avail_Percent]					--процент свободного ОЗУ на сервере
		 , a.[Server_physical_memory_Mb]			--сколько всего ОЗУ на сервере в МБ
		 , a.[SQL_server_committed_target_Mb]		--сколько всего ОЗУ выделено под MS SQL Server в МБ
		 , a.[SQL_server_physical_memory_in_use_Mb] --сколько всего ОЗУ потребляет MS SQL Server в данный момент времени в МБ
		 , a.[SQL_RAM_Avail_Percent]				--поцент свободного ОЗУ для MS SQL Server относительно всего выделенного ОЗУ для MS SQL Server
		 , a.[StateMemorySQL]						--достаточно ли ОЗУ для MS SQL Server
		 , a.[SQL_RAM_Reserve_Percent]				--процентт выделенной ОЗУ для MS SQL Server относительно всего ОЗУ сервера
		 --достаточн ли ОЗУ для сервера
		, (case when a.[RAM_Avail_Percent]<10 and a.[RAM_Avail_Percent]>5 and a.[TotalAvailOSRam_Mb]<8192 then 'Warning' when a.[RAM_Avail_Percent]<=5 and a.[TotalAvailOSRam_Mb]<2048 then 'Danger' else 'Normal' end) as [StateMemoryServer]
	from
	(
		select cast(a0.available_physical_memory_kb/1024.0 as int) as TotalAvailOSRam_Mb
			 , cast((a0.available_physical_memory_kb/casT(a0.total_physical_memory_kb as float))*100 as numeric(5,2)) as [RAM_Avail_Percent]
			 , a0.system_low_memory_signal_state
			 , ceiling(b.physical_memory_kb/1024.0) as [Server_physical_memory_Mb]
			 , ceiling(b.committed_target_kb/1024.0) as [SQL_server_committed_target_Mb]
			 , ceiling(a.physical_memory_in_use_kb/1024.0) as [SQL_server_physical_memory_in_use_Mb]
			 , cast(((b.committed_target_kb-a.physical_memory_in_use_kb)/casT(b.committed_target_kb as float))*100 as numeric(5,2)) as [SQL_RAM_Avail_Percent]
			 , cast((b.committed_target_kb/casT(a0.total_physical_memory_kb as float))*100 as numeric(5,2)) as [SQL_RAM_Reserve_Percent]
			 , (case when (ceiling(b.committed_target_kb/1024.0)-1024)<ceiling(a.physical_memory_in_use_kb/1024.0) then 'Warning' else 'Normal' end) as [StateMemorySQL]
		from sys.dm_os_sys_memory as a0
		cross join sys.dm_os_process_memory as a
		cross join sys.dm_os_sys_info as b
		cross join sys.dm_os_sys_memory as v
	) as a
	;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по использованию ОЗУ', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vRAM';

