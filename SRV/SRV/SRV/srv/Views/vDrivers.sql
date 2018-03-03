
create view [srv].[vDrivers] as
select
	  [Driver_GUID]
      ,[Server]
      ,[Name]
	  ,[TotalSpace] as [TotalSpaceByte]
	  ,[FreeSpace] as [FreeSpaceByte]
	  ,[DiffFreeSpace] as [DiffFreeSpaceByte]
	  ,round([TotalSpace]/1024, 3) as [TotalSpaceKb]
	  ,round([FreeSpace]/1024, 3) as [FreeSpaceKb]
	  ,round([DiffFreeSpace]/1024, 3) as [DiffFreeSpaceKb]
      ,round([TotalSpace]/1024/1024, 3) as [TotalSpaceMb]
	  ,round([FreeSpace]/1024/1024, 3) as [FreeSpaceMb]
	  ,round([DiffFreeSpace]/1024/1024, 3) as [DiffFreeSpaceMb]
	  ,round([TotalSpace]/1024/1024/1024, 3) as [TotalSpaceGb]
	  ,round([FreeSpace]/1024/1024/1024, 3) as [FreeSpaceGb]
	  ,round([DiffFreeSpace]/1024/1024/1024, 3) as [DiffFreeSpaceGb]
	  ,round([TotalSpace]/1024/1024/1024/1024, 3) as [TotalSpaceTb]
	  ,round([FreeSpace]/1024/1024/1024/1024, 3) as [FreeSpaceTb]
	  ,round([DiffFreeSpace]/1024/1024/1024/1024, 3) as [DiffFreeSpaceTb]
	  ,round([FreeSpace]/([TotalSpace]/100), 3) as [FreeSpacePercent]
	  ,round([DiffFreeSpace]/([TotalSpace]/100), 3) as [DiffFreeSpacePercent]
      ,[InsertUTCDate]
      ,[UpdateUTCdate]
  FROM [srv].[Drivers]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о логических дисках', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vDrivers';

