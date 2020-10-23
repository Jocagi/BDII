-- Triggers
----------------------

--Trigger que notifica cuando hay un cambio en la tabla clientes
Create trigger tiu_aviso on Sales.Customer
	After Insert, Update as
	Print 'Actualiza datos'
	
	--Test
	Update Sales.Customer
	Set PersonID = 10
	Where CustomerID = 8;

	Select * from Sales.Customer;


	Alter trigger tiu_aviso on Sales.Customer
	After Update as
	If UPDATE(PersonId)
		Begin
	Print 'Actualiza datos: PersonaId ->' + PersonId
		End
	Else
		Begin
	Print 'Otra cosa'
		End


	Alter trigger tiu_aviso on Sales.Customer
	After Update as
	
	declare @valorAnterior int
	declare @valorNuevo int

	Select @valorAnterior = PersonID
	From deleted;

	Select @valorNuevo = PersonID
	From inserted;

	If UPDATE(PersonId)
		Begin
	Print 'Actualiza datos: PersonaId'
	Print @valorAnterior
	Print @valorNuevo
		End
	Else
		Begin
	Print 'Otra cosa'
		End


-- Ejemplo 2

Create table PERSONA
(
	ID INT NOT NULL,
	NOMBRE VARCHAR(50),
	NOMBRE_ANTERIOR VARCHAR(50),
	NOMBRE_IGUAL_CUENTA INT
	CONSTRAINT PK_PERSONA PRIMARY KEY(ID)
)

INSERT INTO PERSONA (ID, NOMBRE) VALUES (1, 'Fernando')
INSERT INTO PERSONA (ID, NOMBRE) VALUES (2, 'Lisbeth')
INSERT INTO PERSONA (ID, NOMBRE) VALUES (3, 'Karen')

Select * From PERSONA

Alter trigger tiu_validaPersona on PERSONA
After insert, update as

	declare @nuevoNombre varchar(50)

	Select @nuevoNombre = nombre
	From inserted

	Update PERSONA
	Set Nombre_igual_cuenta = (Select Count(1) From Persona Where nombre = @nuevoNombre)
	Where nombre = @nuevoNombre

INSERT INTO PERSONA (ID, NOMBRE) VALUES (5, 'Karen')

Select * From PERSONA

