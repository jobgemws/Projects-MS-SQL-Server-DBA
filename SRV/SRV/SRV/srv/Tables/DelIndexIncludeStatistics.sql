CREATE TABLE [srv].[DelIndexIncludeStatistics] (
    [Server]                      NVARCHAR (128) NOT NULL,
    [SchemaName]                  [sysname]      NOT NULL,
    [ObjectName]                  [sysname]      NOT NULL,
    [ObjectType]                  NVARCHAR (60)  COLLATE Latin1_General_CI_AS_KS_WS NULL,
    [ObjectCreateDate]            DATETIME       NOT NULL,
    [DelIndexName]                [sysname]      NULL,
    [IndexIsPrimaryKey]           BIT            NULL,
    [IndexType]                   NVARCHAR (60)  NULL,
    [IndexFragmentation]          FLOAT (53)     NULL,
    [IndexFragmentCount]          BIGINT         NULL,
    [IndexAvgFragmentSizeInPages] FLOAT (53)     NULL,
    [IndexPages]                  BIGINT         NULL,
    [IndexKeyColumns]             NVARCHAR (MAX) NULL,
    [IndexIncludedColumns]        NVARCHAR (MAX) NULL,
    [ActualIndexName]             [sysname]      NULL,
    [InsertUTCDate]               DATETIME       CONSTRAINT [DF_DelIndexIncludeStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [DataBase]                    NVARCHAR (256) NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[DelIndexIncludeStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);

