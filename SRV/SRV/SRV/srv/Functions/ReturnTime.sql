


CREATE   FUNCTION [srv].[ReturnTime] (@d int)
	RETURNS nvarchar(50)	
AS
BEGIN
	DECLARE @res nvarchar(50);

	set @res=(
			  case when (@d<60)				 then N'00:'+right(N'0'+cast(@d as nvarchar(2)),2) 
				   when (@d>=60 and @d<6000) then right(N'0'+cast(floor(@d/60.0) as nvarchar(2)),2)
											+N':'+right(N'0'+cast(ceiling(((@d/60.0)-floor(@d/60.0))*60)  as nvarchar(50)),2)
				   when (@d>=6000) then right(N'0'+cast(floor(@d/60.0/100.0) as nvarchar(50)),2)+ N':'+
			    right(N'0'+cast(floor((@d - (floor(@d/60.0/100.0))*6000)/60.0) as nvarchar(50)),2) +N':'+
				right(N'0'+cast(ceiling((((@d - (floor(@d/60.0/100.0))*6000)/60.0)- floor((@d - (floor(@d/60.0/100.0))*6000)/60.0))*60)     as nvarchar(50)),2)
			  else N'00:00' 
			  end
			 );
	
	return @res;
END;



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Функция форматировния вывода времени выполнения SQL JOBS из БД msdb. Время переводится в удобичитаемый формат.', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'FUNCTION', @level1name = N'ReturnTime';

