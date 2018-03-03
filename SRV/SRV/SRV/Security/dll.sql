CREATE SCHEMA [dll]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объекты схемы dll подгружаются из сторонних библиотек', @level0type = N'SCHEMA', @level0name = N'dll';

