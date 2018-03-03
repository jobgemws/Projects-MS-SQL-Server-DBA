CREATE SCHEMA [inf]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объекты схемы inf базируются на встроенных объектах и данную информацию можно получить в любой момент времени (т е напрямую запросом без использования объекта в этой схеме)', @level0type = N'SCHEMA', @level0name = N'inf';

