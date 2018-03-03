CREATE TABLE [srv].[ddl_log] (
    [DDL_Log_GUID] UNIQUEIDENTIFIER CONSTRAINT [DF_ddl_log_DDL_Log_GUID] DEFAULT (newid()) NOT NULL,
    [PostTime]     DATETIME         NOT NULL,
    [DB_Login]     NVARCHAR (255)   NULL,
    [DB_User]      NVARCHAR (255)   NULL,
    [Event]        NVARCHAR (255)   NULL,
    [TSQL]         NVARCHAR (MAX)   NULL,
    CONSTRAINT [PK_ddl_log] PRIMARY KEY CLUSTERED ([DDL_Log_GUID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Изменения БД (DDL)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log', @level2type = N'COLUMN', @level2name = N'DDL_Log_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время вызова', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log', @level2type = N'COLUMN', @level2name = N'PostTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логин', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log', @level2type = N'COLUMN', @level2name = N'DB_Login';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пользователь', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log', @level2type = N'COLUMN', @level2name = N'DB_User';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Событие', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log', @level2type = N'COLUMN', @level2name = N'Event';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'ddl_log', @level2type = N'COLUMN', @level2name = N'TSQL';

