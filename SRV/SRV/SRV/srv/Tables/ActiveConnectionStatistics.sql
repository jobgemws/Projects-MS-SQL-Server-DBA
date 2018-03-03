CREATE TABLE [srv].[ActiveConnectionStatistics] (
    [Row_GUID]      UNIQUEIDENTIFIER CONSTRAINT [DF_ActiveConnectionStatistics_Row_GUID] DEFAULT (newid()) NOT NULL,
    [ServerName]    NVARCHAR (255)   NOT NULL,
    [SessionID]     INT              NOT NULL,
    [LoginName]     NCHAR (128)      NOT NULL,
    [DBName]        NVARCHAR (128)   NULL,
    [ProgramName]   NVARCHAR (255)   NULL,
    [Status]        NCHAR (30)       NOT NULL,
    [LoginTime]     DATETIME         NOT NULL,
    [EndRegUTCDate] DATETIME         NULL,
    [InsertUTCDate] DATETIME         CONSTRAINT [DF_ActiveConnectionStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_ActiveConnectionStatistics] PRIMARY KEY CLUSTERED ([Row_GUID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[ActiveConnectionStatistics]([InsertUTCDate] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [indSession]
    ON [srv].[ActiveConnectionStatistics]([ServerName] ASC, [SessionID] ASC, [LoginName] ASC, [DBName] ASC, [LoginTime] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'История активных подключений', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'Row_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Название сервера', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'ServerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор сессии', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'SessionID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логин', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'LoginName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'База данных', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'DBName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Программа', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'ProgramName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Состояние сеанса
sys.dm_exec_sessions ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время подключения', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'LoginTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время зарегистрированного окончания подключения', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'EndRegUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ActiveConnectionStatistics', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

