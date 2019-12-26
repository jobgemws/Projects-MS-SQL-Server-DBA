CREATE TABLE [srv].[SQLQuery] (
    [SQLHandle]     VARBINARY (64) NOT NULL,
    [TSQL]          NVARCHAR (MAX) NULL,
    [InsertUTCDate] DATETIME       CONSTRAINT [DF_SQLQuery_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_SQLQuery] PRIMARY KEY CLUSTERED ([SQLHandle] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[SQLQuery]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Запросы', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SQLQuery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хэш запроса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SQLQuery', @level2type = N'COLUMN', @level2name = N'SQLHandle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Запрос', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SQLQuery', @level2type = N'COLUMN', @level2name = N'TSQL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SQLQuery', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

