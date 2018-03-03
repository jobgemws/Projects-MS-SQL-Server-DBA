CREATE TABLE [srv].[PlanQuery] (
    [PlanHandle]                VARBINARY (64) NOT NULL,
    [SQLHandle]                 VARBINARY (64) NOT NULL,
    [QueryPlan]                 XML            NULL,
    [InsertUTCDate]             DATETIME       CONSTRAINT [DF_PlanQuery_InsertUTCDate] DEFAULT (getutcdate()) NOT NULL,
    [dop]                       SMALLINT       NULL,
    [request_time]              DATETIME       NULL,
    [grant_time]                DATETIME       NULL,
    [requested_memory_kb]       BIGINT         NULL,
    [granted_memory_kb]         BIGINT         NULL,
    [required_memory_kb]        BIGINT         NULL,
    [used_memory_kb]            BIGINT         NULL,
    [max_used_memory_kb]        BIGINT         NULL,
    [query_cost]                FLOAT (53)     NULL,
    [timeout_sec]               INT            NULL,
    [resource_semaphore_id]     SMALLINT       NULL,
    [queue_id]                  SMALLINT       NULL,
    [wait_order]                INT            NULL,
    [is_next_candidate]         BIT            NULL,
    [wait_time_ms]              BIGINT         NULL,
    [pool_id]                   INT            NULL,
    [is_small]                  BIT            NULL,
    [ideal_memory_kb]           BIGINT         NULL,
    [reserved_worker_count]     INT            NULL,
    [used_worker_count]         INT            NULL,
    [max_used_worker_count]     INT            NULL,
    [reserved_node_bitmap]      BIGINT         NULL,
    [bucketid]                  INT            NULL,
    [refcounts]                 INT            NULL,
    [usecounts]                 INT            NULL,
    [size_in_bytes]             INT            NULL,
    [memory_object_address]     VARBINARY (8)  NULL,
    [cacheobjtype]              NVARCHAR (50)  NULL,
    [objtype]                   NVARCHAR (20)  NULL,
    [parent_plan_handle]        VARBINARY (64) NULL,
    [creation_time]             DATETIME       NULL,
    [execution_count]           BIGINT         NULL,
    [total_worker_time]         BIGINT         NULL,
    [min_last_worker_time]      BIGINT         NULL,
    [max_last_worker_time]      BIGINT         NULL,
    [min_worker_time]           BIGINT         NULL,
    [max_worker_time]           BIGINT         NULL,
    [total_physical_reads]      BIGINT         NULL,
    [min_last_physical_reads]   BIGINT         NULL,
    [max_last_physical_reads]   BIGINT         NULL,
    [min_physical_reads]        BIGINT         NULL,
    [max_physical_reads]        BIGINT         NULL,
    [total_logical_writes]      BIGINT         NULL,
    [min_last_logical_writes]   BIGINT         NULL,
    [max_last_logical_writes]   BIGINT         NULL,
    [min_logical_writes]        BIGINT         NULL,
    [max_logical_writes]        BIGINT         NULL,
    [total_logical_reads]       BIGINT         NULL,
    [min_last_logical_reads]    BIGINT         NULL,
    [max_last_logical_reads]    BIGINT         NULL,
    [min_logical_reads]         BIGINT         NULL,
    [max_logical_reads]         BIGINT         NULL,
    [total_clr_time]            BIGINT         NULL,
    [min_last_clr_time]         BIGINT         NULL,
    [max_last_clr_time]         BIGINT         NULL,
    [min_clr_time]              BIGINT         NULL,
    [max_clr_time]              BIGINT         NULL,
    [min_last_elapsed_time]     BIGINT         NULL,
    [max_last_elapsed_time]     BIGINT         NULL,
    [min_elapsed_time]          BIGINT         NULL,
    [max_elapsed_time]          BIGINT         NULL,
    [total_rows]                BIGINT         NULL,
    [min_last_rows]             BIGINT         NULL,
    [max_last_rows]             BIGINT         NULL,
    [min_rows]                  BIGINT         NULL,
    [max_rows]                  BIGINT         NULL,
    [total_dop]                 BIGINT         NULL,
    [min_last_dop]              BIGINT         NULL,
    [max_last_dop]              BIGINT         NULL,
    [min_dop]                   BIGINT         NULL,
    [max_dop]                   BIGINT         NULL,
    [total_grant_kb]            BIGINT         NULL,
    [min_last_grant_kb]         BIGINT         NULL,
    [max_last_grant_kb]         BIGINT         NULL,
    [min_grant_kb]              BIGINT         NULL,
    [max_grant_kb]              BIGINT         NULL,
    [total_used_grant_kb]       BIGINT         NULL,
    [min_last_used_grant_kb]    BIGINT         NULL,
    [max_last_used_grant_kb]    BIGINT         NULL,
    [min_used_grant_kb]         BIGINT         NULL,
    [max_used_grant_kb]         BIGINT         NULL,
    [total_ideal_grant_kb]      BIGINT         NULL,
    [min_last_ideal_grant_kb]   BIGINT         NULL,
    [max_last_ideal_grant_kb]   BIGINT         NULL,
    [min_ideal_grant_kb]        BIGINT         NULL,
    [max_ideal_grant_kb]        BIGINT         NULL,
    [total_reserved_threads]    BIGINT         NULL,
    [min_last_reserved_threads] BIGINT         NULL,
    [max_last_reserved_threads] BIGINT         NULL,
    [min_reserved_threads]      BIGINT         NULL,
    [max_reserved_threads]      BIGINT         NULL,
    [total_used_threads]        BIGINT         NULL,
    [min_last_used_threads]     BIGINT         NULL,
    [max_last_used_threads]     BIGINT         NULL,
    [min_used_threads]          BIGINT         NULL,
    [max_used_threads]          BIGINT         NULL,
    CONSTRAINT [PK_PlanQuery] PRIMARY KEY CLUSTERED ([SQLHandle] ASC, [PlanHandle] ASC)
);


GO
CREATE NONCLUSTERED INDEX [indInsertUTCDate]
    ON [srv].[PlanQuery]([InsertUTCDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс по InsertUTCDate', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'PlanQuery', @level2type = N'INDEX', @level2name = N'indInsertUTCDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Планы запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'PlanQuery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хэш плана выполнения', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'PlanQuery', @level2type = N'COLUMN', @level2name = N'PlanHandle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хэш запроса', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'PlanQuery', @level2type = N'COLUMN', @level2name = N'SQLHandle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'План выполнения', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'PlanQuery', @level2type = N'COLUMN', @level2name = N'QueryPlan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время создания записи в UTC', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'PlanQuery', @level2type = N'COLUMN', @level2name = N'InsertUTCDate';

