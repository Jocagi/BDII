/*
	Integrantes:
	Jos� Carlos Gir�n Marquez   1064718
	Karen Izabel Paiz Gonz�lez  1215718 

*/


/*

Crear un procedimiento que aplique un descuento D a
cada uno de los productos vendidos para cierta Orden de
venta. Siempre y cuando la cantidad de dicho producto
sea mayor a 2. Mientras ocurre dicha actualizaci�n nadie
puede visualizar ni actualizar la informaci�n relacionada a
dicha orden.

*/

Select * from Sales.SalesOrderHeader
Select * from Sales.SalesOrderDetail

Create or Alter Procedure Sales.pAplicaDescuento @pOrdenID int, @pDescuento money
As
Begin
	Set transaction isolation level repeatable read;

	Begin Transaction

		Update Sales.SalesOrderDetail
		Set UnitPriceDiscount = @pDescuento
		Where SalesOrderID = @pOrdenID

		If @@ERROR = 0
			Begin
				Print 'Descuento aplicado con exito'
				commit;
			End
		Else
			Begin
				Print 'Error al aplicar descuento'
				rollback;	
			End
End

Exec Sales.pAplicaDescuento 43659, 0.65


/*

Al departamento de DWH le han solicitado generar una
tabla resumen de las compras realizadas. Dicha tabla
resumen requiere la informaci�n de: A�o, Mes, producto,
cantidad de unidades vendidas, precio y descuentos aplicados

Dicha informaci�n se debe generar cada hora y
debe asegurarse de generar el 100% de los registros, aun
as�, se est�n actualizando.

�Qu� riesgo encuentra dentro de esta generaci�n de
datos?
�Qu� sugerencia/cambio aplicar�a a la solicitud?

*/

/*
No es recomentable realizar esta clase de lectura, 
ya que los datos son impredecibles.
Recomendaria mas hacen una lectura confirmada.
*/


Create Table Sales.DWHResumen 
		(
		    ID int IDENTITY(1,1) PRIMARY KEY,
			Year smallint,
			Month tinyint,
			ProductID int,
			ProductPrice money,
			Discounts money,
			Sales int
		)
    

Create or Alter Procedure Sales.pDWHResumen
As
Begin
	
	Set transaction isolation level read uncommitted;

	Begin Transaction
		
		Truncate Table Sales.DWHResumen

		Insert into Sales.DWHResumen
		Select 
			YEAR(OH.OrderDate) as Year,
			MONTH(OH.OrderDate) as Month,
			OD.ProductID as Product,
			P.ListPrice as Price,
			SUM(OD.LineTotal) - SUM(OD.UnitPrice) as Discounts,
			COUNT(1) as Sales
		From Sales.SalesOrderHeader OH
		Inner Join Sales.SalesOrderDetail OD
					on OH.SalesOrderID = OD.SalesOrderID
		Inner Join Production.Product P
					on OD.ProductID = P.ProductID
		Group by YEAR(OH.OrderDate), MONTH(OH.OrderDate), OD.ProductID, P.ListPrice

		If @@ERROR = 0
			Begin
				Print 'Tabla generada con exito'
				commit;
			End
		Else
			Begin
				Print 'Error al generar tabla'
				rollback;	
			End
End

Exec Sales.pDWHResumen

Select * From Sales.DWHResumen



/*

Realizar un proceso para la carga de datos de personas con sus n�meros telef�nicos. La carga se 
realizar� a partir de un archivo .csv con el formato:
Apellido,tipo tel�fono, tel�fono Nombre2, Nombre1, tel�fono

Se debe validar si ya existe el cliente, tipo tel�fono o tel�fono, no insertarlo. 
Y poder manejar los errores para permitir y asegurar la actualizaci�n 
de los datos (seg�n su nivel) aunque existan errores posteriores.

*/


BEGIN TRAN 	addPersona

CREATE TABLE temp ( Nombre1 nvarchar(50), Nombre2 nvarchar(50), Apellido nvarchar(50), PhoneType int, Phone nvarchar(25));
BULK INSERT dbo.temp 
FROM 'c:\file.csv'
WITH 
  (
	ROWTERMINATOR =','
  ) 
declare @contador int
select @contador = COUNT(1)
from Person.Person PP inner join temp on (PP.FirstName = temp.Nombre1 AND PP.MiddleName = temp.Nombre2 AND PP.LastName = temp.Apellido)
declare @Type int
declare @Phone nvarchar(25)
declare @FName nvarchar(50)
declare @MName nvarchar(50)
declare @LName nvarchar(50)
DECLARE @BussinesEntityID int
select top 1 @BussinesEntityID = BusinessEntityID
from person.BusinessEntity
order by BusinessEntityID desc
select top 1 @Type = PhoneType, @Phone = Phone, @FName = Nombre1, @MName = Nombre2, @LName = Apellido
from temp

if(@contador > 0)
begin
	print 'La persona ya existe'
end
else
BEGIN
	if(@Type > 3 OR @TYPE < 0 )
	BEGIN 
		print 'El tipo no corresponde'
	END
	ELSE
	BEGIN
		declare @cont int
		select @cont = COUNT(1)
		from Person.PersonPhone
		where PhoneNumber = @Phone
		if(@Cont > 0)
		BEGIN
			print 'El numero ya existe'
		END
		ELSE
		BEGIN
			SET IDENTITY_INSERT Person.BusinessEntity On
			INSERT INTO Person.BusinessEntity (BusinessEntityID) VALUES (@BussinesEntityID +1)
			INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, MiddleName, LastName, EmailPromotion) VALUES (@BussinesEntityID +1, 'VC', 0, @FName, @MName, @LName, 0)
			INSERT INTO PERSON.PersonPhone(BusinessEntityID, PhoneNumber, PhoneNumberTypeID) VALUES(@BussinesEntityID +1, @Phone, @Type)
			COMMIT
		END
	END
END
DROP TABLE temp
