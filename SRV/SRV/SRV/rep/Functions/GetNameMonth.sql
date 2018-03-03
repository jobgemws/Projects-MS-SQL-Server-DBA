
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [rep].[GetNameMonth]
(
	@Month_Num int -- заданный номер месяца
)
RETURNS nvarchar(256)
AS
/*
	15.04.2014 ГЕМ:
	Возвращает русское название месяца по заданному его номеру
*/
BEGIN
	declare @Month_Name nvarchar(256);
	set @Month_Name=case @Month_Num
					when 1 then 'январь'
					when 2 then 'февраль'
					when 3 then 'март'
					when 4 then 'апрель'
					when 5 then 'май'
					when 6 then 'июнь'
					when 7 then 'июль'
					when 8 then 'август'
					when 9 then 'сентябрь'
					when 10 then 'октябрь'
					when 11 then 'ноябрь'
					when 12 then 'декабрь'
					end
	return @Month_Name;

END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает русское название месяца по заданному его номеру', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetNameMonth';

