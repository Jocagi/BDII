-- Laboratorio 3: Ejercicio 1
/*
Crear una tabla resumen con la siguiente información sobre las ventas que se han realizado:
a. Nombre de cliente
b. Año de compra
c. Mes de compra
d. Cantidad de compras para ese año-mes del cliente
e. Código de la primer Orden de Compra de ese año-mes
f. Numero de meses de compra:
	i. De los productos de la primer OC , 6 meses para atrás, en cuántos de ellos
	realizó por lo menos una compra con alguno de dichos productos.

Cree un procedimiento el cual realice la operación descrita anteriormente y como primer paso
trunque la tabla resumen. 
*/

Create table Sales.Resumen 
(
	id int NOT NULL,
	name nvarchar(50) NOT NULL,
	year smallint NOT NULL,
	month tinyint NOT NULL,
	purchasesQty int,
	POid int,
	monthQty tinyint
)

DROP TABLE Sales.Resumen

Create Procedure Sales.uspLlenarResumen
As
Begin

	Truncate table Resumen;

	-- id, name, year, month, purchaseQty
	Select
	P.BusinessEntityID as id,
	(P.FirstName + ' ' + P.LastName) as Name,
	DATEPART(YEAR, OrderDate) as Year,
	DATEPART(MONTH, OrderDate) as Month,
	COUNT(1) as PurchasesQty
	into #tmpResumen
	from Sales.Customer C
	Inner Join Person.Person P
			on P.BusinessEntityID = C.PersonID
	Inner Join Sales.SalesOrderHeader OH
			on C.CustomerID = OH.CustomerID
	Group by 
	P.BusinessEntityID,
	P.FirstName + ' ' + P.LastName, 
	DATEPART(YEAR, OrderDate), DATEPART(MONTH, OrderDate);

	-- Primer orden de compra por persona
	Select id, year, month, OH.SalesOrderID as POid, date 
	into #tmpOC
	From
	(
	Select  id, DATEPART(Year, OrderDate) as year,
				DATEPART(Month, OrderDate) as month, 
				MIN(OrderDate) as date
	from Sales.SalesOrderHeader OH
	Inner Join Person.Person P
			on P.BusinessEntityID = OH.CustomerID
	Inner Join #tmpResumen R 
			on R.id = OH.CustomerID
	Group by id, DATEPART(Year, OrderDate), DATEPART(Month, OrderDate) 
	)o
	Inner Join  Sales.SalesOrderHeader OH on o.date = OH.OrderDate 
				and	o.id = OH.CustomerID
	Order by id, year, month;


	-- Numero de meses de compra

	Insert into Sales.Resumen 
	(id, name, year, month, purchasesQty, POid, monthQty)
	Select Distinct o.id, R.Name, o.year, o.month, R.PurchasesQty, T.POid,  monthQty
	From 
	(
		Select id, year, month, COUNT(monthOrder) as monthQty 
		From
		(
			Select id, year, month, ProductID, DATEPART(Month, OrderDate) as monthOrder, 
			COUNT(DISTINCT DATEPART(Month, OrderDate)) as monthQt
			from #tmpOC T
			Inner Join Sales.SalesOrderHeader OH on OH.SalesOrderID = T.POid
			Inner Join Sales.SalesOrderDetail OD on OD.SalesOrderID = T.POid
			Where OH.OrderDate Between DateAdd(month, -6, Convert(date, T.date)) and T.date
			Group by id, ProductID, DATEPART(Month, OrderDate), month, year
		)o
		Group by id, year, month
	)o
	Inner Join #tmpOC T on T.id = o.id AND T.month = o.month AND T.year = o.year
	Inner Join #tmpResumen R on R.id = o.id AND R.month = o.month AND R.year = o.year
	Order by id;

	Drop table #tmpOC;
	Drop table #tmpResumen;

End


Select * from Sales.Resumen