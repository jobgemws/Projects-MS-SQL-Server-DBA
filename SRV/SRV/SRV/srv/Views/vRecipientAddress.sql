create view [srv].[vRecipientAddress] as
select t1.Address, 
	   t2.Recipient_Code, 
	   t2.Recipient_Name, 
	   t1.IsDeleted as AddressIsDeleted,
	   t2.IsDeleted as RecipientIsDeleted
from [srv].[Address] as t1
inner join [srv].[Recipient] as t2 on t1.Recipient_GUID=t2.Recipient_GUID

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адресаты с почтовыми адресами', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vRecipientAddress';

