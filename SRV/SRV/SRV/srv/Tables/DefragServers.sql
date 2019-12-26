CREATE TABLE [srv].[DefragServers] (
    [Server]        NVARCHAR (255) NULL,
    [db]            NVARCHAR (255) NOT NULL,
    [shema]         NVARCHAR (255) NOT NULL,
    [table]         NVARCHAR (255) NOT NULL,
    [IndexName]     NVARCHAR (255) NOT NULL,
    [frag_num]      INT            NOT NULL,
    [frag]          DECIMAL (6, 2) NOT NULL,
    [page]          INT            NOT NULL,
    [rec]           INT            NULL,
    [ts]            DATETIME       NOT NULL,
    [tf]            DATETIME       NOT NULL,
    [frag_after]    DECIMAL (6, 2) NOT NULL,
    [object_id]     INT            NOT NULL,
    [idx]           INT            NOT NULL,
    [InsertUTCDate] DATETIME       CONSTRAINT [DF_DefragServers_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[DefragServers]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'История оптимизаций индексов со всех серверов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DefragServers';

