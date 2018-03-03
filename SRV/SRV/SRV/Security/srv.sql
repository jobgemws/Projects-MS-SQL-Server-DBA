CREATE SCHEMA [srv]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объекты схемы srv обычно базируются на собранных заранее данных (т е напрямую запросом без использования объекта не получится)', @level0type = N'SCHEMA', @level0name = N'srv';

