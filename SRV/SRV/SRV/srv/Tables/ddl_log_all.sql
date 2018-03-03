CREATE TABLE [srv].[ddl_log_all] (
    [DDL_Log_GUID]  UNIQUEIDENTIFIER CONSTRAINT [DF_ddl_log_all_DDL_Log_GUID] DEFAULT (newid()) NOT NULL,
    [Server_Name]   NVARCHAR (255)   NOT NULL,
    [DB_Name]       NVARCHAR (255)   NOT NULL,
    [PostTime]      DATETIME         NOT NULL,
    [DB_Login]      NVARCHAR (255)   NULL,
    [DB_User]       NVARCHAR (255)   NULL,
    [Event]         NVARCHAR (255)   NULL,
    [TSQL]          NVARCHAR (MAX)   NULL,
    [InsertUTCDate] DATETIME         CONSTRAINT [DF_ddl_log_all_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_ddl_log_all] PRIMARY KEY CLUSTERED ([DDL_Log_GUID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[ddl_log_all]([InsertUTCDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Изменения по всем БД (DDL)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'COLUMN', @level2name = N'DDL_Log_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'COLUMN', @level2name = N'Server_Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'COLUMN', @level2name = N'DB_Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время регистрации', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'COLUMN', @level2name = N'PostTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логин', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'COLUMN', @level2name = N'DB_Login';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пользователь', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'COLUMN', @level2name = N'DB_User';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Событие', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'COLUMN', @level2name = N'Event';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'COLUMN', @level2name = N'TSQL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log_all', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

