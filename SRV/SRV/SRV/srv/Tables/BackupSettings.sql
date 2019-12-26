CREATE TABLE [srv].[BackupSettings] (
    [DBID]           INT            NOT NULL,
    [FullPathBackup] NVARCHAR (255) NOT NULL,
    [DiffPathBackup] NVARCHAR (255) NULL,
    [LogPathBackup]  NVARCHAR (255) NULL,
    [InsertUTCDate]  DATETIME       CONSTRAINT [DF_BackupSettings_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_BackupSettings_1] PRIMARY KEY CLUSTERED ([DBID] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[BackupSettings]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'BackupSettings', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Настройки резервного копирования', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'BackupSettings';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'BackupSettings', @level2type = N'COLUMN', @level2name = N'DBID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный путь к папке для полных резервных копий (если указан, то участвует в полном резервном копировании)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'BackupSettings', @level2type = N'COLUMN', @level2name = N'FullPathBackup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный путь к папке для разностныйх резервных копий (если указан, то участвует в разностном резервном копировании)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'BackupSettings', @level2type = N'COLUMN', @level2name = N'DiffPathBackup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный путь к папке для резервных копий журналов транзакций (если указан, то участвует в создании резервных копий журналов транзакций при условии, что модель восстановления у БД не простая)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'BackupSettings', @level2type = N'COLUMN', @level2name = N'LogPathBackup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'BackupSettings', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

