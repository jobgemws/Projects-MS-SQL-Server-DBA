CREATE TABLE [srv].[RestoreSettings] (
    [DBName]          NVARCHAR (255) NOT NULL,
    [FullPathRestore] NVARCHAR (255) NOT NULL,
    [DiffPathRestore] NVARCHAR (255) NOT NULL,
    [LogPathRestore]  NVARCHAR (255) NOT NULL,
    [InsertUTCDate]   DATETIME       CONSTRAINT [DF_RestoreSettings_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_RestoreSettings_1] PRIMARY KEY CLUSTERED ([DBName] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[RestoreSettings]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettings', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Настройки по восстановлению БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettings';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettings', @level2type = N'COLUMN', @level2name = N'DBName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный путь к файлам полных резервных копий (если указано, то БД участвует в процессе восстановления из полной резервной копии)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettings', @level2type = N'COLUMN', @level2name = N'FullPathRestore';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный путь к файлам разностных резервных копий (если указано, то БД участвует в процессе восстановления из разностной резервной копии)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettings', @level2type = N'COLUMN', @level2name = N'DiffPathRestore';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный путь к файлам резервных копий журналов транзакций (если указано, то БД участвует в процессе восстановления журналов транзакций)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettings', @level2type = N'COLUMN', @level2name = N'LogPathRestore';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RestoreSettings', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

