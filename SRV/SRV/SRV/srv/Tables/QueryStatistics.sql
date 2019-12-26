CREATE TABLE [srv].[QueryStatistics] (
    [ID]                     INT            IDENTITY (1, 1) NOT NULL,
    [creation_time]          DATETIME       NOT NULL,
    [last_execution_time]    DATETIME       NOT NULL,
    [execution_count]        BIGINT         NOT NULL,
    [CPU]                    BIGINT         NULL,
    [AvgCPUTime]             MONEY          NULL,
    [TotDuration]            BIGINT         NULL,
    [AvgDur]                 MONEY          NULL,
    [Reads]                  BIGINT         NOT NULL,
    [Writes]                 BIGINT         NOT NULL,
    [AggIO]                  BIGINT         NULL,
    [AvgIO]                  MONEY          NULL,
    [sql_handle]             VARBINARY (64) NOT NULL,
    [plan_handle]            VARBINARY (64) NOT NULL,
    [statement_start_offset] INT            NOT NULL,
    [statement_end_offset]   INT            NOT NULL,
    [database_name]          NVARCHAR (128) NULL,
    [object_name]            NVARCHAR (257) NULL,
    [InsertUTCDate]          DATETIME       CONSTRAINT [DF_QueryStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_QueryStatistics] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE CLUSTERED INDEX [indClustQueryStatistics]
    ON [srv].[QueryStatistics]([creation_time] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[QueryStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [indPlanQuery]
    ON [srv].[QueryStatistics]([plan_handle] ASC, [sql_handle] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кластеризованный неуникальный индекс', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'INDEX', @level2name = N'indClustQueryStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по паре полей (близок к естественному ключу)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'INDEX', @level2name = N'indPlanQuery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Снимки по статистикам экземпляра MS SQL Server (sys.dm_exec_query_stats)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время, когда запрос был скомпилирован', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'creation_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Момент фактического последнего выполнения запроса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'last_execution_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сколько раз запрос был выполнен с момента компиляции', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'execution_count';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Суммарное время использования процессора в миллисекундах', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'CPU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Средняя загрузка процессора на один запрос', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'AvgCPUTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее время выполнения запроса, в миллисекундах', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'TotDuration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Среднее время выполнения запроса в миллисекундах', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'AvgDur';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее количество чтений', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'Reads';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее количество изменений страниц данных', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'Writes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее количество логических операций ввода-вывода (суммарно)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'AggIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Среднее количество логических дисковых операций на одно выполнение запроса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'AvgIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хэш запроса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'sql_handle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хэш плана выполнения', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'plan_handle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начальная позиция запроса, описываемого строкой, в соответствующем тексте пакета или сохраняемом объекте, в байтах, начиная с 0', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'statement_start_offset';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Конечная позиция запроса, описываемого строкой, в соответствующем тексте пакета или сохраняемом объекте, в байтах, начиная с 0.
В версиях до SQL Server 2014 значение -1 обозначает конец пакета. Конечные комментарии больше не включаются', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'statement_end_offset';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'database_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объект', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'object_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryStatistics', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

