
CREATE FUNCTION [rep].[GetTimeFormat] 
(
	@dt datetime, -- входное время
	@format int=0 -- заданный формат
)
RETURNS nvarchar(255)
AS
/*
	15.04.2014 ГЕМ:
	Возвращает время в виде строки по заданному формату и входному времени
	Проставляет необходимые нули:
	формат	входное время	результат
	0		17:04			"17:04:00"
	1		17:04			"17:04"
	1		8:04			"08:04"
	2		17:04			"17"
*/
BEGIN
	DECLARE @res nvarchar(255);
	DECLARE @hour int=DATEPART(HOUR, @dt);
	DECLARE @min int=DATEPART(MINUTE, @dt);
	DECLARE @sec int=DATEPART(SECOND, @dt);

	if(@format=0)
	begin
		set @res=IIF(@hour<10,'0'+cast(@hour as nvarchar(1)), cast(@hour as nvarchar(2)))+':';
		set @res=@res+IIF(@min<10,'0'+cast(@min as nvarchar(1)), cast(@min as nvarchar(2)))+':';
		set @res=@res+IIF(@sec<10,'0'+cast(@sec as nvarchar(1)), cast(@sec as nvarchar(2)));
	end
	else if(@format=1)
	begin
		set @res=IIF(@hour<10,'0'+cast(@hour as nvarchar(1)), cast(@hour as nvarchar(2)))+':';
		set @res=@res+IIF(@min<10,'0'+cast(@min as nvarchar(1)), cast(@min as nvarchar(2)));
	end
	else if(@format=2)
	begin
		set @res=IIF(@hour<10,'0'+cast(@hour as nvarchar(1)), cast(@hour as nvarchar(2)));
	end

	RETURN @res;

END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает время в виде строки по заданному формату и входному времени', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetTimeFormat';

