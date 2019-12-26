CREATE TABLE [srv].[RequestStatistics] (
    [session_id]                  SMALLINT         NOT NULL,
    [request_id]                  INT              NULL,
    [start_time]                  DATETIME         NULL,
    [status]                      NVARCHAR (30)    NULL,
    [command]                     NVARCHAR (32)    NULL,
    [sql_handle]                  VARBINARY (64)   NULL,
    [statement_start_offset]      INT              NULL,
    [statement_end_offset]        INT              NULL,
    [plan_handle]                 VARBINARY (64)   NULL,
    [database_id]                 SMALLINT         NULL,
    [user_id]                     INT              NULL,
    [connection_id]               UNIQUEIDENTIFIER NULL,
    [blocking_session_id]         SMALLINT         NULL,
    [wait_type]                   NVARCHAR (60)    NULL,
    [wait_time]                   INT              NULL,
    [last_wait_type]              NVARCHAR (60)    NULL,
    [wait_resource]               NVARCHAR (256)   NULL,
    [open_transaction_count]      INT              NULL,
    [open_resultset_count]        INT              NULL,
    [transaction_id]              BIGINT           NULL,
    [context_info]                VARBINARY (128)  NULL,
    [percent_complete]            REAL             NULL,
    [estimated_completion_time]   BIGINT           NULL,
    [cpu_time]                    INT              NULL,
    [total_elapsed_time]          INT              NULL,
    [scheduler_id]                INT              NULL,
    [task_address]                VARBINARY (8)    NULL,
    [reads]                       BIGINT           NULL,
    [writes]                      BIGINT           NULL,
    [logical_reads]               BIGINT           NULL,
    [text_size]                   INT              NULL,
    [language]                    NVARCHAR (128)   NULL,
    [date_format]                 NVARCHAR (3)     NULL,
    [date_first]                  SMALLINT         NULL,
    [quoted_identifier]           BIT              NULL,
    [arithabort]                  BIT              NULL,
    [ansi_null_dflt_on]           BIT              NULL,
    [ansi_defaults]               BIT              NULL,
    [ansi_warnings]               BIT              NULL,
    [ansi_padding]                BIT              NULL,
    [ansi_nulls]                  BIT              NULL,
    [concat_null_yields_null]     BIT              NULL,
    [transaction_isolation_level] SMALLINT         NULL,
    [lock_timeout]                INT              NULL,
    [deadlock_priority]           INT              NULL,
    [row_count]                   BIGINT           NULL,
    [prev_error]                  INT              NULL,
    [nest_level]                  INT              NULL,
    [granted_query_memory]        INT              NULL,
    [executing_managed_code]      BIT              NULL,
    [group_id]                    INT              NULL,
    [query_hash]                  BINARY (8)       NULL,
    [query_plan_hash]             BINARY (8)       NULL,
    [most_recent_session_id]      INT              NULL,
    [connect_time]                DATETIME         NULL,
    [net_transport]               NVARCHAR (40)    NULL,
    [protocol_type]               NVARCHAR (40)    NULL,
    [protocol_version]            INT              NULL,
    [endpoint_id]                 INT              NULL,
    [encrypt_option]              NVARCHAR (40)    NULL,
    [auth_scheme]                 NVARCHAR (40)    NULL,
    [node_affinity]               SMALLINT         NULL,
    [num_reads]                   INT              NULL,
    [num_writes]                  INT              NULL,
    [last_read]                   DATETIME         NULL,
    [last_write]                  DATETIME         NULL,
    [net_packet_size]             INT              NULL,
    [client_net_address]          VARCHAR (48)     NULL,
    [client_tcp_port]             INT              NULL,
    [local_net_address]           VARCHAR (48)     NULL,
    [local_tcp_port]              INT              NULL,
    [parent_connection_id]        UNIQUEIDENTIFIER NULL,
    [most_recent_sql_handle]      VARBINARY (64)   NULL,
    [login_time]                  DATETIME         NULL,
    [host_name]                   NVARCHAR (128)   NULL,
    [program_name]                NVARCHAR (128)   NULL,
    [host_process_id]             INT              NULL,
    [client_version]              INT              NULL,
    [client_interface_name]       NVARCHAR (32)    NULL,
    [security_id]                 VARBINARY (85)   NULL,
    [login_name]                  NVARCHAR (128)   NULL,
    [nt_domain]                   NVARCHAR (128)   NULL,
    [nt_user_name]                NVARCHAR (128)   NULL,
    [memory_usage]                INT              NULL,
    [total_scheduled_time]        INT              NULL,
    [last_request_start_time]     DATETIME         NULL,
    [last_request_end_time]       DATETIME         NULL,
    [is_user_process]             BIT              NULL,
    [original_security_id]        VARBINARY (85)   NULL,
    [original_login_name]         NVARCHAR (128)   NULL,
    [last_successful_logon]       DATETIME         NULL,
    [last_unsuccessful_logon]     DATETIME         NULL,
    [unsuccessful_logons]         BIGINT           NULL,
    [authenticating_database_id]  INT              NULL,
    [InsertUTCDate]               DATETIME         CONSTRAINT [DF_RequestStatistics_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [EndRegUTCDate]               DATETIME         NULL,
    [is_blocking_other_session]   INT              DEFAULT ((0)) NOT NULL,
    [dop]                         SMALLINT         NULL,
    [request_time]                DATETIME         NULL,
    [grant_time]                  DATETIME         NULL,
    [requested_memory_kb]         BIGINT           NULL,
    [granted_memory_kb]           BIGINT           NULL,
    [required_memory_kb]          BIGINT           NULL,
    [used_memory_kb]              BIGINT           NULL,
    [max_used_memory_kb]          BIGINT           NULL,
    [query_cost]                  FLOAT (53)       NULL,
    [timeout_sec]                 INT              NULL,
    [resource_semaphore_id]       SMALLINT         NULL,
    [queue_id]                    SMALLINT         NULL,
    [wait_order]                  INT              NULL,
    [is_next_candidate]           BIT              NULL,
    [wait_time_ms]                BIGINT           NULL,
    [pool_id]                     INT              NULL,
    [is_small]                    BIT              NULL,
    [ideal_memory_kb]             BIGINT           NULL,
    [reserved_worker_count]       INT              NULL,
    [used_worker_count]           INT              NULL,
    [max_used_worker_count]       INT              NULL,
    [reserved_node_bitmap]        BIGINT           NULL,
    [bucketid]                    INT              NULL,
    [refcounts]                   INT              NULL,
    [usecounts]                   INT              NULL,
    [size_in_bytes]               INT              NULL,
    [memory_object_address]       VARBINARY (8)    NULL,
    [cacheobjtype]                NVARCHAR (50)    NULL,
    [objtype]                     NVARCHAR (20)    NULL,
    [parent_plan_handle]          VARBINARY (64)   NULL,
    [creation_time]               DATETIME         NULL,
    [execution_count]             BIGINT           NULL,
    [total_worker_time]           BIGINT           NULL,
    [min_last_worker_time]        BIGINT           NULL,
    [max_last_worker_time]        BIGINT           NULL,
    [min_worker_time]             BIGINT           NULL,
    [max_worker_time]             BIGINT           NULL,
    [total_physical_reads]        BIGINT           NULL,
    [min_last_physical_reads]     BIGINT           NULL,
    [max_last_physical_reads]     BIGINT           NULL,
    [min_physical_reads]          BIGINT           NULL,
    [max_physical_reads]          BIGINT           NULL,
    [total_logical_writes]        BIGINT           NULL,
    [min_last_logical_writes]     BIGINT           NULL,
    [max_last_logical_writes]     BIGINT           NULL,
    [min_logical_writes]          BIGINT           NULL,
    [max_logical_writes]          BIGINT           NULL,
    [total_logical_reads]         BIGINT           NULL,
    [min_last_logical_reads]      BIGINT           NULL,
    [max_last_logical_reads]      BIGINT           NULL,
    [min_logical_reads]           BIGINT           NULL,
    [max_logical_reads]           BIGINT           NULL,
    [total_clr_time]              BIGINT           NULL,
    [min_last_clr_time]           BIGINT           NULL,
    [max_last_clr_time]           BIGINT           NULL,
    [min_clr_time]                BIGINT           NULL,
    [max_clr_time]                BIGINT           NULL,
    [min_last_elapsed_time]       BIGINT           NULL,
    [max_last_elapsed_time]       BIGINT           NULL,
    [min_elapsed_time]            BIGINT           NULL,
    [max_elapsed_time]            BIGINT           NULL,
    [total_rows]                  BIGINT           NULL,
    [min_last_rows]               BIGINT           NULL,
    [max_last_rows]               BIGINT           NULL,
    [min_rows]                    BIGINT           NULL,
    [max_rows]                    BIGINT           NULL,
    [total_dop]                   BIGINT           NULL,
    [min_last_dop]                BIGINT           NULL,
    [max_last_dop]                BIGINT           NULL,
    [min_dop]                     BIGINT           NULL,
    [max_dop]                     BIGINT           NULL,
    [total_grant_kb]              BIGINT           NULL,
    [min_last_grant_kb]           BIGINT           NULL,
    [max_last_grant_kb]           BIGINT           NULL,
    [min_grant_kb]                BIGINT           NULL,
    [max_grant_kb]                BIGINT           NULL,
    [total_used_grant_kb]         BIGINT           NULL,
    [min_last_used_grant_kb]      BIGINT           NULL,
    [max_last_used_grant_kb]      BIGINT           NULL,
    [min_used_grant_kb]           BIGINT           NULL,
    [max_used_grant_kb]           BIGINT           NULL,
    [total_ideal_grant_kb]        BIGINT           NULL,
    [min_last_ideal_grant_kb]     BIGINT           NULL,
    [max_last_ideal_grant_kb]     BIGINT           NULL,
    [min_ideal_grant_kb]          BIGINT           NULL,
    [max_ideal_grant_kb]          BIGINT           NULL,
    [total_reserved_threads]      BIGINT           NULL,
    [min_last_reserved_threads]   BIGINT           NULL,
    [max_last_reserved_threads]   BIGINT           NULL,
    [min_reserved_threads]        BIGINT           NULL,
    [max_reserved_threads]        BIGINT           NULL,
    [total_used_threads]          BIGINT           NULL,
    [min_last_used_threads]       BIGINT           NULL,
    [max_last_used_threads]       BIGINT           NULL,
    [min_used_threads]            BIGINT           NULL,
    [max_used_threads]            BIGINT           NULL
);


GO
CREATE CLUSTERED INDEX [indRequest]
    ON [srv].[RequestStatistics]([session_id] ASC, [request_id] ASC, [database_id] ASC, [user_id] ASC, [start_time] ASC, [command] ASC, [sql_handle] ASC, [plan_handle] ASC, [transaction_id] ASC, [connection_id] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[RequestStatistics]([InsertUTCDate] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [indPlanQuery]
    ON [srv].[RequestStatistics]([sql_handle] ASC, [plan_handle] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Снимки по активным запросам экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор сеанса, к которому относится данный запрос. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'session_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор запроса. Уникален в контексте сеанса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'request_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Метка времени поступления запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'start_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Состояние запроса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'status';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип выполняемой в данный момент команды', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'command';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хэш-карта текста SQL-запроса. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'sql_handle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество символов в выполняемом в настоящий момент пакете или хранимой процедуре, в которой запущена текущая инструкция. Может применяться вместе с функциями динамического управления sql_handle, statement_end_offset и sys.dm_exec_sql_text для извлечения исполняемой в настоящий момент инструкции по запросу. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'statement_start_offset';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество символов в выполняемом в настоящий момент пакете или хранимой процедуре, в которой завершилась текущая инструкция. Может применяться вместе с функциями динамического управления sql_handle, statement_end_offset и sys.dm_exec_sql_text для извлечения исполняемой в настоящий момент инструкции по запросу. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'statement_end_offset';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хэш-карта плана выполнения SQL. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'plan_handle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор базы данных, к которой выполняется запрос. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'database_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор пользователя, отправившего данный запрос. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'user_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор соединения, по которому поступил запрос. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'connection_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор сеанса, блокирующего данный запрос. Если этот столбец содержит значение NULL, то запрос не блокирован или сведения о сеансе блокировки недоступны (или не могут быть идентифицированы)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'blocking_session_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Если запрос в настоящий момент блокирован, в столбце содержится тип ожидания. Допускает значение NULL (sys.dm_os_wait_stats)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'wait_type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Если запрос в настоящий момент блокирован, в столбце содержится продолжительность текущего ожидания (в миллисекундах). Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'wait_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Если запрос был блокирован ранее, в столбце содержится тип последнего ожидания. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'last_wait_type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Если запрос в настоящий момент блокирован, в столбце указан ресурс, освобождения которого ожидает запрос. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'wait_resource';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число транзакций, открытых для данного запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'open_transaction_count';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число результирующих наборов, открытых для данного запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'open_resultset_count';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор транзакции, в которой выполняется запрос. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'transaction_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Значение CONTEXT_INFO сеанса. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'context_info';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент завершения работы (для некоторых типов команд sys.dm_exec_requests)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'percent_complete';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Только для внутреннего использования. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'estimated_completion_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время ЦП (в миллисекундах), затраченное на выполнение запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'cpu_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее время, истекшее с момента поступления запроса (в миллисекундах). Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'total_elapsed_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор планировщика, который планирует данный запрос. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'scheduler_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адрес блока памяти, выделенного для задачи, связанной с этим запросом. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'task_address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число операций чтения, выполненных данным запросом. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'reads';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число операций записи, выполненных данным запросом. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'writes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число логических операций чтения, выполненных данным запросом. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'logical_reads';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Установка параметра TEXTSIZE для данного запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'text_size';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Установка языка для данного запроса. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'language';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Установка параметра DATEFORMAT для данного запроса. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'date_format';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Установка параметра DATEFIRST для данного запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'date_first';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Параметр QUOTED_IDENTIFIER для запроса включен (ON). В противном случае — 0.

Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'quoted_identifier';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Параметр ARITHABORT для запроса включен (ON). В противном случае — 0.

Не допускает значение NULL.', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'arithabort';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Параметр ANSI_NULL_DFLT_ON для запроса включен (ON). В противном случае — 0.

Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'ansi_null_dflt_on';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Параметр ANSI_DEFAULTS для запроса включен (ON). В противном случае — 0.

Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'ansi_defaults';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Параметр ANSI_WARNINGS для запроса включен (ON). В противном случае — 0.

Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'ansi_warnings';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Параметр ANSI_PADDING для запроса включен (ON).

В противном случае — 0.

Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'ansi_padding';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Параметр ANSI_NULLS для запроса включен (ON). В противном случае — 0.

Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'ansi_nulls';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Параметр CONCAT_NULL_YIELDS_NULL для запроса включен (ON). В противном случае — 0.

Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'concat_null_yields_null';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Уровень изоляции, с которым создана транзакция для данного запроса. Не допускает значение NULL.

0 = не указан;

1 = читать незафиксированные;

2 = читать зафиксированные;

3 = повторяемые результаты;

4 = сериализуемые;

5 = моментальный снимок', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'transaction_isolation_level';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время ожидания блокировки для данного запроса (в миллисекундах). Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'lock_timeout';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Значение параметра DEADLOCK_PRIORITY для данного запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'deadlock_priority';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число строк, возвращенных клиенту по данному запросу. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'row_count';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последняя ошибка, происшедшая при выполнении запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'prev_error';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Текущий уровень вложенности кода, выполняемого для данного запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'nest_level';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число страниц, выделенных для выполнения поступившего запроса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'granted_query_memory';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Указывает, выполняет ли данный запрос в настоящее время код объекта среды CLR (например, процедуры, типа или триггера). Этот флаг установлен в течение всего времени, когда объект среды CLR находится в стеке, даже когда из среды вызывается код Transact-SQL. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'executing_managed_code';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор группы рабочей нагрузки, которой принадлежит этот запрос. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'group_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Двоичное хэш-значение рассчитывается для запроса и используется для идентификации запросов с аналогичной логикой. Можно использовать хэш запроса для определения использования статистических ресурсов для запросов, которые отличаются только своими литеральными значениями', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'query_hash';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Двоичное хэш-значение рассчитывается для плана выполнения запроса и используется для идентификации аналогичных планов выполнения запросов. Можно использовать хэш плана запроса для нахождения совокупной стоимости запросов со схожими планами выполнения', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'query_plan_hash';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Представляет собой идентификатор сеанса самого последнего запроса, связанного с данным соединением. (Соединения SOAP можно повторно использовать в другом сеансе.) Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'most_recent_session_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отметка времени установления соединения. Не допускает значения NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'connect_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Содержит описание физического транспортного протокола, используемого данным соединением. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'net_transport';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Указывает тип протокола передачи полезных данных. В настоящее время различаются протоколы TDS (TSQL) и SOAP. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'protocol_type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Версия протокола доступа к данным, связанного с данным соединением. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'protocol_version';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор, описывающий тип соединения. Этот идентификатор endpoint_id может использоваться для запросов к представлению sys.endpoints. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'endpoint_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логическое значение, указывающее, разрешено ли шифрование для данного соединения. Не допускает значения NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'encrypt_option';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Указывает схему проверки подлинности (SQL Server или Windows), используемую с данным соединением. Не допускает значения NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'auth_scheme';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентифицирует узел памяти, которому соответствует данное соединение. Не допускает значения NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'node_affinity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число пакетов, принятых посредством данного соединения. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'num_reads';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число пакетов, переданных посредством данного соединения. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'num_writes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отметка времени о последнем полученном пакете данных. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'last_read';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отметка времени о последнем отправленном пакете данных. Не допускает значения NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'last_write';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер сетевого пакета, используемый для передачи данных. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'net_packet_size';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сетевой адрес удаленного клиента. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'client_net_address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер порта на клиентском компьютере, который используется при осуществлении соединения. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'client_tcp_port';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'IP-адрес сервера, с которым установлено данное соединение. Доступен только для соединений, которые в качестве транспорта данных используют протокол TCP. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'local_net_address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TCP-порт сервера, если соединение использует протокол TCP. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'local_tcp_port';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентифицирует первичное соединение, используемое в сеансе MARS. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'parent_connection_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дескриптор последнего запроса SQL, выполненного с помощью данного соединения. Постоянно проводится синхронизация между столбцом most_recent_sql_handle и столбцом most_recent_session_id. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'most_recent_sql_handle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время подключения сеанса. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'login_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя клиентской рабочей станции, указанное в сеансе. Для внутреннего сеанса это значение равно NULL. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя клиентской программы, которая инициировала сеанс. Для внутреннего сеанса это значение равно NULL. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'program_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор процесса клиентской программы, которая инициировала сеанс. Для внутреннего сеанса это значение равно NULL. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'host_process_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Версия TDS-протокола интерфейса, который используется клиентом для подключения к серверу. Для внутреннего сеанса это значение равно NULL. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'client_version';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя протокола, используемого клиентом для подключения к серверу. Для внутреннего сеанса это значение равно NULL. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'client_interface_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор безопасности Microsoft Windows, связанный с именем входа. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'security_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя входа SQL Server, под которым выполняется текущий сеанс. Имя входа пользователя, создавшего сеанс, см. в столбце original_login_name. Это может быть имя входа SQL Server, прошедшее проверку подлинности, либо имя пользователя домена Windows, прошедшее проверку подлинности. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'login_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Домен Windows для клиента, если во время сеанса применяется проверка подлинности Windows или доверительное соединение. Для внутренних сеансов и пользователей, не принадлежащих к домену, это значение равно NULL. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'nt_domain';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя пользователя Windows для клиента, если во время сеанса используется проверка подлинности Windows или доверительное соединение. Для внутренних сеансов и пользователей, не принадлежащих к домену, это значение равно NULL. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'nt_user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество 8-килобайтовых страниц памяти, используемых данным сеансом. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'memory_usage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общее время, назначенное данному сеансу (включая его вложенные запросы) для исполнения, в миллисекундах. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'total_scheduled_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время, когда начался последний запрос данного сеанса. Это может быть запрос, выполняющийся в данный момент. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'last_request_start_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время завершения последнего запроса в рамках данного сеанса. Допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'last_request_end_time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0, если сеанс является системным. В противном случае значение равно 1. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'is_user_process';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор безопасности Microsoft Windows, связанный с именем входа original_login_name. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'original_security_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя входа SQL Server, с помощью которого клиент создал данный сеанс. Это может быть имя входа SQL Server, прошедшее проверку подлинности, имя пользователя домена Windows, прошедшее проверку подлинности, или пользователь автономной базы данных. Обратите внимание, что после первоначального соединения для сеанса может быть выполнено много неявных или явных переключений контекста. Например, при использовании инструкции EXECUTE AS. Не допускает значение NULL', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'original_login_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время последнего успешного входа в систему для имени original_login_name до запуска текущего сеанса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'last_successful_logon';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время последнего неуспешного входа в систему для имени original_login_name до запуска текущего сеанса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'last_unsuccessful_logon';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число неуспешных попыток входа в систему для имени original_login_name между last_successful_logon и login_time', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'unsuccessful_logons';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор базы данных, выполняющей проверку подлинности участника. Для имен входа это значение будет равно 0. Для пользователей автономной базы данных это значение будет содержать идентификатор автономной базы данных', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'authenticating_database_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время удаления записи из активных в UTC (время регистрации удаления моментальным снимком)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'RequestStatistics', @level2type = N'COLUMN', @level2name = N'EndRegUTCDate';

