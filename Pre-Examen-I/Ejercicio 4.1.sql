-- Ejercicio 4

/*
Aplicar un aumento del 10% a todos los empleados de la empresa:
a. Utilizando un cursor:
i. Actualizar el “rate”, aumentando un 10% del último sueldo.
ii. Si la persona es de Ventas, aumentar también un 10% su Bono. Implementando
un trigger. 
*/

Declare @Id int
Declare @RateDate datetime
Declare @Rate money
Declare @payFreq tinyint
Declare @ModifiedDate datetime

Declare Bonus Cursor for
Select EP.BusinessEntityID, H.RateChangeDate, Rate + Rate*0.10 as Rate, PayFrequency
From HumanResources.EmployeePayHistory EP
Right Join
	(
	Select BusinessEntityID, MAX(RateChangeDate) as RateChangeDate
	From HumanResources.EmployeePayHistory
	Group by BusinessEntityID
	 )H
	 on H.BusinessEntityID = EP.BusinessEntityID 
Order by EP.BusinessEntityID ASC

Open Bonus
	Fetch next from Bonus into @Id, @RateDate, @Rate, @payFreq
While @@FETCH_STATUS = 0
Begin
   Insert Into HumanResources.EmployeePayHistory
   (BusinessEntityID, RateChangeDate, Rate, PayFrequency, ModifiedDate)
   Values
   (@Id, GetDate(), @Rate, @payFreq, GetDate())
	Fetch next from Bonus into @Id, @RateDate, @Rate, @payFreq
End
Close Bonus
Deallocate Bonus

Select * from HumanResources.EmployeePayHistory 