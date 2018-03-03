CREATE SCHEMA [rep]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объекты схемы rep содержат информацию для отчетов', @level0type = N'SCHEMA', @level0name = N'rep';

