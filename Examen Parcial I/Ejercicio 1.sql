
-- Ejercicio 1: Parcial
/*
Mostrar la cantidad de ventas y monto total, por cada tipo de tarjeta de crédito y ciudad 
donde se entregó el pedido, tomando en cuenta solamente las ventas donde si se aplicó una tasa de cambio.

Demuestre que su query es el más optimo o bien si aplica crear algún objeto adicional en su 
diseño de base datos para mejorar dicha consulta. Explique si esta de acuerdo o no ( y porque) 
con dicha sugerencia.
*/

Select CC.CardType, A.City, Count(1) As Ventas, Sum(TotalDue) as MontoTotal 
from Sales.SalesOrderHeader OH
Inner Join Sales.CreditCard CC on CC.CreditCardID = OH.CreditCardID 
Inner Join Person.Address A on A.AddressID = OH.ShipToAddressID
Where CurrencyRateID IS NOT NULL
Group by CC.CardType, A.City
Order by CardType, City


/*
Missing Index Details from Ejercicio 1.sql - DESKTOP-0JK7I4P.AdventureWorks2019 (DESKTOP-0JK7I4P\user (56))
The Query Processor estimates that implementing the following index could improve the query cost by 23.4318%.
*/

USE [AdventureWorks2019]
GO
CREATE NONCLUSTERED INDEX [IndexCurrencyRate]
ON [Sales].[SalesOrderHeader] ([CurrencyRateID])
INCLUDE ([ShipToAddressID],[CreditCardID],[TotalDue])
GO

