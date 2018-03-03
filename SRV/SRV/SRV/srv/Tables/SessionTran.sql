CREATE TABLE [srv].[SessionTran] (
    [SessionID]              INT      NOT NULL,
    [TransactionID]          BIGINT   NOT NULL,
    [CountTranNotRequest]    TINYINT  CONSTRAINT [DF_SessionTran_Count] DEFAULT ((0)) NOT NULL,
    [CountSessionNotRequest] TINYINT  CONSTRAINT [DF_SessionTran_CountSessionNotRequest] DEFAULT ((0)) NOT NULL,
    [TransactionBeginTime]   DATETIME NOT NULL,
    [InsertUTCDate]          DATETIME CONSTRAINT [DF_SessionTran_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [UpdateUTCDate]          DATETIME CONSTRAINT [DF_SessionTran_UpdateUTCDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_SessionTran] PRIMARY KEY CLUSTERED ([SessionID] ASC, [TransactionID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[SessionTran]([InsertUTCDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SessionTran', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Транзакции, у которых нет активных запросов и их сессии', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SessionTran';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор сессии', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SessionTran', @level2type = N'COLUMN', @level2name = N'SessionID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор транзакции', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SessionTran', @level2type = N'COLUMN', @level2name = N'TransactionID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во раз зафиксированного факта о том, что транзакция была без активных запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SessionTran', @level2type = N'COLUMN', @level2name = N'CountTranNotRequest';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во раз зафиксированного факта о том, что сессия была без активных запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SessionTran', @level2type = N'COLUMN', @level2name = N'CountSessionNotRequest';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время начала транзакции', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SessionTran', @level2type = N'COLUMN', @level2name = N'TransactionBeginTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SessionTran', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время изменения записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'SessionTran', @level2type = N'COLUMN', @level2name = N'UpdateUTCDate';

