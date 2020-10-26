--Ingreso Usuarios (15 pts)
--Crear un proceso para poder agregar N usuarios, con su información
--respectiva, realizando las validaciones correspondientes, y tomando en
--cuenta que si se encuentran usuarios con los mismos apellidos
--automáticamente se relacionan y entran dentro de los 50 amigos que tienen
--permitido asociar.
--▪ Proceso para carga de archivo automático.
--▪ SubProceso para procesar cada línea del archivo.
alter TRIGGER ModificandoAmigo ON dbo.USUARIO for INSERT 
AS
--SET IDENTITY_INSERT dbo.AMIGO ON
INSERT INTO dbo.AMIGO
(
	ID_USUARIO,
	ID_AMIGO
)
SELECT i.ID_USUARIO, u.ID_USUARIO
from INSERTED i , dbo.USUARIO u
WHERE (Upper(trim(i.APELLIDO1)) = Upper(trim(u.APELLIDO1)) OR Upper(trim(i.APELLIDO2 ))= Upper(trim(u.APELLIDO2))) AND i.ID_USUARIO != u.ID_USUARIO
--SET IDENTITY_INSERT dbo.AMIGO OFF

--Procedimiento que ingresa los N usuarios + subproceso para para procesar cada linea del archivo 
CREATE PROCEDURE IngresandoUsuarios
AS
BEGIN
	BULK INSERT Bookface..USUARIO FROM 'C:\Users\usuario\Desktop\bases.csv'
	WITH 
	(
	DATAFILETYPE = 'CHAR', 
	FIELDTERMINATOR=';', 
	ROWTERMINATOR='\n',
	FIRE_TRIGGERS
	)
END 


EXEC IngresandoUsuarios


--Publicación (15 pts)
--Generación aleatoria de N publicaciones para M usuarios
--▪ Nivel de aislamiento
alter PROCEDURE  dbo.uspGenerarPublicaciones 
@cantPub integer,
@cantU integer
AS
DECLARE @numU int--cantidad total de usuarios existentes
DECLARE @cont int = 0;
DECLARE @idusr int 
DECLARE @rndDispo int 
DECLARE @rndtipo int 
DECLARE @rndip nvarchar(15)
DECLARE @minId int
DECLARE @maxId int
DECLARE @Fecha datetime 

BEGIN
	set transaction isolation level read committed;

	SELECT @numU = (SELECT count(1) FROM dbo.USUARIO u)
	SELECT @minId = (SELECT MIN(u.ID_USUARIO) FROM dbo.USUARIO u)
	SELECT @maxId = (SELECT MAX(u.ID_USUARIO) FROM dbo.USUARIO u)


	IF(@cantU > @numU)
	BEGIN
		ROLLBACK 
		PRINT 'No hay esa cantidad de usuarios'
	END 
	ELSE

		WHILE @cont < @cantPub
		BEGIN 
			SET @idusr = floor(RAND()*(@maxId - @minId)+ @minId); --random de asignacion de usuario
			SET @rndDispo = floor(RAND()*((3+1)-1)+1) --random para ingreso de dispositivo 
			SET @rndtipo = floor(RAND()*((3+1)-1)+1)--random para insertar el tipo de publicacion
			SET @Fecha = convert(datetime,'01-01-1980',0) + (365 * 41 * RAND() - 365) --fecha aleatoria de 1979 a 2020
			SET @rndip = cast(floor(RAND()*((253+1)-1)+1) AS varchar(3))+'.'+cast(floor(RAND()*((253+1)-1)+1)AS varchar(3))+'.' --IP aleatoria
			+cast(floor(RAND()*((253+1)-1)+1)AS varchar(3))+'.'+cast(floor(RAND()*((253+1)-1)+1)AS varchar(3))
			INSERT INTO dbo.PUBLICACION
			(
				--ID_PUBLICACION - column value is auto-generated
				ID_DISPOSITIVO,
				ID_TIPO_PUBLICACION,
				ID_USUARIO,
				FECHA_HORA,
				CONTENIDO, --aca no hay problema que no sea coherente con los datos que deberían ir 
				IP
			)
				SELECT @rndDispo,@rndtipo,@idusr,@Fecha,'publicacion aleatoria No.'+cast(@cont as varchar(5)),@rndip 

			SET @cont = @cont + 1;
		END 
END 

EXEC uspGenerarPublicaciones 2,2 --prueba


SELECT * FROM PUBLICACION


--Número de publicaciones al mes, con el 100% de su capacidad de comentarios llena (INFORME)

SELECT COUNT(1) cantPublicacion 
FROM dbo.PUBLICACION p  
WHERE MONTH(p.FECHA_HORA) = MONTH(GETDATE()) AND 
(SELECT count(1) FROM COMENTARIO c WHERE c.ID_PUBLICACION_REF = p.ID_PUBLICACION) = 3
