﻿CREATE TABLE [srv].[ReadWriteTablesStatistics] (
    [ServerName]      NVARCHAR (128)  NOT NULL,
    [DBName]          NVARCHAR (128)  NULL,
    [SchemaTableName] [sysname]       NOT NULL,
    [TableName]       NVARCHAR (128)  NULL,
    [Reads]           BIGINT          NULL,
    [Writes]          BIGINT          NULL,
    [Reads&Writes]    BIGINT          NULL,
    [SampleDays]      NUMERIC (18, 7) NULL,
    [SampleSeconds]   INT             NULL,
    [InsertUTCDate]   DATETIME        CONSTRAINT [DF_ReadWriteTablesStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[ReadWriteTablesStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);

