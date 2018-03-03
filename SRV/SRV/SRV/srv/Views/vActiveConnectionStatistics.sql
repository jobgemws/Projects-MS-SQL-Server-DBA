



CREATE view [srv].[vActiveConnectionStatistics] as
SELECT [ServerName]
	  ,[DBName]
      ,[ProgramName]
      ,[LoginName]
      ,[Status]
      ,[SessionID]
	  ,[LoginTime]
	  ,[EndRegUTCDate]
	  ,[InsertUTCDate]
  FROM [srv].[ActiveConnectionStatistics] with(readuncommitted)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по активным подключениям по собранным данных', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vActiveConnectionStatistics';

