CREATE TABLE [srv].[TableIndexStatistics] (
    [Row_GUID]           UNIQUEIDENTIFIER CONSTRAINT [DF_TableIndexStatistics_Row_GUID] DEFAULT (newid()) NOT NULL,
    [ServerName]         NVARCHAR (255)   NOT NULL,
    [DBName]             NVARCHAR (255)   NULL,
    [SchemaName]         NVARCHAR (255)   NULL,
    [TableName]          NVARCHAR (255)   NULL,
    [IndexUsedForCounts] NVARCHAR (255)   NULL,
    [CountRows]          BIGINT           NULL,
    [InsertUTCDate]      DATETIME         CONSTRAINT [DF_TableIndexStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_TableIndexStatistics] PRIMARY KEY CLUSTERED ([Row_GUID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[TableIndexStatistics]([InsertUTCDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о размерах индексов таблицы на каждый момент времени экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics', @level2type = N'COLUMN', @level2name = N'Row_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics', @level2type = N'COLUMN', @level2name = N'ServerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics', @level2type = N'COLUMN', @level2name = N'DBName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Схема', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics', @level2type = N'COLUMN', @level2name = N'SchemaName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics', @level2type = N'COLUMN', @level2name = N'TableName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Название индекса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics', @level2type = N'COLUMN', @level2name = N'IndexUsedForCounts';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во строк', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics', @level2type = N'COLUMN', @level2name = N'CountRows';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'TableIndexStatistics', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

