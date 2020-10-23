--Resolucion de Lab1

--LAB1
--Ej1

Select p.Name, YEAR(StartDate) as Year, COUNT(1) as Qty
from Production.WorkOrder WO
	Inner Join Production.Product P ON WO.ProductID = P.ProductID
Group by p.Name, YEAR(StartDate)
Order by 1,2


--Ej2

--Transaccion
begin tran --Proced. pendiente
rollback -- Regresar al estado anterior

Create Procedure Purchasing.uspModificarMetodo
@year integer,
@month integer,
@product integer
As
Begin
Update Purchasing.PurchaseOrderHeader
Set	   ShipMethodID = 3
From  Purchasing.PurchaseOrderHeader POH
	  Inner Join Purchasing.PurchaseOrderDetail POD ON
	  POH.PurchaseOrderID = POD.PurchaseOrderID
Where YEAR(OrderDate)  = @year AND
	  MONTH(OrderDate) = @month AND
	  POD.ProductID =	@product;
End

exec Purchasing.uspModificarMetodo


--Ej3
Create Function obtenerPromedioPrecio(@id int) returns money
as
Begin

Declare @Retorna money

	Select @Retorna = AVG( OD.UnitPrice )
	From Purchasing.PurchaseOrderDetail OD 
	Where OD.PurchaseOrderID = @id
	
return @Retorna

End

Select PurchaseOrderID, OrderDate, TotalDue, dbo.getAverage(PurchaseOrderID) as Average
from Purchasing.PurchaseOrderHeader OH
