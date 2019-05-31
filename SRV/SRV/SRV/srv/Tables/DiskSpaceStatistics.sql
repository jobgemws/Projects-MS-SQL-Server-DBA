CREATE TABLE [srv].[DiskSpaceStatistics] (
    [Server]            NVARCHAR (128)  CONSTRAINT [DF_DiskSpaceStatistics_Server] DEFAULT (@@servername) NOT NULL,
    [Disk]              NVARCHAR (256)  NOT NULL,
    [Disk_Space_Mb]     NUMERIC (11, 2) NOT NULL,
    [Available_Mb]      NUMERIC (11, 2) NOT NULL,
    [Available_Percent] NUMERIC (11, 2) NOT NULL,
    [State]             VARCHAR (7)     NOT NULL,
    [InsertUTCDate]     DATETIME        CONSTRAINT [DF_DiskSpaceStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[DiskSpaceStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);

