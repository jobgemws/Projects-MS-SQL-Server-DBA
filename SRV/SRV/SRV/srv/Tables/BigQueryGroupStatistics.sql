CREATE TABLE [srv].[BigQueryGroupStatistics] (
    [Server]              NVARCHAR (128) NOT NULL,
    [creation_time]       DATETIME       NULL,
    [last_execution_time] DATETIME       NULL,
    [execution_count]     BIGINT         NULL,
    [CPU]                 BIGINT         NULL,
    [AvgCPUTime]          MONEY          NULL,
    [TotDuration]         BIGINT         NULL,
    [AvgDur]              MONEY          NULL,
    [AvgIOLogicalReads]   MONEY          NULL,
    [AvgIOLogicalWrites]  MONEY          NULL,
    [AggIO]               BIGINT         NULL,
    [AvgIO]               MONEY          NULL,
    [AvgIOPhysicalReads]  MONEY          NULL,
    [plan_generation_num] BIGINT         NULL,
    [AvgRows]             MONEY          NULL,
    [AvgDop]              MONEY          NULL,
    [AvgGrantKb]          MONEY          NULL,
    [AvgUsedGrantKb]      MONEY          NULL,
    [AvgIdealGrantKb]     MONEY          NULL,
    [AvgReservedThreads]  MONEY          NULL,
    [AvgUsedThreads]      MONEY          NULL,
    [query_text]          NVARCHAR (MAX) NULL,
    [database_name]       NVARCHAR (128) NULL,
    [object_name]         NVARCHAR (257) NULL,
    [query_plan]          XML            NULL,
    [sql_handle]          VARBINARY (64) NULL,
    [plan_handle]         VARBINARY (64) NULL,
    [query_hash]          BINARY (8)     NULL,
    [query_plan_hash]     BINARY (8)     NULL,
    [InsertUTCDate]       DATETIME       NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[BigQueryGroupStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Группировка по тяжелым запросам', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'BigQueryGroupStatistics';

