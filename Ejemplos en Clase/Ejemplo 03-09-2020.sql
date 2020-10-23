
-- Crear una regla donde al actualizar la cantidad de productos en una linea de detalle,
-- actualizar automaticamente el subtotal de dicha linea de detalle
-- adicional actualizar en los N campos de las N tablas respectivas que impacte

Update Purchasing.copiaDetalle
Set OrderQty = 5
Where purchaseorderid = 1 and purchaseorderdetailid = 1


Create trigger Purchasing.T_CambiaDetalle ON
Purchasing.copiaDetalle After Update
As
if update(OrderQty) OR update(UnitPrice) --Validar por campo
Begin

	Update Purchasing.CopiaDetalle
	Set LineTotal = CopiaDetalle.OrderQty * CopiaDetalle.UnitPrice
	from inserted I
	Where I.PurchaseOrderID= CopiaDetalle.PurchaseOrderID AND 
			I.PurchaseOrderDetailID= CopiaDetalle.PurchaseOrderDetailID;

	Update Purchasing.CopiaHeader
	Set SubTotal = (Select SUM(LineTotal) From PurchaseOrderHeader)
		from inserted I
	Where I.PurchaseOrderID= CopiaHeader.PurchaseOrderID

End;
