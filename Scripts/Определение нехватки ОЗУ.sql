SELECT TOP (1000) [WaitType]
      ,[Wait_S]
      ,[Resource_S]
      ,[Signal_S]
      ,[WaitCount]
      ,[Percentage]
      ,[AvgWait_S]
      ,[AvgRes_S]
      ,[AvgSig_S]
  FROM [SRV].[inf].[vWaits]
  where [WaitType] in (
    'PAGEIOLATCH_XX',
    'RESOURCE_SEMAPHORE',
    'RESOURCE_SEMAPHORE_QUERY_COMPILE'
  )