CREATE TABLE [srv].[OldStatisticsStateStatistics] (
    [Server]              NVARCHAR (128)  NOT NULL,
    [object_id]           INT             NOT NULL,
    [SchemaName]          NVARCHAR (128)  NULL,
    [ObjectName]          [sysname]       NOT NULL,
    [stats_id]            INT             NOT NULL,
    [StatName]            NVARCHAR (128)  NULL,
    [row_count]           BIGINT          NULL,
    [ProcModified]        NUMERIC (18, 3) NULL,
    [ObjectSizeMB]        NUMERIC (38, 2) NULL,
    [type_desc]           NVARCHAR (60)   COLLATE Latin1_General_CI_AS_KS_WS NULL,
    [create_date]         DATETIME        NOT NULL,
    [last_updated]        DATETIME2 (7)   NULL,
    [ModificationCounter] BIGINT          NULL,
    [ProcSampled]         NUMERIC (18, 3) NULL,
    [Func]                FLOAT (53)      NULL,
    [IsScanned]           INT             NOT NULL,
    [ColumnType]          [sysname]       NULL,
    [auto_created]        BIT             NULL,
    [IndexName]           [sysname]       NULL,
    [has_filter]          BIT             NULL,
    [InsertUTCDate]       DATETIME        CONSTRAINT [DF_OldStatisticsStateStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [DataBase]            NVARCHAR (256)  NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[OldStatisticsStateStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Устаревшая статистика', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'OldStatisticsStateStatistics';

