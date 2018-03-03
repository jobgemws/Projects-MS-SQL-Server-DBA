
CREATE PROCEDURE [srv].[GetRecipients]
@Recipient_Name nvarchar(255)=NULL,
@Recipient_Code nvarchar(10)=NULL,
@Recipients nvarchar(max) out
/*
	Процедура составления почтовых адресов уведомлений
*/
AS
BEGIN
	SET NOCOUNT ON;
	set @Recipients='';
	
	select @Recipients=@Recipients+d.[Address]+';'
	from srv.Recipient as r
	inner join srv.[Address] as d on r.Recipient_GUID=d.Recipient_GUID
	where (r.Recipient_Name=@Recipient_Name or @Recipient_Name IS NULL)
	and  (r.Recipient_Code=@Recipient_Code or @Recipient_Code IS NULL)
	and r.IsDeleted=0
	and d.IsDeleted=0;
	--order by r.InsertUTCDate desc, d.InsertUTCDate desc;

	if(len(@Recipients)>0) set @Recipients=substring(@Recipients,1,len(@Recipients)-1);
END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процедура составления почтовых адресов уведомлений', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'GetRecipients';

