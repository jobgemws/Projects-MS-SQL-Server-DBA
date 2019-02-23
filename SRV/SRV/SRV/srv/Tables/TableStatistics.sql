CREATE TABLE [srv].[TableStatistics] (
    [ServerName]          NVARCHAR (255) NOT NULL,
    [DBName]              NVARCHAR (255) NOT NULL,
    [SchemaName]          NVARCHAR (255) NOT NULL,
    [TableName]           NVARCHAR (255) NOT NULL,
    [CountRows]           BIGINT         NOT NULL,
    [DataKB]              INT            NOT NULL,
    [IndexSizeKB]         INT            NOT NULL,
    [UnusedKB]            INT            NOT NULL,
    [ReservedKB]          INT            NOT NULL,
    [InsertUTCDate]       DATETIME       CONSTRAINT [DF_TableStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [Date]                AS             (CONVERT([date],[InsertUTCDate])) PERSISTED,
    [CountRowsBack]       BIGINT         NULL,
    [CountRowsNext]       BIGINT         NULL,
    [DataKBBack]          INT            NULL,
    [DataKBNext]          INT            NULL,
    [IndexSizeKBBack]     INT            NULL,
    [IndexSizeKBNext]     INT            NULL,
    [UnusedKBBack]        INT            NULL,
    [UnusedKBNext]        INT            NULL,
    [ReservedKBBack]      INT            NULL,
    [ReservedKBNext]      INT            NULL,
    [AvgCountRows]        AS             ((([CountRowsBack]+[CountRows])+[CountRowsNext])/(3)) PERSISTED,
    [AvgDataKB]           AS             ((([DataKBBack]+[DataKB])+[DataKBNext])/(3)) PERSISTED,
    [AvgIndexSizeKB]      AS             ((([IndexSizeKBBack]+[IndexSizeKB])+[IndexSizeKBNext])/(3)) PERSISTED,
    [AvgUnusedKB]         AS             ((([UnusedKBBack]+[UnusedKB])+[UnusedKBNext])/(3)) PERSISTED,
    [AvgReservedKB]       AS             ((([ReservedKBBack]+[ReservedKB])+[ReservedKBNext])/(3)) PERSISTED,
    [DiffCountRows]       AS             (([CountRowsNext]+[CountRowsBack])-(2)*[CountRows]) PERSISTED,
    [DiffDataKB]          AS             (([DataKBNext]+[DataKBBack])-(2)*[DataKB]) PERSISTED,
    [DiffIndexSizeKB]     AS             (([IndexSizeKBNext]+[IndexSizeKBBack])-(2)*[IndexSizeKB]) PERSISTED,
    [DiffUnusedKB]        AS             (([UnusedKBNext]+[UnusedKBBack])-(2)*[UnusedKB]) PERSISTED,
    [DiffReservedKB]      AS             (([ReservedKBNext]+[ReservedKBBack])-(2)*[ReservedKB]) PERSISTED,
    [TotalPageSizeKB]     INT            NULL,
    [TotalPageSizeKBBack] INT            NULL,
    [TotalPageSizeKBNext] INT            NULL,
    [UsedPageSizeKB]      INT            NULL,
    [UsedPageSizeKBBack]  INT            NULL,
    [UsedPageSizeKBNext]  INT            NULL,
    [DataPageSizeKB]      INT            NULL,
    [DataPageSizeKBBack]  INT            NULL,
    [DataPageSizeKBNext]  INT            NULL,
    [AvgDataPageSizeKB]   AS             ((([DataPageSizeKBBack]+[DataPageSizeKB])+[DataPageSizeKBNext])/(3)) PERSISTED,
    [AvgUsedPageSizeKB]   AS             ((([UsedPageSizeKBBack]+[UsedPageSizeKB])+[UsedPageSizeKBNext])/(3)) PERSISTED,
    [AvgTotalPageSizeKB]  AS             ((([TotalPageSizeKBBack]+[TotalPageSizeKB])+[TotalPageSizeKBNext])/(3)) PERSISTED,
    [DiffDataPageSizeKB]  AS             (([DataPageSizeKBNext]+[DataPageSizeKBBack])-(2)*[DataPageSizeKB]) PERSISTED,
    [DiffUsedPageSizeKB]  AS             (([UsedPageSizeKBNext]+[UsedPageSizeKBBack])-(2)*[UsedPageSizeKB]) PERSISTED,
    [DiffTotalPageSizeKB] AS             (([TotalPageSizeKBNext]+[TotalPageSizeKBBack])-(2)*[TotalPageSizeKB]) PERSISTED
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[TableStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о размерах таблицы на каждый момент времени экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'ServerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DBName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Схема', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'SchemaName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во строк', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'CountRows';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер данных в КБ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DataKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер индексов в КБ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'IndexSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер неиспользуемого места в КБ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'UnusedKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Зарезервировано в КБ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'ReservedKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата создания записи', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'Date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во строк за предыдущий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'CountRowsBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во строк за последующий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'CountRowsNext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер данных в КБ за предыдущий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DataKBBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер данных в КБ за последующий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DataKBNext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер индексов в КБ за предыдущий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'IndexSizeKBBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер индексов в КБ за последующий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'IndexSizeKBNext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер неиспользуемого места в КБ за предыдущий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'UnusedKBBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер неиспользуемого места в КБ за последующий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'UnusedKBNext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер зарезервированного места в КБ за предыдущий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'ReservedKBBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер зарезервированного места в КБ за последующий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'ReservedKBNext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Средний показатель  CountRows', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'AvgCountRows';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Средний показатель  DataKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'AvgDataKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Средний показатель  IndexSizeKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'AvgIndexSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Средний показатель  UnusedKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'AvgUnusedKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Средний показатель  ReservedKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'AvgReservedKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приращение показателя  CountRows', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DiffCountRows';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приращение показателя  DataKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DiffDataKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приращение показателя  IndexSizeKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DiffIndexSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приращение показателя  UnusedKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DiffUnusedKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приращение показателя  ReservedKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DiffReservedKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Весь размер таблицы в КБ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'TotalPageSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Весь размер таблицы в КБ за предыдущий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'TotalPageSizeKBBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Весь размер таблицы в КБ за последующий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'TotalPageSizeKBNext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее кол-во используемых страниц (размер в КБ)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'UsedPageSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее кол-во используемых страниц (размер в КБ) за предыдущий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'UsedPageSizeKBBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее кол-во используемых страниц (размер в КБ) за последующий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'UsedPageSizeKBNext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во страниц под данные (размер в КБ)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DataPageSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во страниц под данные (размер в КБ) за предыдущий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DataPageSizeKBBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во страниц под данные (размер в КБ) за последущий день', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DataPageSizeKBNext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Средний показатель DataPageSizeKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'AvgDataPageSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Средний показатель UsedPageSizeKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'AvgUsedPageSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Средний показатель TotalPageSizeKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'AvgTotalPageSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приращение показателя  DataPageSizeKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DiffDataPageSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приращение показателя  UsedPageSizeKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DiffUsedPageSizeKB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приращение показателя  TotalPageSizeKB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableStatistics', @level2type = N'COLUMN', @level2name = N'DiffTotalPageSizeKB';

