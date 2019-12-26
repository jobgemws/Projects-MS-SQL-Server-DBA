CREATE TABLE [srv].[IndexDefragStatistics] (
    [Server]          NVARCHAR (128) NOT NULL,
    [db]              NVARCHAR (128) NULL,
    [shema]           NVARCHAR (128) NULL,
    [tb]              [sysname]      NOT NULL,
    [idx]             INT            NULL,
    [database_id]     SMALLINT       NULL,
    [index_name]      [sysname]      NULL,
    [index_type_desc] NVARCHAR (60)  NULL,
    [level]           TINYINT        NULL,
    [object_id]       INT            NULL,
    [frag_num]        BIGINT         NULL,
    [frag]            FLOAT (53)     NULL,
    [frag_page]       FLOAT (53)     NULL,
    [page]            BIGINT         NULL,
    [rec]             BIGINT         NULL,
    [ghost]           BIGINT         NULL,
    [func]            FLOAT (53)     NULL,
    [InsertUTCDate]   DATETIME       CONSTRAINT [DF_IndexDefragStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[IndexDefragStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статистика степени фрагментации индексов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'IndexDefragStatistics';

