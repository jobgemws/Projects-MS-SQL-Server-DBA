CREATE TABLE [dbo].[AuditQuery] (
    [ID]   INT            IDENTITY (1, 1) NOT NULL,
    [TSQL] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_AuditQuery] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для аудита', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditQuery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор записи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditQuery', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditQuery', @level2type = N'COLUMN', @level2name = N'TSQL';

