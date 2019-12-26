CREATE TABLE [srv].[Defrag] (
    [ID]            BIGINT         IDENTITY (1, 1) NOT NULL,
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
    [InsertUTCDate] DATETIME       CONSTRAINT [DF_Defrag_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [Server]        NVARCHAR (255) CONSTRAINT [DF_Defrag_Server] DEFAULT (CONVERT([nvarchar](255),serverproperty(N'MachineName'))) NOT NULL,
    CONSTRAINT [PK_Defrag] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[Defrag]([InsertUTCDate] ASC) WITH (FILLFACTOR = 90);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Index on InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'History about the reorganization of the indexes of all databases of an instance of MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Record ID', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'db';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Scheme', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'shema';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Table', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'table';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Index', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'IndexName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of fragments at the leaf level of the distribution unit IN_ROW_DATA
NULL for non-finite index levels and LOB_DATA or ROW_OVERFLOW_DATA distribution units.

NULL value for heaps if mode = SAMPLED is specified
sys.dm_db_index_physical_stats', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'frag_num';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fragmentation in%', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'frag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number of pages occupied by the index', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'page';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total number of records', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time of the start of the index defragmentation process', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'ts';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time of the end of the index defragmentation process', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'tf';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fragmentation in% after the defragmentation process', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'frag_after';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Object identifier', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'object_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'
Index identifier', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'idx';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time of record creation in UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'Defrag', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

