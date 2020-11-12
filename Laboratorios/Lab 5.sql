
-- Realizar una consulta ( query ) que muestre la información de las ventas realizadas por cliente
-- para los años entre 2011 y 2015, mostrando los datos como una tabla resumen:

Select 
P.BusinessEntityID As Cliente,
SUM(CASE WHEN YEAR = 2011 THEN Total ELSE 0 END) AS A2011,
SUM(CASE WHEN YEAR = 2012 THEN Total ELSE 0 END) AS A2012,
SUM(CASE WHEN YEAR = 2013 THEN Total ELSE 0 END) AS A2013,
SUM(CASE WHEN YEAR = 2014 THEN Total ELSE 0 END) AS A2014,
SUM(CASE WHEN YEAR = 2015 THEN Total ELSE 0 END) AS A2015
From 
(
	Select 
	C.PersonID AS ID,
	YEAR(SOH.OrderDate) AS YEAR,
	SOH.TotalDue As Total
	from Sales.SalesOrderHeader SOH
	Inner Join Sales.Customer C on C.CustomerID = SOH.CustomerID
)data
Inner Join Person.Person P on P.BusinessEntityID = data.ID
Group by BusinessEntityID
Order by BusinessEntityID


-- Obtenga un query para poder listar todos los objetos de la base de datos con sus respectivos 
-- privilegios que se han otorgado,como mínimo debería de tener la siguiente información

CREATE ROLE AnalistaRH;
DENY CREATE TABLE, CREATE PROCEDURE TO AnalistaRH;

SELECT DISTINCT DB_NAME() AS 'DBName'
      ,p.[name] AS 'Rol/Usuario'
      ,p.[type_desc] AS 'Tipo'
      ,dbp.[permission_name] AS 'Nombre_Permiso'
      ,dbp.[state_desc] AS 'Tipo_Permiso'
      ,so.[Name] AS 'Objecto'
FROM [sys].[database_permissions] dbp 
	LEFT JOIN [sys].[objects] so
		ON dbp.[major_id] = so.[object_id] 
	LEFT JOIN [sys].[database_principals] p
		ON dbp.[grantee_principal_id] = p.[principal_id] 
	LEFT JOIN [sys].[database_principals] p2
		ON dbp.[grantor_principal_id] = p2.[principal_id]
