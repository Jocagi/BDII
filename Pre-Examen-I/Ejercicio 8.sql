-- Ejercicio 8

/*
Actualice la comisión a pagar para los vendedores, cada vez que ocurra algún movimiento de
venta. 
*/

Select * from Sales.SalesPerson

ALTER TABLE Sales.SalesPerson ADD Commission money NULL;

Create trigger ti_ComisionVendedor 
on Sales.SalesOrderHeader
After insert as

	declare @id int
	declare @venta date

	Select 
	@id = SalesPersonID,
	@venta = SubTotal
	From inserted

	Update Sales.SalesPerson
	Set Commission = CommissionPct * @venta
	Where 
	BusinessEntityID = @id
