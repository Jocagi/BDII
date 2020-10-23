
-- Integrantes:
-- Karen Izabel Paiz Gonzalez 1215718
-- Jose Carlos Giron Marquez 1064718
-- Pablo Javier Garcia Montenegro 1174216


-- 1.
Select P.Name ,YEAR(WO.ModifiedDate) As YEAR, SUM(OrderQty) as Ordenes
from Production.WorkOrder WO
	Inner Join Production.Product P ON
		WO.ProductID = P.ProductID
Group by YEAR(WO.ModifiedDate), P.Name;

-- 2.

Create Procedure uspUpdatePurchase
				@pYear integer,
				@pMonth integer, 
				@pName nvarchar(50)
as
Begin

	UPDATE Purchasing.PurchaseOrderHeader
	SET ShipMethodID = 3
	From 
	Purchasing.PurchaseOrderHeader OH
	Inner Join Purchasing.PurchaseOrderDetail OD ON OD.PurchaseOrderID = OH.PurchaseOrderID
	Inner Join Production.Product P ON OD.ProductID = P.ProductID
	Where @pName = P.Name And @pMonth = MONTH(OH.OrderDate) And @pYear = YEAR(OH.OrderDate)

End


-- 3.

Create Function getAverage(@id int) returns money
as
Begin

Declare @Retorna money

	Select @Retorna = AVG( OD.UnitPrice )
	From Purchasing.PurchaseOrderDetail OD
	Where PurchaseOrderID = @id
	Group by PurchaseOrderID

return @Retorna

End

Select PurchaseOrderID, OrderDate, TotalDue, dbo.getAverage(PurchaseOrderID) as Average
from Purchasing.PurchaseOrderHeader OH
