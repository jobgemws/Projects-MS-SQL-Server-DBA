CREATE TABLE [srv].[NewIndexOptimizeStatistics] (
    [ServerName]            NVARCHAR (128)  NULL,
    [DBName]                NVARCHAR (128)  NULL,
    [Schema]                NVARCHAR (128)  NULL,
    [Name]                  NVARCHAR (128)  NULL,
    [index_advantage]       FLOAT (53)      NULL,
    [group_handle]          INT             NOT NULL,
    [unique_compiles]       BIGINT          NOT NULL,
    [last_user_seek]        DATETIME        NULL,
    [last_user_scan]        DATETIME        NULL,
    [avg_total_user_cost]   FLOAT (53)      NULL,
    [avg_user_impact]       FLOAT (53)      NULL,
    [system_seeks]          BIGINT          NOT NULL,
    [last_system_scan]      DATETIME        NULL,
    [last_system_seek]      DATETIME        NULL,
    [avg_total_system_cost] FLOAT (53)      NULL,
    [avg_system_impact]     FLOAT (53)      NULL,
    [index_group_handle]    INT             NOT NULL,
    [index_handle]          INT             NOT NULL,
    [database_id]           SMALLINT        NOT NULL,
    [object_id]             INT             NOT NULL,
    [equality_columns]      NVARCHAR (4000) NULL,
    [inequality_columns]    NVARCHAR (4000) NULL,
    [statement]             NVARCHAR (4000) NULL,
    [K]                     INT             NULL,
    [Keys]                  NVARCHAR (4000) NULL,
    [include]               NVARCHAR (4000) NULL,
    [sql_statement]         NVARCHAR (4000) NULL,
    [user_seeks]            BIGINT          NOT NULL,
    [user_scans]            BIGINT          NOT NULL,
    [est_impact]            BIGINT          NULL,
    [SecondsUptime]         INT             NULL,
    [InsertUTCDate]         DATETIME        CONSTRAINT [DF_NewIndexOptimizeStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL
);


GO
CREATE CLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[NewIndexOptimizeStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);

