CREATE   PROCEDURE [rep].[GetProjectHoursInDate]
(
	@user_display nvarchar(255),
	@stdate date,
	@fndate date
)
AS BEGIN
/*
	затраченное время в часах выбранного сотрудника по проектам и датам
*/  
    SET NOCOUNT ON;  
  
    set transaction isolation level read uncommitted;

	set @fndate=DateAdd(day,1, @fndate);
	
	declare @lower_user_name nvarchar(255);
	
	select top(1)
	@lower_user_name=[lower_user_name]
	FROM [Jira].[dbo].[cwd_user]
	  where [display_name] = @user_display;
	
	select p.[pkey] as [ProjectKey], p.[pname] as [ProjectName], ji.SUMMARY, cast(wl.[STARTDATE] as DATE) as [DATE], cast(cast(sum(wl.[timeworked]) as numeric(18,3))/3600 as numeric(18,3)) as [DurationHour]
	from [Jira].[dbo].[project]   as p
	join [Jira].[dbo].[jiraissue] as ji on (ji.[PROJECT] = p.[ID])
	join [Jira].[dbo].[worklog]   as wl on (wl.[issueid]=ji.[ID])
	where wl.[AUTHOR]=@lower_user_name--кто+также можно проект и диапазон дат
	and wl.[STARTDATE] between @stdate and @fndate
	group by cast(wl.[STARTDATE] as DATE), p.[pkey], p.[pname], ji.SUMMARY;
  
END  

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает затраченное время в часах выбранного сотрудника по проектам и датам', @level0type = N'SCHEMA', @level0name = N'rep', @level1type = N'PROCEDURE', @level1name = N'GetProjectHoursInDate';

