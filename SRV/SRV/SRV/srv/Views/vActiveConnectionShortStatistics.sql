create view [srv].[vActiveConnectionShortStatistics] as
with tbl0 as (
	select [ServerName]
      ,[DBName]
	  ,[Status]
	FROM [srv].[vActiveConnectionStatistics]
	group by [ServerName]
      ,[DBName]
	  ,[Status]
	  ,YEAR([InsertUTCDate])
	  ,MONTH([InsertUTCDate])
	  ,DAY([InsertUTCDate])
	  ,DATEPART(hour,[InsertUTCDate])
	  ,DATEPART(minute,[InsertUTCDate])
)
, tbl1 as (
	select [ServerName]
      ,[DBName]
	  ,[Status]
	  ,count(*) as [count]
	FROM tbl0
	group by [ServerName]
      ,[DBName]
	  ,[Status]
)
SELECT [ServerName]
      ,[DBName]
	  ,[Status]
	  , count(*)/(select [count] from tbl1 where tbl1.[ServerName]=t.[ServerName] and tbl1.[DBName]=t.[DBName] and tbl1.[Status]=t.[Status]) as [AvgCount]
	  , min(InsertUTCDate) as MinInsertUTCDate
  FROM [srv].[vActiveConnectionStatistics] as t
  group by [ServerName]
      ,[DBName]
	  ,[Status]
 --order by [ServerName]
 --     ,[DBName]
	--  ,[Status]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сокращенная информация по активным подключениям по собранным данным', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vActiveConnectionShortStatistics';

