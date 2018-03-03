
CREATE FUNCTION [rep].[GetDateFormat] 
(
	@dt datetime, -- входная дата
	@format int=0 -- заданный формат
)
RETURNS nvarchar(255)
AS
/*
	15.04.2014 ГЕМ:
	Возвращает дату в виде строки по заданному формату и входной дате
	Проставляет необходимые нули:
	формат	входная дата	результат
	0		17.4.2014		"17.04.2014"
	1		17.4.2014		"04.2014"
	1		8.11.2014		"11.2014"
	2		17.04.2014		"2014"
*/
BEGIN
	DECLARE @res nvarchar(255);
	DECLARE @day int=DAY(@dt);
	DECLARE @month int=MONTH(@dt);
	DECLARE @year int=YEAR(@dt);

	if(@format=0)
	begin
		set @res=IIF(@day<10,'0'+cast(@day as nvarchar(1)), cast(@day as nvarchar(2)))+'.';
		set @res=@res+IIF(@month<10,'0'+cast(@month as nvarchar(1)), cast(@month as nvarchar(2)))+'.';
		set @res=@res+cast(@year as nvarchar(255));
	end
	else if(@format=1)
	begin
		set @res=IIF(@month<10,'0'+cast(@month as nvarchar(1)), cast(@month as nvarchar(2)))+'.';
		set @res=@res+cast(@year as nvarchar(255));
	end
	else if(@format=2)
	begin
		set @res=cast(@year as nvarchar(255));
	end

	RETURN @res;

END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает дату в виде строки по заданному формату и входной дате', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetDateFormat';

