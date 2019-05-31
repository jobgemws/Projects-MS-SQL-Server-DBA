CREATE TABLE [srv].[DBListNotDelete] (
    [Name]           NVARCHAR (255) NOT NULL,
    [IsWhiteListAll] BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DBListNotDelete] PRIMARY KEY CLUSTERED ([Name] ASC) WITH (FILLFACTOR = 95)
);

