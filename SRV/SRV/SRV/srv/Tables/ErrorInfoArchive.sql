CREATE TABLE [srv].[ErrorInfoArchive] (
    [ErrorInfo_GUID]     UNIQUEIDENTIFIER CONSTRAINT [DF_ErrorInfoArchive_ErrorInfo_GUID] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [ERROR_TITLE]        NVARCHAR (MAX)   NULL,
    [ERROR_PRED_MESSAGE] NVARCHAR (MAX)   NULL,
    [ERROR_NUMBER]       NVARCHAR (MAX)   NULL,
    [ERROR_MESSAGE]      NVARCHAR (MAX)   NULL,
    [ERROR_LINE]         NVARCHAR (MAX)   NULL,
    [ERROR_PROCEDURE]    NVARCHAR (MAX)   NULL,
    [ERROR_POST_MESSAGE] NVARCHAR (MAX)   NULL,
    [RECIPIENTS]         NVARCHAR (MAX)   NULL,
    [InsertDate]         DATETIME         CONSTRAINT [DF_ArchiveErrorInfo_InsertDate] DEFAULT (getdate()) NOT NULL,
    [StartDate]          DATETIME         CONSTRAINT [DF_ErrorInfoArchive_StartDate] DEFAULT (getdate()) NOT NULL,
    [FinishDate]         DATETIME         CONSTRAINT [DF_ErrorInfoArchive_FinishDate] DEFAULT (getdate()) NOT NULL,
    [Count]              INT              CONSTRAINT [DF_ErrorInfoArchive_Count] DEFAULT ((1)) NOT NULL,
    [UpdateDate]         DATETIME         CONSTRAINT [DF_ErrorInfoArchive_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [IsRealTime]         BIT              CONSTRAINT [DF_ErrorInfoArchive_IsRealTime] DEFAULT ((0)) NOT NULL,
    [InsertUTCDate]      DATETIME         CONSTRAINT [DF_ErrorInfoArchive_InsertUTCDate] DEFAULT (getutcdate()) NULL,
    CONSTRAINT [PK_ArchiveErrorInfo] PRIMARY KEY CLUSTERED ([ErrorInfo_GUID] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[ErrorInfoArchive]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Архив уведомлений на почту', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'ErrorInfo_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Заголовок уведомления', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'ERROR_TITLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Предкомментарий уведомления', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'ERROR_PRED_MESSAGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код ошибки/уведомления', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'ERROR_NUMBER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Текст уведомления', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'ERROR_MESSAGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер строки ошибки/уведомления', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'ERROR_LINE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хранимая процедура', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'ERROR_PROCEDURE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Посткомментарий уведомления', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'ERROR_POST_MESSAGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адресанты через ;', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'RECIPIENTS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'InsertDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начало', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'StartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Окончание', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'FinishDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во раз', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'Count';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время обновления записи', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'UpdateDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак того, что уведомление реального времени (т е нужно обработать как можно быстрее)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'IsRealTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ErrorInfoArchive', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

