
CREATE   FUNCTION [rep].[GetTimeFormat] 
(
	@dt datetime, -- input time
	@format int=0 -- specified format
)
RETURNS nvarchar(255)
AS
/*
	Returns the time as a string according to the specified format and input time.
	Dumps the necessary zeros:
	format 	input time		result
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
		set @res=case when(@hour<10) then '0'+cast(@hour as nvarchar(1)) else cast(@hour as nvarchar(2))+':' end;
		set @res=@res+case when(@min<10) then '0'+cast(@min as nvarchar(1)) else cast(@min as nvarchar(2))+':' end;
		set @res=@res+case when(@sec<10) then '0'+cast(@sec as nvarchar(1)) else cast(@sec as nvarchar(2)) end;
	end
	else if(@format=1)
	begin
		set @res=case when(@hour<10) then '0'+cast(@hour as nvarchar(1)) else cast(@hour as nvarchar(2))+':' end;
		set @res=@res+case when(@min<10) then '0'+cast(@min as nvarchar(1)) else cast(@min as nvarchar(2)) end;
	end
	else if(@format=2)
	begin
		set @res=case when(@hour<10) then '0'+cast(@hour as nvarchar(1)) else cast(@hour as nvarchar(2)) end;
	end

	RETURN @res;

END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns the time as a string according to the specified format and input time', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'FUNCTION', @level1name = N'GetTimeFormat';

