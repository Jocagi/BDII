-- Niveles de Aislamiento

------------Ejemplo 1------------

-- Cliente 1
-- No se le hace commit ni rollback a la transaccion
Begin transaction
	Update Sales.SalesOrderDetail
		Set UnitPriceDiscount += 0.2
		Where SalesOrderID = 43662;
--rollback

--Cliente 2
-- Lectura no confirmada
Set transaction isolation level read uncommitted;
-- Lecturas sucias
Select * from Sales.SalesOrderDetail
Where SalesOrderID = 43662;


------------Ejemplo 2------------

-- Cliente 1
-- No se le hace commit ni rollback a la transaccion
Begin transaction
	Update Sales.SalesOrderDetail
		Set UnitPriceDiscount += 0.2
		Where SalesOrderID = 43662;
--rollback

--Cliente 2
-- Lectura confirmada
Set transaction isolation level read committed;
-- Se congela hasta que termine la transaccion
Select * from Sales.SalesOrderDetail
Where SalesOrderID = 43662;

------------Ejemplo 3------------

-- Cliente 1
-- Lectura repetible
Set transaction isolation level repeatable read;
-- Se obtienen los registros garantizando que no se modifiquen
-- Esta transaccion no tiene commit ni rollback
Begin transaction
	Select * from Sales.SalesOrderDetail
	Where SalesOrderID = 43662;
--rollback

--Cliente 2
-- Este se congela hasta que el cliente 1 termine su transaccion
Begin transaction
	Update Sales.SalesOrderDetail
		Set UnitPriceDiscount += 0.2
		Where SalesOrderID = 43662;
rollback



------------Ejemplo 4------------

-- Cliente 1
-- Lectura serializable
Set transaction isolation level serializable;
-- Se obtienen los registros garantizando que no se inserte nada mas
-- Esta transaccion no tiene commit ni rollback
Begin transaction
	Select * from Sales.Currency
	Where CurrencyCode like 'B%';

	Waitfor delay '00:00:10'

	Select * from Sales.Currency
	Where CurrencyCode like 'B%';
commit

	Waitfor delay '00:00:10'

	Select * from Sales.Currency
	Where CurrencyCode like 'B%';

--Cliente 2
-- Este se congela hasta que el cliente 1 termine su transaccion
Begin transaction
	Insert into Sales.Currency
	(CurrencyCode, Name)
	Values
	('BZB', 'BBZZ')
commit


