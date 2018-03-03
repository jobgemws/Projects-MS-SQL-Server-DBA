CREATE TABLE [srv].[Drivers] (
    [Driver_GUID]   UNIQUEIDENTIFIER CONSTRAINT [DF_Drivers_Driver_GUID] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [Server]        NVARCHAR (255)   CONSTRAINT [DF_Drivers_Server] DEFAULT (@@servername) NOT NULL,
    [Name]          NVARCHAR (8)     NOT NULL,
    [TotalSpace]    FLOAT (53)       CONSTRAINT [DF_Drivers_TotalSpace] DEFAULT ((0)) NOT NULL,
    [FreeSpace]     FLOAT (53)       CONSTRAINT [DF_Drivers_FreeSpace] DEFAULT ((0)) NOT NULL,
    [DiffFreeSpace] FLOAT (53)       CONSTRAINT [DF_Drivers_DiffFreeSpace] DEFAULT ((0)) NOT NULL,
    [InsertUTCDate] DATETIME         CONSTRAINT [DF_Drivers_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [UpdateUTCdate] DATETIME         CONSTRAINT [DF_Drivers_UpdateUTCdate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_Drivers] PRIMARY KEY CLUSTERED ([Driver_GUID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[Drivers]([InsertUTCDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по логическим дискам (работает не полностью, не доработано, т к не используется)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи (глобальный)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'Driver_GUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'Server';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логическая метка диска', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Весь объем логического диска в байтах', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'TotalSpace';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Весь свободный объем логического диска в байтах', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'FreeSpace';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Изменение свободного объема логического диска', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'DiffFreeSpace';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время изменения записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'UpdateUTCdate';

