CREATE TABLE [srv].[DefragRun] (
    [Run]           BIT      CONSTRAINT [DF_DefragRun_Run] DEFAULT ((0)) NOT NULL,
    [UpdateUTCDate] DATETIME CONSTRAINT [DF_DefragRun_UpdateUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Настройки реорганизации индексов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DefragRun';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак того, что процесс реорганизации индексов запущен', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DefragRun', @level2type = N'COLUMN', @level2name = N'Run';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время изменения записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DefragRun', @level2type = N'COLUMN', @level2name = N'UpdateUTCDate';

