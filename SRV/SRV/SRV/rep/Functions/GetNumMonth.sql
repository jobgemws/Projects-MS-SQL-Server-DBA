
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [rep].[GetNumMonth]
(
	@Month_Name nvarchar(256) -- заданное название месяца по-русски
)
RETURNS int
AS
/*
	15.04.2014 ГЕМ:
	Возвращает номер месяца по его заданному названию по-русски
*/
BEGIN
	declare @Month_Num int;
	set @Month_Num=case ltrim(rtrim(@Month_Name))
					when 'январь' then 1
					when 'февраль' then 2
					when 'март' then 3
					when 'апрель' then 4
					when 'май' then 5
					when 'июнь' then 6
					when 'июль' then 7
					when 'август' then 8
					when 'сентябрь' then 9
					when 'октябрь' then 10
					when 'ноябрь' then 11
					when 'декабрь' then 12
					end
	return @Month_Num;

END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает номер месяца по его заданному названию по-русски', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetNumMonth';

