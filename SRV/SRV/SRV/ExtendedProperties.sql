EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'База данных для администрирования
Версия для MS SQL Server 2016-2017 (также полностью или частично поддерживается MS SQL Server 2012-2014).
Поддержка всех версий до версии MS SQL Server 2012 может быть не на достаточном уровне для использования в производственной среде.
Необходимые типовые задания см. в ХП inf.InfoAgentJobs.';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор объекта', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'FUNCTION', @level1name = N'GetPlansObject', @level2type = N'PARAMETER', @level2name = N'@ObjectID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор БД', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'FUNCTION', @level1name = N'GetPlansObject', @level2type = N'PARAMETER', @level2name = N'@DBID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetDateFormat', @level2type = N'PARAMETER', @level2name = N'@dt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Формат:
0: "dd.mm.yyyy"
1: "mm.yyyy"
2: "yyyy"', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetDateFormat', @level2type = N'PARAMETER', @level2name = N'@format';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер месяца в году', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetNameMonth', @level2type = N'PARAMETER', @level2name = N'@Month_Num';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Название месяца', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetNumMonth', @level2type = N'PARAMETER', @level2name = N'@Month_Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetTimeFormat', @level2type = N'PARAMETER', @level2name = N'@dt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Формат:
0: "hh:mm:ss"
1: "hh:mm"
2: "hh"', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetTimeFormat', @level2type = N'PARAMETER', @level2name = N'@format';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'старость запущенной транзакции в минутах', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoKillSessionTranBegin', @level2type = N'PARAMETER', @level2name = N'@minuteOld';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во попаданий в таблицу', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoKillSessionTranBegin', @level2type = N'PARAMETER', @level2name = N'@countIsNotRequests';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число в виде строки', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'FUNCTION', @level1name = N'GetNumericNormalize', @level2type = N'PARAMETER', @level2name = N'@str';

