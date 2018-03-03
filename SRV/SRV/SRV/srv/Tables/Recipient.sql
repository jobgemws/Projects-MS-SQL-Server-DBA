CREATE TABLE [srv].[Recipient] (
    [Recipient_GUID] UNIQUEIDENTIFIER CONSTRAINT [DF_Recipient_Recipient_GUID] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [Recipient_Name] NVARCHAR (255)   NOT NULL,
    [Recipient_Code] NVARCHAR (10)    NOT NULL,
    [IsDeleted]      BIT              CONSTRAINT [DF_Recipient_IsDeleted] DEFAULT ((0)) NOT NULL,
    [InsertUTCDate]  DATETIME         CONSTRAINT [DF_Recipient_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_Recipient] PRIMARY KEY CLUSTERED ([Recipient_GUID] ASC),
    CONSTRAINT [AK_Recipient_Code] UNIQUE NONCLUSTERED ([Recipient_Code] ASC),
    CONSTRAINT [AK_Recipient_Name] UNIQUE NONCLUSTERED ([Recipient_Name] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[Recipient]([InsertUTCDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Recipient', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адресаты', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Recipient';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Recipient', @level2type = N'COLUMN', @level2name = N'Recipient_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Название адресанта (может быть выражено в почтовом ящике)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Recipient', @level2type = N'COLUMN', @level2name = N'Recipient_Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код адресанта', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Recipient', @level2type = N'COLUMN', @level2name = N'Recipient_Code';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак удаления записи', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Recipient', @level2type = N'COLUMN', @level2name = N'IsDeleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Recipient', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

