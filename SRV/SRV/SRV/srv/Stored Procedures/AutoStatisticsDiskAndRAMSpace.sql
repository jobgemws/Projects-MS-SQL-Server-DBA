

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoStatisticsDiskAndRAMSpace]
AS
BEGIN
	/*
		Собирает информацию о емкостях логических дисков и ОЗУ
	*/
	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    --По дискам сингализация
	insert into [srv].[DiskSpaceStatistics] (
		   [Disk]
		 , [Disk_Space_Mb]
		 , [Available_Mb]
		 , [Available_Percent]
		 , [State]
	)
	select [Disk]
		 , [Disk_Space_Mb]
		 , [Available_Mb]
		 , [Available_Percent]
		 , (case when [Available_Percent]<=20 and [Available_Percent]>10 then 'Warning' when [Available_Percent]<=10 then 'Danger' else 'Normal' end) as [State]
	from
	(	SELECT  volume_mount_point as [Disk]
		, cast(((MAX(s.total_bytes))/1024.0)/1024.0 as numeric(11,2)) as Disk_Space_Mb
		, cast(((MIN(s.available_bytes))/1024.0)/1024.0 as numeric(11,2)) as Available_Mb
		, cast((MIN(available_bytes)/cast(MAX(total_bytes) as float))*100 as numeric(11,2)) as [Available_Percent]
		FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) as s
		GROUP BY volume_mount_point
	) as a;
	
	--ПО RAM сингализация
	insert into [srv].[RAMSpaceStatistics] (
		   [TotalAvailOSRam_Mb]
		 , [RAM_Avail_Percent]
		 , [Server_physical_memory_Mb]
		 , [SQL_server_committed_target_Mb]
		 , [SQL_server_physical_memory_in_use_Mb]
		 , [State]
	)
	select a0.[TotalAvailOSRam_Mb]
		 , a0.[RAM_Avail_Percent]
		 , ceiling(b.physical_memory_kb/1024.0) as [Server_physical_memory_Mb]
		 , ceiling(b.committed_target_kb/1024.0) as [SQL_server_committed_target_Mb]
		 , ceiling(a.physical_memory_in_use_kb/1024.0) as [SQL_server_physical_memory_in_use_Mb]
		 --, ceiling(v.available_physical_memory_kb/1024.0) as [available_physical_memory_Mb]
		 , (case when (ceiling(b.committed_target_kb/1024.0)-1024)<ceiling(a.physical_memory_in_use_kb/1024.0) then 'Warning' else 'Normal' end) as [State]
		 --, (case when [RAM_Avail_Percent]<=8 and [RAM_Avail_Percent]>5 then 'Warning' when [RAM_Avail_Percent]<=5 then 'Danger' else 'Normal' end) as [State]
	from
	(
		select cast(available_physical_memory_kb/1024.0 as int) as TotalAvailOSRam_Mb
			 , cast((available_physical_memory_kb/casT(total_physical_memory_kb as float))*100 as numeric(5,2)) as [RAM_Avail_Percent]
		from sys.dm_os_sys_memory
	) as a0
	cross join sys.dm_os_process_memory as a
	cross join sys.dm_os_sys_info as b
	cross join sys.dm_os_sys_memory as v;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Собирает информацию о емкостях логических дисков и ОЗУ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoStatisticsDiskAndRAMSpace';

