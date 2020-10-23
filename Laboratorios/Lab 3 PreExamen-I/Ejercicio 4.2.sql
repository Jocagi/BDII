
Create trigger HumanResources.Bono on HumanResources.EmployeePayHistory after update
as
if UPDATE(rate)
begin
	DECLARE @Id AS int
	select @Id = BusinessEntityID
	from inserted


	DECLARE @puesto  as varchar(50)

	select @puesto = D.Name
	from HumanResources.Employee E
	inner join HumanResources.EmployeeDepartmentHistory EDH on E.BusinessEntityID = EDH.BusinessEntityID
	inner join HumanResources.Department D on EDH.DepartmentID = D.DepartmentID
	WHERE E.BusinessEntityID = @Id

	if(@puesto = 'Sales')
	Begin
		update Sales.SalesPerson
		SET Bonus = Bonus + (Bonus *0.1)
		where Sales.SalesPerson.BusinessEntityID = @Id

	END
END;
