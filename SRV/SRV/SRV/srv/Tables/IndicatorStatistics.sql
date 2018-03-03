CREATE TABLE [srv].[IndicatorStatistics] (
    [execution_count]               BIGINT          NOT NULL,
    [max_total_elapsed_timeSec]     DECIMAL (38, 6) NOT NULL,
    [max_total_elapsed_timeLastSec] DECIMAL (38, 6) NOT NULL,
    [execution_countStatistics]     BIGINT          NOT NULL,
    [max_AvgDur_timeSec]            DECIMAL (38, 6) NOT NULL,
    [max_AvgDur_timeLastSec]        DECIMAL (38, 6) NOT NULL,
    [DATE]                          DATE            NOT NULL,
    CONSTRAINT [PK_IndicatorStatistics] PRIMARY KEY CLUSTERED ([DATE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индикатор производительности экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во вызовов по снимкам активных запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorStatistics', @level2type = N'COLUMN', @level2name = N'execution_count';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максимальное суммарное кол-во времени в сек, затраченное на обработку по снимкам активных запросов за предыдущий период', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorStatistics', @level2type = N'COLUMN', @level2name = N'max_total_elapsed_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максимальное суммарное кол-во времени в сек, затраченное на обработку по снимкам активных запросов за дату DATE', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorStatistics', @level2type = N'COLUMN', @level2name = N'max_total_elapsed_timeLastSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во вызовов по статистике экземпляра MS SQL SERVER', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorStatistics', @level2type = N'COLUMN', @level2name = N'execution_countStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максмимальное из средних времен выполнения в сек, затраченное на обработку за предыдущий период', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorStatistics', @level2type = N'COLUMN', @level2name = N'max_AvgDur_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максмимальное из средних времен выполнения в сек, затраченное на обработку за дату DATE', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorStatistics', @level2type = N'COLUMN', @level2name = N'max_AvgDur_timeLastSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата, за какой день считался индикатор', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndicatorStatistics', @level2type = N'COLUMN', @level2name = N'DATE';

