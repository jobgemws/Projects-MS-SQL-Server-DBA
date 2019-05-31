CREATE TABLE [srv].[ListDefragIndex] (
    [db]            NVARCHAR (255) NOT NULL,
    [shema]         NVARCHAR (255) NOT NULL,
    [table]         NVARCHAR (255) NOT NULL,
    [IndexName]     NVARCHAR (255) NOT NULL,
    [object_id]     INT            NOT NULL,
    [idx]           INT            NOT NULL,
    [db_id]         INT            NOT NULL,
    [frag]          DECIMAL (6, 2) NOT NULL,
    [InsertUTCDate] DATETIME       CONSTRAINT [DF_ListDefragIndex_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_ListDefragIndex] PRIMARY KEY CLUSTERED ([object_id] ASC, [idx] ASC, [db_id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[ListDefragIndex]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Список индексов, прошедших реорганизацию в одной итерации', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex', @level2type = N'COLUMN', @level2name = N'db';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Схема', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex', @level2type = N'COLUMN', @level2name = N'shema';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex', @level2type = N'COLUMN', @level2name = N'table';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex', @level2type = N'COLUMN', @level2name = N'IndexName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор объекта', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex', @level2type = N'COLUMN', @level2name = N'object_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор индекса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex', @level2type = N'COLUMN', @level2name = N'idx';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex', @level2type = N'COLUMN', @level2name = N'db_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ListDefragIndex', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

