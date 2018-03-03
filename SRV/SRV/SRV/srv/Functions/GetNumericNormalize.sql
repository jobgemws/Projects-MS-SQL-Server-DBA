
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [srv].[GetNumericNormalize]
(
	@str nvarchar(256) -- входное число в виде строки
)
RETURNS nvarchar(256)
AS
/*
	15.04.2014 ГЕМ:
	У входного числа в виде строки отсекает лишние нули после запятой
*/
BEGIN
	declare @ind int;
	set @ind=0;
	declare @result nvarchar(256);

	if(PATINDEX('%.%', @str)>0)
	begin
		while(substring(@str, len(@str)-@ind,1)='0') set @ind=@ind+1;
		set @result=left(@str, len(@str)-@ind);
		if(right(@result,1)='.') set @result=left(@result, len(@result)-1);
	end
	
	RETURN @result;
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'У входного числа в виде строки отсекает лишние нули после запятой', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'FUNCTION', @level1name = N'GetNumericNormalize';

