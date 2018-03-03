CREATE TABLE [dbo].[TEST] (
    [TEST_GUID]     UNIQUEIDENTIFIER CONSTRAINT [DF_TEST_TEST_GUID] DEFAULT (newid()) NOT NULL,
    [IDENT]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [Field_Name]    NVARCHAR (255)   NULL,
    [Field_Value]   NVARCHAR (255)   NULL,
    [InsertUTCDate] DATETIME         CONSTRAINT [DF_TEST_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_TEST] PRIMARY KEY CLUSTERED ([TEST_GUID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [dbo].[TEST]([InsertUTCDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица для тестов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TEST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (глобальный)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'TEST_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (локальный)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'IDENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Назвние поля/параметра', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'Field_Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Значение поля/параметра', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'Field_Value';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

