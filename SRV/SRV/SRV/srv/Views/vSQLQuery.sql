
CREATE view [srv].[vSQLQuery] as 
SELECT [SQLHandle]
      ,[TSQL]
      ,[InsertUTCDate]
  FROM [srv].[SQLQuery]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Запросы', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vSQLQuery';

