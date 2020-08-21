
-- Crear un procedimiento que reciba como parametro:
-- el apellido de un contactomy regrese el contact id 
-- de la primer ocurrencia (contacto) con dicho apellido

Create Procedure person.uspGetCodeContact
				@pLastName varchar(50),
				@pContactId integer output 
as
Begin

	Select Top 1 @pContactId = p.BusinessEntityID
	From Purchasing.Vendor v
		Inner Join Person.BusinessEntityContact BEC
			on BEC.BusinessEntityID = v.BusinessEntityID
		Inner Join Person.Person p
			on BEC.PersonID = p.BusinessEntityID
	Where p.LastName = @pLastName;

End

-- Ejecutar

Declare @pID integer;
Set @pID = 0;
Exec Person.uspGetCodeContact 'Mohan', @pID output;
Print @pID;

If(@pID = 0)
	Begin
	Print 'Persona no encontrada';
	End
Else
	Begin
		Select BusinessEntityID, FirstName, LastName, Demographics
		From Person.Person
		Where BusinessEntityID = @pID
	End




-- Crear una funciona que retorna la existencia de un producto en inventario

Select ProductID, name, 3 cantidad_existencia
From Production.Product P

Create Function getProductStock(@id int) returns int
as
Begin

Declare @iRetorna int

	Select @iRetorna = Quantity 
	From Production.ProductInventory
	Where ProductID = @id and LocationID = 50

if @iRetorna is NULL
	Begin
		return 0
	End

return @iRetorna

End

