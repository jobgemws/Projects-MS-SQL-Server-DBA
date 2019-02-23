CREATE TABLE [srv].[ShortInfoRunJobsServers] (
    [Job_GUID]              UNIQUEIDENTIFIER NOT NULL,
    [Job_Name]              NVARCHAR (255)   NOT NULL,
    [LastFinishRunState]    NVARCHAR (255)   NULL,
    [LastRunDurationString] NVARCHAR (255)   NULL,
    [LastRunDurationInt]    INT              NULL,
    [LastOutcomeMessage]    NVARCHAR (255)   NULL,
    [LastRunOutcome]        TINYINT          NOT NULL,
    [Server]                NVARCHAR (255)   NOT NULL,
    [InsertUTCDate]         DATETIME         CONSTRAINT [DF_ShortInfoRunJobsServers_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [TargetServer]          [sysname]        NULL,
    [LastDateTime]          DATETIME         NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[ShortInfoRunJobsServers]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Краткая информация о заданиях, которые выполнились либо с ошибкой, либо слишком долго (более 30 секунд)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор задачи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers', @level2type = N'COLUMN', @level2name = N'Job_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Задание', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers', @level2type = N'COLUMN', @level2name = N'Job_Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последнее состояние задачи при выполнении', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers', @level2type = N'COLUMN', @level2name = N'LastFinishRunState';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последняя продолжительность выполнения задания в виде строки', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers', @level2type = N'COLUMN', @level2name = N'LastRunDurationString';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последняя продолжительность выполнения задания в виде числа', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers', @level2type = N'COLUMN', @level2name = N'LastRunDurationInt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последнее сообщение о выполненном задании', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers', @level2type = N'COLUMN', @level2name = N'LastOutcomeMessage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Результат последнего выполнения задания', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers', @level2type = N'COLUMN', @level2name = N'LastRunOutcome';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers', @level2type = N'COLUMN', @level2name = N'Server';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ShortInfoRunJobsServers', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

