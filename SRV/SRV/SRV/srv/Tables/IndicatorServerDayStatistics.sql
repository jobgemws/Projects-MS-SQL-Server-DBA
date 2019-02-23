CREATE TABLE [srv].[IndicatorServerDayStatistics] (
    [Server]             [sysname] NOT NULL,
    [ExecutionCount]     BIGINT    NOT NULL,
    [AvgDur]             MONEY     NOT NULL,
    [AvgCPUTime]         MONEY     NOT NULL,
    [AvgIOLogicalReads]  MONEY     NOT NULL,
    [AvgIOLogicalWrites] MONEY     NOT NULL,
    [AvgIOPhysicalReads] MONEY     NOT NULL,
    [DATE]               DATE      NOT NULL,
    CONSTRAINT [PK_IndicatorServerDayStatistics] PRIMARY KEY CLUSTERED ([DATE] ASC, [Server] ASC) WITH (FILLFACTOR = 95)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индикатор производительности экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorServerDayStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorServerDayStatistics', @level2type = N'COLUMN', @level2name = N'Server';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во вызовов по снимкам активных запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorServerDayStatistics', @level2type = N'COLUMN', @level2name = N'ExecutionCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Среднее время выполнения всех запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorServerDayStatistics', @level2type = N'COLUMN', @level2name = N'AvgDur';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Среднее время выполнения всех запросов суммарно по ЦП', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorServerDayStatistics', @level2type = N'COLUMN', @level2name = N'AvgCPUTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Среднее кол-во логических чтений всех запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorServerDayStatistics', @level2type = N'COLUMN', @level2name = N'AvgIOLogicalReads';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Среднее кол-во записей всех запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorServerDayStatistics', @level2type = N'COLUMN', @level2name = N'AvgIOLogicalWrites';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Среднее кол-во физических чтений всех запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorServerDayStatistics', @level2type = N'COLUMN', @level2name = N'AvgIOPhysicalReads';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата, за какой день считался индикатор', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorServerDayStatistics', @level2type = N'COLUMN', @level2name = N'DATE';

