/*
	José Carlos Girón Marquez   1064718
	Karen Izabel Paiz González  1215718 
*/


/*No permita ingresar una tarjeta de crédito con diferencia de fecha
de expiración menor a 30 días*/

create trigger Sales.CreditCard_triggerFechaExp on Sales.CreditCard after insert as
declare @Año int
declare @Mes int
select @Año = ExpYear, @Mes = ExpMonth 
from inserted

if(DATEPART(YEAR,GETDATE())< @Año) or (DATEPART(YEAR,GETDATE())= @Año AND @Mes<=DATEPART(Month,GETDATE()))
BEGIN
	DELETE  Sales.CreditCard
	from inserted i
	WHERE CreditCard.CreditCardID = i.creditcardID
	print 'Tarjeta vencida o a punto de expirar'
END;


/*No permita ingresar y/o actualizar un correo electronico asocido a otra persona*/

create trigger Person.Email_dif_update on Person.EmailAddress after update as

declare @email varchar(50)
declare @contador int

select @email=EmailAddress
from inserted

select @contador = COUNT(1)
from Person.EmailAddress EA
where EA.EmailAddress = @email

if(@contador > 1)
begin
	print 'email repetido'
	declare @emailAnt varchar(50)
	select @emailANT=EmailAddress
    from deleted

	IF(update(emailAddress))
	begin
		UPDATE Person.EmailAddress
		SET EmailAddress = @emailAnt

		from inserted i 
		where i.BusinessEntityID = Person.EmailAddress.BusinessEntityID AND Person.EmailAddress.EmailAddressID = I.EmailAddressID
	end

end;


create trigger Person.Email_dif_insert on Person.EmailAddress after insert as
declare @email varchar(50)
declare @contador int

select @email=EmailAddress
from inserted

select @contador = COUNT(1)
from Person.EmailAddress EA
where EA.EmailAddress = @email
if(@contador > 1)
begin
	print 'email repetido'

	declare @emailAnt varchar(50)
	select @emailANT=EmailAddress
    from deleted

	DELETE  Person.EmailAddress 
	from inserted i
	WHERE i.BusinessEntityID = Person.EmailAddress.BusinessEntityID AND Person.EmailAddress.EmailAddressID = I.EmailAddressID		
end;



/*Actualizar el inventario del producto al vender cada uno de ellos. Al momento
que se confirma y/o cancela la venta.*/

select *
from sales.SalesOrderHeader

create trigger Sales.SalesOrderDetail_cant_productos on Sales.SalesOrderDetail after insert, update as
declare @cant_ant int
declare @cant_new int

select @cant_ant = OrderQty
from deleted

select @cant_new = OrderQty
from inserted

if(update(orderQty))
begin 
	update Production.ProductInventory
	set Quantity = Quantity + (@cant_ant - @cant_new)
	from inserted i
	WHERE i.ProductID = Production.ProductInventory.ProductID 		
end;

select *
from Production.TransactionHistory