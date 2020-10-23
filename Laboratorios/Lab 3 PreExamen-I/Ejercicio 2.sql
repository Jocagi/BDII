--Laboratorio 3: ejercicio 2
/*
Mostrar las personas con sus respectivas direcciones
a. Nombre
b. Apellido
c. Tipo dirección
d. Línea 1
e. Línea 2
f. Ciudad
*/

select P.FirstName as Nombre, P.LastName as Apellido, AT.Name as Tipo_Dirección, A.AddressLine1 as Línea1, A.AddressLine2 as Línea2, A.City as Ciudad
from Person.Person P 
	inner join Person.BusinessEntityAddress b on b.BusinessEntityID = P.BusinessEntityID
	inner join Person.Address A on b.AddressID = A.AddressID
	inner join Person.AddressType AT on AT.AddressTypeID = b.AddressTypeID






