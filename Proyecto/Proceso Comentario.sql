
Create or Alter Procedure uspIngresarComentario
@ID_Publicacion integer,
@ID_Usuario integer,
@ID_Dispositivo integer,
@ID_Tipo integer,
@Contenido nvarchar(50),
@IP_Address nvarchar(50)
As
Begin

	Declare @ComentPublicacion integer;
	Declare @ID_Comentario integer;

	-- Contar cantidad total de comentarios para una publicacion dada
	Select @ComentPublicacion = COUNT(1)
	from COMENTARIO
	Where	ID_PUBLICACION_REF = @ID_Publicacion 
			AND ACTIVO = 1

	-- Ingresar contenido del comentario
	Insert Into PUBLICACION (ID_DISPOSITIVO, ID_TIPO_PUBLICACION, ID_USUARIO, FECHA_HORA, CONTENIDO, IP)
	Values (@ID_Dispositivo, @ID_Tipo, @ID_Usuario, GETDATE(), @Contenido, @IP_Address);

	-- Vlaor del ID comentaario
	Set @ID_Comentario = SCOPE_IDENTITY();

	-- Validar activo/inactivo
	IF (@ComentPublicacion < 3)
		Begin
			Insert Into COMENTARIO (ID_COMENTARIO, ID_PUBLICACION_REF, ACTIVO)
			Values (@ID_Comentario, @ID_Publicacion, 1)
		End
	Else
		Begin
			Insert Into COMENTARIO (ID_COMENTARIO, ID_PUBLICACION_REF, ACTIVO)
			Values (@ID_Comentario, @ID_Publicacion, 0)
		End
End

Select * from PUBLICACION
Select * from COMENTARIO
exec uspIngresarComentario 1, 22, 1, 1, 'Hola Mundo!', '192.168.01.01'