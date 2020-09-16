--EJERCICIO 7
/*
�Cu�l es el producto m�s vendido, por a�o? Tome en cuenta �nicamente los productos que se
hayan vendido a m�s de un cliente. 
*/
select A.A�o, A.Cantidad1, I.Producto, P.Name 
from(
		select A�o, Max(Cantidad)  as Cantidad1
		from (
				select  DATEPART(YEAR, SOH.OrderDate) as A�o, SD.ProductID as Producto,  SUM(OrderQty) AS Cantidad
				from  Sales.SalesOrderDetail SD
				INNER JOIN Sales.SalesOrderHeader SOH ON SD.SalesOrderID = SOH.SalesOrderID
				inner join (
							select ProductID, COUNT(DISTINCT SOH.CustomerID) as cantidad
							from Sales.SalesOrderDetail SD
							INNER JOIN Sales.SalesOrderHeader SOH ON SD.SalesOrderID = SOH.SalesOrderID
							group by SD.ProductID
							having ( COUNT(DISTINCT SOH.CustomerID) > 1)
							) J on J.ProductID = SD.ProductID
				group by DATEPART(YEAR, SOH.OrderDate),SD.ProductID
			) H 
			group by A�o) A inner join(
				select  DATEPART(YEAR, SOH.OrderDate) as A�o, SD.ProductID as Producto,  SUM(OrderQty) AS Cantidad
				from  Sales.SalesOrderDetail SD
				INNER JOIN Sales.SalesOrderHeader SOH ON SD.SalesOrderID = SOH.SalesOrderID
				inner join (
							select ProductID, COUNT(DISTINCT SOH.CustomerID) as cantidad
							from Sales.SalesOrderDetail SD
							INNER JOIN Sales.SalesOrderHeader SOH ON SD.SalesOrderID = SOH.SalesOrderID
							group by SD.ProductID
							having ( COUNT(DISTINCT SOH.CustomerID) > 1)
							) J on J.ProductID = SD.ProductID
				group by DATEPART(YEAR, SOH.OrderDate),SD.ProductID
			) I on A.Cantidad1 = I.Cantidad  inner join Production.Product P on I.Producto = P.ProductID
ORDER BY A�o

