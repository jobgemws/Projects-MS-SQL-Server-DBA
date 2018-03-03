CREATE TABLE [srv].[Defrag] (
    [ID]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [db]            NVARCHAR (100) NOT NULL,
    [shema]         NVARCHAR (100) NOT NULL,
    [table]         NVARCHAR (100) NOT NULL,
    [IndexName]     NVARCHAR (100) NOT NULL,
    [frag_num]      INT            NOT NULL,
    [frag]          DECIMAL (6, 2) NOT NULL,
    [page]          INT            NOT NULL,
    [rec]           INT            NULL,
    [ts]            DATETIME       NOT NULL,
    [tf]            DATETIME       NOT NULL,
    [frag_after]    DECIMAL (6, 2) NOT NULL,
    [object_id]     INT            NOT NULL,
    [idx]           INT            NOT NULL,
    [InsertUTCDate] DATETIME       CONSTRAINT [DF_Defrag_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_Defrag] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[Defrag]([InsertUTCDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IndMain]
    ON [srv].[Defrag]([db] ASC, [shema] ASC, [table] ASC, [IndexName] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по набору (неуникальный, естественный индекс)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'INDEX', @level2name = N'IndMain';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'История про реорганизацию индексов всех БД экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'db';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Схема', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'shema';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'table';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'IndexName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество фрагментов на конечном уровне единицы распределения IN_ROW_DATA
NULL для неконечных уровней индекса и единиц распределения LOB_DATA или ROW_OVERFLOW_DATA.

Значение NULL для куч, если указан режим = SAMPLED
sys.dm_db_index_physical_stats', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'frag_num';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фрагментация в %', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'frag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во страниц, занимаемых индексом', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'page';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее количество записей', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время начала процесса дефрагментации индекса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'ts';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время окончания процесса дефрагментации индекса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'tf';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фрагментация в % после процесса дефрагментации', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'frag_after';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор объекта', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'object_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатоор индекса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'idx';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

