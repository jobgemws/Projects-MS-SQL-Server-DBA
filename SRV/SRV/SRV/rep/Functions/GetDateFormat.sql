
CREATE   FUNCTION [rep].[GetDateFormat] 
(
	@dt datetime, -- input date
	@format int=0 -- specified format
)
RETURNS nvarchar(255)
AS
/*
	Returns the date as a string according to the specified format and input date.
	Dumps the necessary zeros:
	format  input date		result
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
		set @res=case when(@day<10) then '0'+cast(@day as nvarchar(1)) else cast(@day as nvarchar(2))+'.' end;
		set @res=@res+case when(@month<10) then '0'+cast(@month as nvarchar(1)) else cast(@month as nvarchar(2))+'.' end;
		set @res=@res+cast(@year as nvarchar(255));
	end
	else if(@format=1)
	begin
		set @res=case when(@month<10) then '0'+cast(@month as nvarchar(1)) else cast(@month as nvarchar(2))+'.' end;
		set @res=@res+cast(@year as nvarchar(255));
	end
	else if(@format=2)
	begin
		set @res=cast(@year as nvarchar(255));
	end

	RETURN @res;

END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns the date as a string according to the specified format and input date', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetDateFormat';

