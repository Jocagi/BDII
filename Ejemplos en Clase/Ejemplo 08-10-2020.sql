
-- Laboratorio transacciones

/* 
	1. Crear un procedimiento que inserte en SalesOrderHeader
	- Reciba las columnas necesarias para insertar
	- Reciba cuantos PRODUCTOS ( lineas ) tendra el detalle
	- Actualizar las columnas respectivas de TOTALES
	
	2. Insertar en SalesOrderDetail
	- Utilizo el mismo del header o creo uno adicional ?
	- Manejar los errores para determinar o confirmar los que si aplican
	- Presentar el resultado del detalle

PROC PRINCIPAL -- una sola vez
	
	insertar el encabezado

	recorrido con los N detalles para insertar el producto-linea
		llamar a un procedimiento especifico para insertar el detalle

	actualizar totales
*/

Create or Alter Procedure Sales.SpIngresaVenta 
		@pOrderDate date, @pCustomerID int, @pProductos int
as
Begin

	Declare @var_ciclo int
	Declare @var_order_nueva int
	Declare @var_ValidaOutput int 

	Begin Transaction
		
		Insert into Sales.SalesOrderHeader
			(OrderDate, DueDate, CustomerID, BillToAddressID, ShipToAddressID, ShipMethodID)
		Values
		(@pOrderDate, @pOrderDate, @pCustomerID, 1, 1, 1)

		-- Ultimo valor autoincremental ingresado
		set @var_order_nueva = SCOPE_IDENTITY() --@@IDENTITY

		If @@ERROR = 0
			Begin
				-- continuar
				commit;
				
				Set @var_ciclo = 0
				
				-- recorrido de N detalles
				while ( @var_ciclo < @pProductos)
				Begin
					
					Exec Sales.pIngresaVentaDetalle @var_order_nueva, @var_ValidaOutput output
					Set @var_ciclo += 1
				
				End

				-- Actualizar totales
				Begin transaction

					Update Sales.SalesOrderHeader
						Set SubTotal = (
										Select SUM(LineTotal) 
										from SalesOrderDetail
										Where SalesOrderID = @var_order_nueva
										)
						Where SalesOrderID = @var_order_nueva
			
					If @@ERROR = 0
						Begin
							commit;
						End
					Else
						Begin
							Print 'Error en Update'
							rollback;
						End

				Print 'OK';
			End
		Else
			Begin
				rollback;
				Print 'Error';
			End
End


Select * from Sales.SalesOrderHeader
Order by 1 DESC

Exec Sales.SpIngresaVenta '2020-03-01', 5, 6

Select * from Sales.SalesOrderDetail
Order by 1 DESC


Create or Alter Procedure Sales.pIngresaVentaDetalle @pOrderID int, @pValidaOutput int output
As
Begin
	Begin Transaction
	
		Insert into Sales.SalesOrderDetail
			(SalesOrderID, ProductID, OrderQty, SpecialOfferID, UnitPrice)
		Values
			(@pOrderID, 772, 5, 1, 25.50)
		
		If @@ERROR = 0
			Begin
				commit;
				Set @pValidaOutput = 1
			End
		Else
			Begin
				rollback;
				Set @pValidaOutput = -1
			End
End


Exec Sales.pIngresaVentaDetalle 75142