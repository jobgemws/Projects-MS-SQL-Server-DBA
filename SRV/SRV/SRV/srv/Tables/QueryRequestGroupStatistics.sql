CREATE TABLE [srv].[QueryRequestGroupStatistics] (
    [DBName]                          NVARCHAR (MAX)  CONSTRAINT [DF_QueryRequestGroupStatistics1_DBName] DEFAULT (newid()) NULL,
    [TSQL]                            NVARCHAR (MAX)  NOT NULL,
    [Count]                           BIGINT          NOT NULL,
    [mintotal_elapsed_timeSec]        DECIMAL (23, 3) NOT NULL,
    [maxtotal_elapsed_timeSec]        DECIMAL (23, 3) NOT NULL,
    [mincpu_timeSec]                  DECIMAL (23, 3) NOT NULL,
    [maxcpu_timeSec]                  DECIMAL (23, 3) NOT NULL,
    [minwait_timeSec]                 DECIMAL (23, 3) NOT NULL,
    [maxwait_timeSec]                 DECIMAL (23, 3) NOT NULL,
    [row_count]                       BIGINT          NOT NULL,
    [SumCountRows]                    BIGINT          NOT NULL,
    [min_reads]                       BIGINT          NOT NULL,
    [max_reads]                       BIGINT          NOT NULL,
    [min_writes]                      BIGINT          NOT NULL,
    [max_writes]                      BIGINT          NOT NULL,
    [min_logical_reads]               BIGINT          NOT NULL,
    [max_logical_reads]               BIGINT          NOT NULL,
    [min_open_transaction_count]      BIGINT          NOT NULL,
    [max_open_transaction_count]      BIGINT          NOT NULL,
    [min_transaction_isolation_level] BIGINT          NOT NULL,
    [max_transaction_isolation_level] BIGINT          NOT NULL,
    [Unique_nt_user_name]             NVARCHAR (MAX)  NULL,
    [Unique_nt_domain]                NVARCHAR (MAX)  NULL,
    [Unique_login_name]               NVARCHAR (MAX)  NULL,
    [Unique_program_name]             NVARCHAR (MAX)  NULL,
    [Unique_host_name]                NVARCHAR (MAX)  NULL,
    [Unique_client_tcp_port]          NVARCHAR (MAX)  NULL,
    [Unique_client_net_address]       NVARCHAR (MAX)  NULL,
    [Unique_client_interface_name]    NVARCHAR (MAX)  NULL,
    [InsertUTCDate]                   DATETIME        CONSTRAINT [DF_QueryRequestGroupStatistics1_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [sql_handle]                      VARBINARY (64)  NOT NULL,
    CONSTRAINT [PK_QueryRequestGroupStatistics] PRIMARY KEY CLUSTERED ([sql_handle] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Детальная информация по собранным запросам (сгруппированная по запросам)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'QueryRequestGroupStatistics';

