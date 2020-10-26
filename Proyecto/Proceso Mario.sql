--1. Usuarios nuevos y porcentaje de crecimiento

DROP TABLE #ReporteDeCrecimiento
GO
--Tabla temporal creada
CREATE TABLE
#ReporteDeCrecimiento (ID INT IDENTITY(1,1), fecha_creacion DATE, cantidad_usuarios INT, porcentaje INT)
GO

--Insertando fechas y cantidades (con 0% en todo de crecimiento)
INSERT INTO #ReporteDeCrecimiento
	(fecha_creacion, cantidad_usuarios, porcentaje)
SELECT U.fecha_creacion, 0, 0
FROM Bitacora B
		INNER JOIN USUARIO U ON (U.id_usuario = B.id_usuario)
GROUP BY U.fecha_creacion
ORDER BY U.fecha_creacion DESC--********************************************¿DESC o ASC?
GO

--Prueba
SELECT *
FROM #ReporteDeCrecimiento
GO

--Cursor para calcular el porcentaje en la tabla actual
DECLARE @fecha date, @cantUsr int, @totalUsrs int
SET @totalUsrs = 0;

DECLARE C_CrecimientoUsr CURSOR GLOBAL FOR
SELECT fecha_creacion
FROM #ReporteDeCrecimiento

OPEN C_CrecimientoUsr
FETCH C_CrecimientoUsr INTO @fecha
WHILE (@@FETCH_STATUS = 0)
BEGIN

	UPDATE #ReporteDeCrecimiento
	SET cantidad_usuarios = (	
								SELECT COUNT(Us.id_usuario) FROM USUARIO Us
								GROUP BY fecha_creacion
								HAVING @fecha = fecha_creacion 
							)
	WHERE @fecha = fecha_creacion 

	IF @totalUsrs = 0
	BEGIN
			UPDATE #ReporteDeCrecimiento
			SET porcentaje = 100
			WHERE @fecha = fecha_creacion 

			SET @totalUsrs = ( SELECT cantidad_usuarios FROM #ReporteDeCrecimiento WHERE @fecha = fecha_creacion )
	END
	ELSE
	BEGIN	
			SET @cantUsr = ( SELECT cantidad_usuarios FROM #ReporteDeCrecimiento WHERE @fecha = fecha_creacion )

			UPDATE #ReporteDeCrecimiento
			SET porcentaje = (@cantUsr*100)/@TotalUsrs
			WHERE @fecha = fecha_creacion 

			SET @totalUsrs = @totalUsrs + @cantUsr
	END
	FETCH NEXT FROM C_CrecimientoUsr into @fecha,  @cantUsr
END
CLOSE C_CrecimientoUsr
DEALLOCATE C_CrecimientoUsr
GO

SELECT *
FROM #ReporteDeCrecimiento
GO
--Elimina tabla temporal
DROP TABLE #ReporteDeCrecimiento
GO

--2. Publicaciones que impactaron el cambio de numero max de amigos
DECLARE @MeGusta int, @NoMeGusta int
SET @MeGusta = 0; SET @NoMeGusta = 0;
SELECT U.nombre1 AS [Nombre], U.Apellido1 AS [Apellido], P.fecha_hora AS [Fecha y hora de publicacion],
		P.contenido AS [Contenido de publicación], D.id_dispositivo AS [Dispositivo],
		TP.tipo AS [Tipo de publicacion], P.ip AS [IP de creacion]

FROM bitacora B
	INNER JOIN Publicacion P on (P.id_publicacion = B.id_publicacion)
	INNER JOIN Tipo_accion A ON (A.id_tipo_accion = B.id_tipo_accion)
	INNER JOIN Usuario U ON (U.id_usuario = P.id_usuario)
	INNER JOIN Tipo_publicacion TP ON (TP.id_tipo_publicacion = P.id_tipo_publicacion)
	INNER JOIN Dispositivo D ON (D.id_dispositivo = P.id_dispositivo)

GROUP BY A.accion, U.nombre1, U.Apellido1, P.fecha_hora, P.contenido, D.id_dispositivo, TP.tipo, P.ip
HAVING COUNT(CASE WHEN A.id_tipo_accion = 1 THEN 1 END) - COUNT(CASE WHEN A.id_tipo_accion = 2 THEN 1 END) - COUNT(CASE WHEN A.id_tipo_accion = 3 THEN 1 END)> 14 --tomando 1 como el id de la acción 'like'