
-- Ejercicio 2: Parcial
/*
Al realizar una calificación/revisión de un producto comprado por los clientes, 
no debe permitir ingresar más de una revisión para una misma fecha 
y correo siempre y cuando la existencia de dicho producto sea mayor a 100.
*/

Create trigger Production.ti_AgregarReview on Production.ProductReview
Instead of insert
As

Declare @Id int
Declare @ProdId int
Declare @Name nvarchar(50)
Declare @Date datetime
Declare @Email nvarchar(50)
Declare @Rating int
Declare @Comment nvarchar(50)

Declare @Existencia_Producto smallint

Select 
	@Id = ProductReviewID,
	@ProdId = ProductID,
	@Name = ReviewerName,
	@Date = ReviewDate,
	@Email = EmailAddress,
	@Rating = Rating,
	@Comment = Comments
From inserted

Select @Existencia_Producto = Quantity 
From Production.ProductInventory PI
Where 
	PI.LocationID = 60 --Final Assembly Location ID
	AND ProductID = @ProdId

if(@Existencia_Producto >= 100)
begin
	
	declare @Duplicados int

	Select @Duplicados = COUNT(1) 
	From Production.ProductReview
	Where 
		EmailAddress = @Email AND
		ReviewDate = @Date

	if(@Duplicados > 0)
	begin
		print('Ya ha ingresado una reseña ')	
	end
	else
	begin
		Insert Into 
			Production.ProductReview
			(ProductID, ReviewerName, ReviewDate, EmailAddress, Rating, Comments, ModifiedDate) 
		Values 
			(@ProdId, @Name, @Date, @Email, @Rating, @Comment, GETDATE())
		print('Agregado con éxito')
	end
end

else
begin
	print('No puede agregar la reseña debido a que no hay suficientes productos en existencia')
end