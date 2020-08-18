
-- Ejercicio 1 (Adventureworks)

--  Para cada cliente con su dirección de casa en
--  Redmond, mostrar el campo line1 de dicha
--	dirección y los campos line1,city de la dirección de
--	entrega (dejar en blanco si no tiene)

Select P.FirstName, P.LastName, BEA.AddressID, BEA.AddressTypeID, A.AddressLine1, A.City 
from Person.Person P
	Inner Join Person.BusinessEntity BE on (P.BusinessEntityID = BE.BusinessEntityID)
	Inner Join Person.BusinessEntityAddress BEA on 
		(BE.BusinessEntityID = BEA.BusinessEntityID and BEA.AddressTypeID = 2)
	Inner Join Person.Address A on
		(BEA.AddressID = A.AddressID and A.City = 'Redmond')
Order by P.BusinessEntityID

-- Mostrar las 3 mas importantes ciudades ( en cuanto a las ventas realizadas ).

Select Top 3 C.Name, Count(1) as Sales 
from Sales.SalesOrderHeader O
	Inner Join Sales.SalesTerritory T on O.TerritoryID = T.TerritoryID 
	Inner Join Person.CountryRegion C on C.CountryRegionCode = T.CountryRegionCode
Group by C.Name
Order by Sales DESC

-- Cuantas ventas se han realizado según los rangos de venta de: 0 99; 100 999; 1000 9999; 10000+

Select 
	Count(CASE WHEN O.TotalDue >= 0 and O.TotalDue <= 99 THEN 1 END) as Sales0_99,
	Count(CASE WHEN O.TotalDue >= 100 and O.TotalDue <= 999 THEN 1 END) as Sales100_999,
	Count(CASE WHEN O.TotalDue >= 1000 and O.TotalDue <= 9999 THEN 1 END) as Sales1000_9999,
	Count(CASE WHEN O.TotalDue >= 10000 THEN 1 END) as Sales10000
from Sales.SalesOrderHeader O

-- Muestre el total de venta por cada Region. Del mayor al menor

Select 
	C.Name,
	Sum(TotalDue) as Total
from Sales.SalesOrderHeader O
	Inner Join Sales.SalesTerritory T on O.TerritoryID = T.TerritoryID 
	Inner Join Person.CountryRegion C on C.CountryRegionCode = T.CountryRegionCode
Group by C.Name
Order by Total DESC



-- Ejercicio 2 (Employees)

-- Listar todos los empleados contratados en el 2019. Incluyendo: Nombre, departamento, fecha contratación y salario

Select fist_name, department_name, hire_date, salary 
from Employees E
	Inner Join Departments D on D.department_id = E.department_id
where hire_date = 2019

-- Mostrar los paises que tengan mas de 5 empleados contratados.

Select C.Name, Count(1) as EmployeesCount 
from Countries C
	Inner Join Locations L on L.country_id = C.country_id
	Inner Join Departments D on D.location_id = L.location_id
	Inner Join Employees E on E.department_id = D.department_id
group by C.Name
where EmployeesCount > 5
	