SELECT [db]
      ,[shema]
      ,[table]
      ,[IndexName]
      ,[frag_num]
      ,[frag]
      ,[page]
      ,[rec]
      ,[ts]
      ,[tf]
      ,DateDiff(second, [ts], [tf]) as DiffSec
      ,[frag_after]
      ,[object_id]
      ,[idx]
      ,[InsertUTCDate]
  FROM [SRV].[srv].[DefragServers]
  where [frag_after]>20 and [page]>=8 and [frag]<=[frag_after]
  and cast([InsertUTCDate] as DATE)=DateAdd(day,-1,cast(GetUTCDate() as DATE))
  order by [frag_after] desc