CREATE SCHEMA [nav]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пользовательская схема', @level0type = N'SCHEMA', @level0name = N'nav';

