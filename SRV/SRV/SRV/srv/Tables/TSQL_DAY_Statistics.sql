CREATE TABLE [srv].[TSQL_DAY_Statistics] (
    [command]                          NVARCHAR (32)   NOT NULL,
    [DBName]                           NVARCHAR (128)  NOT NULL,
    [PlanHandle]                       VARBINARY (64)  NOT NULL,
    [SqlHandle]                        VARBINARY (64)  NOT NULL,
    [execution_count]                  BIGINT          NOT NULL,
    [min_wait_timeSec]                 DECIMAL (23, 8) NOT NULL,
    [min_estimated_completion_timeSec] DECIMAL (23, 8) NOT NULL,
    [min_cpu_timeSec]                  DECIMAL (23, 8) NOT NULL,
    [min_total_elapsed_timeSec]        DECIMAL (23, 8) NOT NULL,
    [min_lock_timeoutSec]              DECIMAL (23, 8) NOT NULL,
    [max_wait_timeSec]                 DECIMAL (23, 8) NOT NULL,
    [max_estimated_completion_timeSec] DECIMAL (23, 8) NOT NULL,
    [max_cpu_timeSec]                  DECIMAL (23, 8) NOT NULL,
    [max_total_elapsed_timeSec]        DECIMAL (23, 8) NOT NULL,
    [max_lock_timeoutSec]              DECIMAL (23, 8) NOT NULL,
    [DATE]                             DATE            CONSTRAINT [DF_TSQL_DAY_Statistics_DATE] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indClustered]
    ON [srv].[TSQL_DAY_Statistics]([PlanHandle] ASC, [SqlHandle] ASC, [DATE] ASC);


GO
CREATE NONCLUSTERED INDEX [indDATE]
    ON [srv].[TSQL_DAY_Statistics]([DATE] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индикатор производительности экземпляра MS SQL Server по снимкам активных запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Команда', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'command';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'DBName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хэш плана выполнения', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'PlanHandle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хэш запроса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'SqlHandle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во выполнений', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'execution_count';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минимальное время ожидания в сек', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'min_wait_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минимальное время компиляции в сек', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'min_estimated_completion_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минимальное время ЦП в сек (суммарно по всем ядрам)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'min_cpu_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минимальное время всего выполнения в сек ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'min_total_elapsed_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минимальное время блокировки в сек', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'min_lock_timeoutSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максимальное время ожидания в сек', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'max_wait_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максимальное время компиляции в сек', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'max_estimated_completion_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максимальное время ЦП в сек (суммарно по всем ядрам)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'max_cpu_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максимальное время всего выполнения в сек ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'max_total_elapsed_timeSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максимальное время блокировки в сек', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'max_lock_timeoutSec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата, когда данные собирались', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TSQL_DAY_Statistics', @level2type = N'COLUMN', @level2name = N'DATE';

