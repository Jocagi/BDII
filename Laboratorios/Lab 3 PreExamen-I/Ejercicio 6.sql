/*
Sobre los empleados, valide que no permita tener para 1 empleado más de un departamento
activo. 
*/

-- Actualizar el ultimo EndDate para indicar que ya no trabaja en ese departamento

Create trigger ti_validaDepartamento 
on HumanResources.EmployeeDepartmentHistory
After insert as

	declare @id int
	declare @date date

	Select 
	@id = BusinessEntityID,
	@date= StartDate
	From inserted

	Update HumanResources.EmployeeDepartmentHistory
	Set EndDate = @date
	Where 
	BusinessEntityID = @id AND EndDate IS NULL

Select * from HumanResources.EmployeeDepartmentHistory