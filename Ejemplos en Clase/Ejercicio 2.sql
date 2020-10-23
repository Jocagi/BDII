-- Crear SP que obtenga el primer contacto por apellido

Create procedure Person.uspObtenerContacto as
Begin
	
	Select Top 1 v.Name, p.LastName, p.LastName
	from Purchasing.Vendor v
		Inner Join Person.BusinessEntityContact bec
				on v.BusinessEntityID = bec.BusinessEntityID
		Inner Join Person.Person p
				on p.BusinessEntityID = bec.PersonID
		Inner Join Person.ContactType ct
				on bec.ContactTypeID = ct.ContactTypeID
End

Exec Person.uspObtenerContacto


-- Crear SP que obtenga el primer contacto por nombre, 
-- recibiendo como parametro el apellido

Alter procedure Person.uspObtenerContacto 
			@pLastName VARCHAR(50)
as
Begin
	
	Select Top 1 v.Name, p.FirstName, p.LastName, ct.Name
	from Purchasing.Vendor v
		Inner Join Person.BusinessEntityContact bec
				on v.BusinessEntityID = bec.BusinessEntityID
		Inner Join Person.Person p
				on p.BusinessEntityID = bec.PersonID
		Inner Join Person.ContactType ct
				on bec.ContactTypeID = ct.ContactTypeID
	Where @pLastName = p.LastName
	order by FirstName;
End

Exec Person.uspObtenerContacto 'Moya'
