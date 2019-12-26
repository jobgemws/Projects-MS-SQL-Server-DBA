CREATE TABLE [srv].[RestoreSettingsDetail] (
    [Row_GUID]          UNIQUEIDENTIFIER CONSTRAINT [DF_RestoreSettingsDetail_Row_GUID] DEFAULT (newid()) NOT NULL,
    [DBName]            NVARCHAR (255)   NOT NULL,
    [SourcePathRestore] NVARCHAR (255)   NOT NULL,
    [TargetPathRestore] NVARCHAR (255)   NOT NULL,
    [Ext]               NVARCHAR (255)   NOT NULL,
    [InsertUTCDate]     DATETIME         CONSTRAINT [DF_RestoreSettingsDetail_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_RestoreSettingsDetail_1] PRIMARY KEY CLUSTERED ([Row_GUID] ASC) WITH (FILLFACTOR = 95)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Детальные настройки по восстановлению БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettingsDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettingsDetail', @level2type = N'COLUMN', @level2name = N'Row_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettingsDetail', @level2type = N'COLUMN', @level2name = N'DBName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный путь к файлам резервных копий', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettingsDetail', @level2type = N'COLUMN', @level2name = N'SourcePathRestore';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный путь к файлам, куда будет восстановлена БД (без расширения)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettingsDetail', @level2type = N'COLUMN', @level2name = N'TargetPathRestore';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расширение файла', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettingsDetail', @level2type = N'COLUMN', @level2name = N'Ext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettingsDetail', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

