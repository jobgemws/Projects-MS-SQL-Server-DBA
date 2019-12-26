CREATE TABLE [srv].[DBListNotDelete] (
    [Name]           NVARCHAR (255) NOT NULL,
    [IsWhiteListAll] BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DBListNotDelete] PRIMARY KEY CLUSTERED ([Name] ASC) WITH (FILLFACTOR = 95)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Белый список БД, которых нельзя удалять', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'DBListNotDelete';

