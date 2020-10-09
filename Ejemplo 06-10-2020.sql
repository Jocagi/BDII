
Select *
from Sales.SalesOrderHeader

--Para mas de 50 ventas
Alter table Sales.SalesPerson Add Mayor Integer

Select *
from Sales.SalesPerson

Begin Transaction
Update Sales.SalesPerson
	Set Mayor = 
				(
				Select case when Count(1) > 50 then 1 else 0 end mayor
				from Sales.SalesOrderHeader SOH 
				where SalesPersonID = BusinessEntityID
				)
-- Ver cuantas filas fueron modificadas
If (@@ROWCOUNT > 5)
Begin
	Commit;
	Print ' Commit ';
End
Else
Begin
	Rollback;
	Print ' Rollback ';
End
