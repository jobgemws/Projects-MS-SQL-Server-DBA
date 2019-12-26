CREATE TABLE [srv].[DBFileStatistics] (
    [Server]               NVARCHAR (128)   CONSTRAINT [DF_DBFileStatistics_Server] DEFAULT (CONVERT([nvarchar](255),serverproperty(N'MachineName'))) NOT NULL,
    [DBName]               NVARCHAR (128)   NOT NULL,
    [FileId]               SMALLINT         NOT NULL,
    [NumberReads]          BIGINT           NOT NULL,
    [BytesRead]            BIGINT           NOT NULL,
    [IoStallReadMS]        BIGINT           NOT NULL,
    [NumberWrites]         BIGINT           NOT NULL,
    [BytesWritten]         BIGINT           NOT NULL,
    [IoStallWriteMS]       BIGINT           NOT NULL,
    [IoStallMS]            BIGINT           NOT NULL,
    [BytesOnDisk]          BIGINT           NOT NULL,
    [TimeStamp]            BIGINT           NOT NULL,
    [FileHandle]           VARBINARY (8)    NOT NULL,
    [Type_desc]            NVARCHAR (60)    COLLATE Latin1_General_CI_AS_KS_WS NULL,
    [FileName]             [sysname]        NOT NULL,
    [Drive]                NVARCHAR (1)     NULL,
    [Physical_Name]        NVARCHAR (260)   NOT NULL,
    [Ext]                  NVARCHAR (3)     NULL,
    [CountPage]            INT              NOT NULL,
    [SizeMb]               FLOAT (53)       NULL,
    [SizeGb]               FLOAT (53)       NULL,
    [Growth]               INT              NULL,
    [GrowthMb]             FLOAT (53)       NULL,
    [GrowthGb]             FLOAT (53)       NULL,
    [GrowthPercent]        INT              NOT NULL,
    [is_percent_growth]    BIT              NOT NULL,
    [database_id]          INT              NOT NULL,
    [State]                TINYINT          NULL,
    [StateDesc]            NVARCHAR (60)    COLLATE Latin1_General_CI_AS_KS_WS NULL,
    [IsMediaReadOnly]      BIT              NOT NULL,
    [IsReadOnly]           BIT              NOT NULL,
    [IsSpace]              BIT              NOT NULL,
    [IsNameReserved]       BIT              NOT NULL,
    [CreateLsn]            NUMERIC (25)     NULL,
    [DropLsn]              NUMERIC (25)     NULL,
    [ReadOnlyLsn]          NUMERIC (25)     NULL,
    [ReadWriteLsn]         NUMERIC (25)     NULL,
    [DifferentialBaseLsn]  NUMERIC (25)     NULL,
    [DifferentialBaseGuid] UNIQUEIDENTIFIER NULL,
    [DifferentialBaseTime] DATETIME         NULL,
    [RedoStartLsn]         NUMERIC (25)     NULL,
    [RedoStartForkGuid]    UNIQUEIDENTIFIER NULL,
    [RedoTargetLsn]        NUMERIC (25)     NULL,
    [RedoTargetForkGuid]   UNIQUEIDENTIFIER NULL,
    [BackupLsn]            NUMERIC (25)     NULL,
    [InsertUTCDate]        DATETIME         CONSTRAINT [DF_DBFileStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[DBFileStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статистика по файлам БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBFileStatistics';

