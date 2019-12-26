CREATE TABLE [srv].[DiskSpaceStatistics] (
    [Server]            NVARCHAR (128)  CONSTRAINT [DF_DiskSpaceStatistics_Server] DEFAULT (CONVERT([nvarchar](255),serverproperty(N'MachineName'))) NOT NULL,
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


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статистика использования емкости дисков', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DiskSpaceStatistics';

