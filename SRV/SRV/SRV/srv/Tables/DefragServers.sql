CREATE TABLE [srv].[DefragServers] (
    [Server]        NVARCHAR (128) NULL,
    [db]            NVARCHAR (100) NOT NULL,
    [shema]         NVARCHAR (100) NOT NULL,
    [table]         NVARCHAR (100) NOT NULL,
    [IndexName]     NVARCHAR (100) NOT NULL,
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

