CREATE TABLE [srv].[DBFile] (
    [DBFile_GUID]     UNIQUEIDENTIFIER CONSTRAINT [DF_DBFile_DBFile_GUID] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [Server]          NVARCHAR (255)   NOT NULL,
    [Name]            NVARCHAR (255)   NOT NULL,
    [Drive]           NVARCHAR (10)    NOT NULL,
    [Physical_Name]   NVARCHAR (255)   NOT NULL,
    [Ext]             NVARCHAR (255)   NOT NULL,
    [Growth]          INT              NOT NULL,
    [IsPercentGrowth] INT              NOT NULL,
    [DB_ID]           INT              NOT NULL,
    [DB_Name]         NVARCHAR (255)   NOT NULL,
    [SizeMb]          FLOAT (53)       NOT NULL,
    [DiffSizeMb]      FLOAT (53)       NOT NULL,
    [InsertUTCDate]   DATETIME         CONSTRAINT [DF_DBFile_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [UpdateUTCdate]   DATETIME         CONSTRAINT [DF_DBFile_UpdateUTCdate] DEFAULT (getutcdate()) NOT NULL,
    [File_ID]         INT              NOT NULL,
    CONSTRAINT [PK_DBFile] PRIMARY KEY CLUSTERED ([DBFile_GUID] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DBFile]
    ON [srv].[DBFile]([DB_ID] ASC, [File_ID] ASC, [Server] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Уникальный индекс (естественный ключ)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'INDEX', @level2name = N'IX_DBFile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по файлам БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор файла БД (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'DBFile_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'Server';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Название файла', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Диск, на котором расположен файл', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'Drive';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный путь к файлу', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'Physical_Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расширение файла', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'Ext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Прирост', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'Growth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак того, что прирост в процентах', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'IsPercentGrowth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'DB_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Название БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'DB_Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер в МБ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'SizeMb';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Изменение размера в МБ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'DiffSizeMb';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время изменения записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'UpdateUTCdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор файла БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFile', @level2type = N'COLUMN', @level2name = N'File_ID';

