CREATE TABLE [srv].[ServerDBFileInfoStatistics] (
    [ServerName]    NVARCHAR (255) NOT NULL,
    [DBName]        NVARCHAR (128) NULL,
    [File_id]       INT            NOT NULL,
    [Type_desc]     NVARCHAR (60)  NULL,
    [FileName]      [sysname]      NOT NULL,
    [Drive]         NVARCHAR (1)   NULL,
    [Ext]           NVARCHAR (3)   NULL,
    [CountPage]     INT            NOT NULL,
    [SizeMb]        FLOAT (53)     NULL,
    [SizeGb]        FLOAT (53)     NULL,
    [InsertUTCDate] DATETIME       CONSTRAINT [DF_ServerDBFileInfoStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[ServerDBFileInfoStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о файлах всех БД на каждый момент времени экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'ServerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'DBName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор файла БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'File_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Описание типа файла БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'Type_desc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Файл БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Метка логического диска', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'Drive';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расширение файла БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'Ext';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во страниц файла БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'CountPage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер файла БД в МБ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'SizeMb';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер файла БД в ГБ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'SizeGb';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ServerDBFileInfoStatistics', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

