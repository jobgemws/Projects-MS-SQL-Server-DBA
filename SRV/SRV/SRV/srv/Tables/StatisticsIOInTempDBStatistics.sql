CREATE TABLE [srv].[StatisticsIOInTempDBStatistics] (
    [Server]             NVARCHAR (128)   NOT NULL,
    [physical_name]      NVARCHAR (260)   NOT NULL,
    [name]               [sysname]        NOT NULL,
    [num_of_writes]      BIGINT           NOT NULL,
    [avg_write_stall_ms] NUMERIC (38, 17) NULL,
    [num_of_reads]       BIGINT           NOT NULL,
    [avg_read_stall_ms]  NUMERIC (38, 17) NULL,
    [InsertUTCDate]      DATETIME         CONSTRAINT [DF_StatisticsIOInTempDBStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[StatisticsIOInTempDBStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);

