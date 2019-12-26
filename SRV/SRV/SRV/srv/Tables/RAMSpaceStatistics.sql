CREATE TABLE [srv].[RAMSpaceStatistics] (
    [Server]                               NVARCHAR (128) CONSTRAINT [DF_RAMSpaceStatistics_Server] DEFAULT (CONVERT([nvarchar](255),serverproperty(N'MachineName'))) NOT NULL,
    [TotalAvailOSRam_Mb]                   INT            NOT NULL,
    [RAM_Avail_Percent]                    NUMERIC (5, 2) NOT NULL,
    [Server_physical_memory_Mb]            INT            CONSTRAINT [DF_RAMSpaceStatistics_Server_physical_memory_Mb] DEFAULT ((0)) NOT NULL,
    [SQL_server_committed_target_Mb]       INT            CONSTRAINT [DF_RAMSpaceStatistics_SQL_server_committed_target_Mb] DEFAULT ((0)) NOT NULL,
    [SQL_server_physical_memory_in_use_Mb] INT            CONSTRAINT [DF_RAMSpaceStatistics_SQL_server_physical_memory_in_use_Mb] DEFAULT ((0)) NOT NULL,
    [State]                                NVARCHAR (7)   CONSTRAINT [DF_RAMSpaceStatistics_State] DEFAULT ((0)) NOT NULL,
    [InsertUTCDate]                        DATETIME       CONSTRAINT [DF_RAMSpaceStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[RAMSpaceStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статистика по использованию емкости ОЗУ', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RAMSpaceStatistics';

