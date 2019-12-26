CREATE TABLE [srv].[Address] (
    [Address_GUID]   UNIQUEIDENTIFIER CONSTRAINT [DF_Address_Address_GUID] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [Recipient_GUID] UNIQUEIDENTIFIER NOT NULL,
    [Address]        NVARCHAR (255)   NOT NULL,
    [IsDeleted]      BIT              CONSTRAINT [DF_Address_IsDeleted] DEFAULT ((0)) NOT NULL,
    [InsertUTCDate]  DATETIME         CONSTRAINT [DF_Address_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED ([Address_GUID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [AK_Address] UNIQUE NONCLUSTERED ([Recipient_GUID] ASC, [Address] ASC) WITH (FILLFACTOR = 95)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Почтовые адреса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор почтового адреса (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Address', @level2type = N'COLUMN', @level2name = N'Address_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор адресатора (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Address', @level2type = N'COLUMN', @level2name = N'Recipient_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Почтовый адрес', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Address', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак удаления записи', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Address', @level2type = N'COLUMN', @level2name = N'IsDeleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Address', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

