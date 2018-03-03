CREATE TABLE [srv].[ShortInfoRunJobs] (
    [Job_GUID]              UNIQUEIDENTIFIER NOT NULL,
    [Job_Name]              NVARCHAR (255)   NOT NULL,
    [LastFinishRunState]    NVARCHAR (255)   NULL,
    [LastDateTime]          DATETIME         NOT NULL,
    [LastRunDurationString] NVARCHAR (255)   NULL,
    [LastRunDurationInt]    INT              NULL,
    [LastOutcomeMessage]    NVARCHAR (255)   NULL,
    [LastRunOutcome]        TINYINT          NOT NULL,
    [Server]                NVARCHAR (255)   NOT NULL,
    [InsertUTCDate]         DATETIME         CONSTRAINT [DF_ShortInfoRunJobs_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [ID]                    INT              IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_ShortInfoRunJobs] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[ShortInfoRunJobs]([InsertUTCDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Краткая информация о заданиях, которые выполнились либо с ошибкой, либо слишком долго (более 30 секунд)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор задачи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'Job_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Задание', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'Job_Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последнее состояние задачи при выполнении', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'LastFinishRunState';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последнее время запуска задания', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'LastDateTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последняя продолжительность выполнения задания в виде строки', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'LastRunDurationString';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последняя продолжительность выполнения задания в виде числа', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'LastRunDurationInt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последнее сообщение о выполненном задании', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'LastOutcomeMessage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Результат последнего выполнения задания', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'LastRunOutcome';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'Server';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobs', @level2type = N'COLUMN', @level2name = N'ID';

