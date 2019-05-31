create view [inf].[vDisk] as
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
