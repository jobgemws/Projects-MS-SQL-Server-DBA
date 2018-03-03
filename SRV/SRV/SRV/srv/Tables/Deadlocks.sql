CREATE TABLE [srv].[Deadlocks] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [Server]          NVARCHAR (20) NULL,
    [NumberDeadlocks] INT           NULL,
    [InsertDate]      DATETIME      CONSTRAINT [DF_Deadlocks_InsertDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Deadlocks] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertDate]
    ON [srv].[Deadlocks]([InsertDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Deadlocks', @level2type = N'INDEX', @level2name = N'indInsertDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Взаимоблокировки', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Deadlocks';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Deadlocks', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Deadlocks', @level2type = N'COLUMN', @level2name = N'Server';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во взаимоблокировок', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Deadlocks', @level2type = N'COLUMN', @level2name = N'NumberDeadlocks';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Deadlocks', @level2type = N'COLUMN', @level2name = N'InsertDate';

