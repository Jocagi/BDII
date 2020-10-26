 /* 
 Interacción (15pts) 
 El proceso tendrá la capacidad de recibir una interacción para una publicación en específico. 
 Solicitando la información respectiva según las reglas descritas. 
	▪ Nivel de aislamiento 
 */

 Insert Into TIPO_ACCION (ACCION) Values ('Like')
 Insert Into TIPO_ACCION (ACCION) Values ('Dislike')
 Insert Into TIPO_ACCION (ACCION) Values ('Removed-Like')
 Insert Into TIPO_ACCION (ACCION) Values ('Removed-Dislike')
 Insert Into TIPO_ACCION (ACCION) Values ('Comment')
 Insert Into TIPO_ACCION (ACCION) Values ('Removed-Comment')

 Select * from TIPO_ACCION

 Insert Into TIPO_PUBLICACION( TIPO ) Values ('Post')
 Insert Into TIPO_PUBLICACION( TIPO ) Values ('Imagen')
 Insert Into TIPO_PUBLICACION( TIPO ) Values ('Noticia')

 Select * from TIPO_PUBLICACION

 Insert Into DISPOSITIVO (NOMBRE) Values ('Telefono')

 Select * from DISPOSITIVO

 Insert into USUARIO
				(CORREO, NOMBRE1, NOMBRE2, APELLIDO1, APELLIDO2, FECHA_DE_NACIMIENT, CONTRASENA, CANT_MAX_AMIGOS, FECHA_CREACION)
				Values
				('josegiron1607@gmail.com', 'Jose', 'Carlos', 'Giron', 'Marquez', '2000-07-16', '123', 50, GetDate());
 
 Insert into USUARIO
				(CORREO, NOMBRE1, APELLIDO1, FECHA_DE_NACIMIENT, CONTRASENA, CANT_MAX_AMIGOS, FECHA_CREACION)
				Values
				('fhjdkj@gmail.com', 'Andrea', 'Camara', '2000-01-01', '123', 50, GetDate());
 

 Select * from USUARIO

 Select * from TIPO_PUBLICACION

 Insert Into PUBLICACION (ID_DISPOSITIVO, ID_TIPO_PUBLICACION, ID_USUARIO, FECHA_HORA, CONTENIDO, IP)
 Values (1, 2, 20, GETDATE(), 'URL IMAGEN', '192.168.1.1')

 Select * from PUBLICACION

 Insert Into BITACORA (ID_PUBLICACION, ID_USUARIO, ID_TIPO_ACCION, FECHA_HORA)
 Values (2, 21, 2, GETDATE())

 
Create or Alter Procedure uspIngresarInteraccion
@ID_Publicacion integer,
@ID_Usuario integer,
@ID_Accion integer -- Se asume 1 para Like y 2 para Dislike
As
Begin

	Set transaction isolation level serializable;
	Begin transaction

	Declare @CantLikeGeneral integer;
	Declare @CantDislikeGeneral integer;

	Declare @CantLikeUsuario integer;
	Declare @CantDislikeUsuario integer;

	-- Contar likes y dislikes totales, tomando en cuenta solo los validos.
	-- Cuando una accion se deshace, se resta del total respectivo
	Select
	@CantLikeGeneral =
	COALESCE(SUM(case    when ID_TIPO_ACCION = 1 then 1
				when ID_TIPO_ACCION = 3 then -1
				else 0 end),0),
	@CantDislikeGeneral =
	COALESCE(SUM(case    when ID_TIPO_ACCION = 2 then 1
				when ID_TIPO_ACCION = 4 then -1
				else 0 end),0),
	@CantLikeUsuario =
	COALESCE(SUM(case    when ID_TIPO_ACCION = 1 AND ID_USUARIO = @ID_Usuario then 1
				when ID_TIPO_ACCION = 3 AND ID_USUARIO = @ID_Usuario then -1
				else 0 end),0),
	@CantDislikeUsuario =
	COALESCE(SUM(case    when ID_TIPO_ACCION = 2 AND ID_USUARIO = @ID_Usuario then 1
				when ID_TIPO_ACCION = 4 AND ID_USUARIO = @ID_Usuario then -1
				else 0 end),0)
	from BITACORA
	Where ID_PUBLICACION = @ID_Publicacion

	
	IF EXISTS (	Select P.ID_USUARIO, A.ID_AMIGO from PUBLICACION P
				Inner Join AMIGO A on P.ID_USUARIO = A.ID_USUARIO
				Where ID_PUBLICACION = @ID_Publicacion AND (A.ID_AMIGO = @ID_Usuario OR P.ID_USUARIO = @ID_Usuario) )
	Begin

		-- Remover Like
		If (@ID_Accion = 3)
			Begin
				If (@CantLikeUsuario > 0)
					Begin
						Insert Into BITACORA (ID_PUBLICACION, ID_USUARIO, ID_TIPO_ACCION, FECHA_HORA)
						Values (@ID_Publicacion, @ID_Usuario, 3, GETDATE());
						commit;
					End
				Else
					Begin
						Print('No existen likes para remover');
						rollback;
					End
			End
		-- Remover Dislike
		Else If (@ID_Accion = 4)
			Begin
				If (@CantDislikeUsuario > 0)
					Begin
						Insert Into BITACORA (ID_PUBLICACION, ID_USUARIO, ID_TIPO_ACCION, FECHA_HORA)
						Values (@ID_Publicacion, @ID_Usuario, 4, GETDATE());
						commit;
					End
				Else
					Begin
						Print('No existen dislikes para remover');
						rollback;
					End
			End
		-- Insertar Like o Dislike
		Else If (@ID_Accion = 1 OR @ID_Accion = 2)
			Begin
				If (@ID_Accion = 1 OR (@ID_Accion = 2 AND @CantLikeGeneral > @CantDislikeGeneral))
					Begin
						If (@CantLikeUsuario = 0 AND @CantDislikeUsuario = 0)
							Begin
									Insert Into BITACORA (ID_PUBLICACION, ID_USUARIO, ID_TIPO_ACCION, FECHA_HORA)
									Values (@ID_Publicacion, @ID_Usuario, @ID_Accion, GETDATE());
									commit;
							End
						Else
							Begin
								Print('El usuario ya ha interactuado con la publicacion');
								rollback;
							End
					End
				Else
					Begin
						Print('No existen suficientes likes para insertar un nuevo dislike');
						rollback;
					End
			End
		Else
			Begin
				Print('Interaccion no reconocida');
				rollback;
			End
		End
	Else
		Begin
			Print('El usuario no se encuentra en la lista de amigos');
			rollback;
		End
End

--Pruebas

exec uspIngresarInteraccion 3, 22, 3

Select * from BITACORA
Where ID_PUBLICACION = 3

Select * from PUBLICACION

Select * from USUARIO

Select * from AMIGO

Insert into AMIGO (ID_USUARIO, ID_AMIGO) Values (20, 21)
Insert into AMIGO (ID_USUARIO, ID_AMIGO) Values (21, 20)


Select P.ID_USUARIO, A.ID_AMIGO 
from PUBLICACION P
Inner Join AMIGO A 
	on P.ID_USUARIO = A.ID_USUARIO
	Where ID_PUBLICACION = 1

IF EXISTS (Select P.ID_USUARIO, A.ID_AMIGO 
from PUBLICACION P
Inner Join AMIGO A 
	on P.ID_USUARIO = A.ID_USUARIO
	Where ID_PUBLICACION = 1
	AND ID_AMIGO = 20)
	Begin
		Print('Si existe el amigo')
	End
Else 
	Begin
		Print('No existe el amigo')
	End