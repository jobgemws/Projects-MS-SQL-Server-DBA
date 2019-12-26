CREATE SCHEMA [zabbix]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Здесь располагаются объекты для вывода значений в Zabbix', @level0type = N'SCHEMA', @level0name = N'zabbix';

