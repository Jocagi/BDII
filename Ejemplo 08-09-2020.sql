
-- Estadisticas

Select *
from sys.objects
where name like '%Purchase%' and type = 'u'

Select * 
from sys.stats
where object_id = 1602104748

DBCC show_statistics ('Purchasing.PurchaseOrderHeader', '_WA_Sys_00000006_5F7E2DAC')


Create statistics orderH_status 
on Purchasing.PurchaseOrderHeader (Status)

DBCC show_statistics ('Purchasing.PurchaseOrderHeader', 'orderH_status')

Select * 
from Purchasing.PurchaseOrderHeader POH
Inner Join Purchasing.PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID