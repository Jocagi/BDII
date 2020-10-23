--Laboratorio 3: ejercicio 3
/*
Cuantas ordenes de trabajo se han realizado por producto en cada a�o.
a. Nombre producto
b. A�o
c. Cantidad de ordenes de trabajo
*/


select DATEPART(year, wo.StartDate) as a�o, P.Name as Nombre_Producto, COUNT(1) as Cantidad_Ordenes
from	Production.WorkOrder wo
inner join Production.Product P on WO.ProductID = P.ProductID
group by DATEPART(year, wo.StartDate), P.Name