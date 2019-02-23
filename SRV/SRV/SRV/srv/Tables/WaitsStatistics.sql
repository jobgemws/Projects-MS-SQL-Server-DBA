CREATE TABLE [srv].[WaitsStatistics] (
    [Server]        NVARCHAR (128)  NOT NULL,
    [WaitType]      NVARCHAR (60)   NOT NULL,
    [Wait_S]        DECIMAL (16, 2) NOT NULL,
    [Resource_S]    DECIMAL (16, 2) NOT NULL,
    [Signal_S]      DECIMAL (16, 2) NOT NULL,
    [WaitCount]     BIGINT          NOT NULL,
    [Percentage]    DECIMAL (5, 2)  NOT NULL,
    [AvgWait_S]     DECIMAL (16, 4) NOT NULL,
    [AvgRes_S]      DECIMAL (16, 4) NOT NULL,
    [AvgSig_S]      DECIMAL (16, 4) NOT NULL,
    [InsertUTCDate] DATETIME        CONSTRAINT [DF_WaitsStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[WaitsStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);

