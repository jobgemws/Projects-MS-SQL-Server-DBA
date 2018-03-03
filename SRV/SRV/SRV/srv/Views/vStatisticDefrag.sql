




CREATE view [srv].[vStatisticDefrag] as
SELECT top 1000
	  [db]
	  ,[shema]
      ,[table]
      ,[IndexName]
      ,avg([frag]) as AvgFrag
      ,avg([frag_after]) as AvgFragAfter
	  ,avg(page) as AvgPage
  FROM [srv].[Defrag]
  group by [db], [shema], [table], [IndexName]
  order by abs(avg([frag])-avg([frag_after])) desc





GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о выполнении реорганизации индексов по собранным данным', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vStatisticDefrag';

