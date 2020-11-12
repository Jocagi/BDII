/*==============================================================*/
/* DISEÑO                                                       */
/*==============================================================*/

/* Base de datos */
create database PARCIALII_1064718
go
use PARCIALII_1064718
go

/* Tabla: CLIENTE */
create table CLIENTE (
   NOMBRE           nvarchar(50)         not null,
   APELLIDO         nvarchar(50)         not null,
   DPI              int                  not null
   constraint PK_CLIENTE primary key (DPI)
)
go

/* Tabla: TELEFONO */
create table TELEFONO (
   FECHA              datetime             not null,
   TELEFONO           nvarchar(50)         not null,
   DPI_CLIENTE        int                  not null,
   ID				  int identity(1,1)    not null,
   constraint PK_TELEFONO primary key (FECHA, TELEFONO)
)
go

DROP TABLE EVENTO

/* Tabla: EVENTO */
create table EVENTO (
   FECHA              date                 not null,
   HORA               varchar(6)           not null,
   ORIGEN             nvarchar(50)         not null,
   DESTINO            nvarchar(50)         not null,
   TIPO               int                  not null,
   DURACION           int                  not null,
   ESTADO             int                  not null,
   ID				  int identity(1,1)    not null,
   constraint PK_EVENTO primary key (ID)
)
go

alter table TELEFONO
   add constraint FK_CLIENTE_TELEFONO foreign key (DPI_CLIENTE)
      references CLIENTE (DPI)
go

alter table EVENTO
   add constraint FK_EVENTO_TELEFONO foreign key (ORIGEN)
      references TELEFONO (TELEFONO)
go

/*==============================================================*/
/* PROCEDIMIENTO                                                */
/*==============================================================*/

Delete from EVENTO
Select * from EVENTO

CREATE or alter PROCEDURE uspIngresarEventos
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	BEGIN TRANSACTION
		BEGIN TRY
			Declare @rowsTotal int;
			Declare @rowsAffected int;

			-- Tabla temporal
			create table #EVENTO (
			   FECHA              date                 not null,
			   HORA               varchar(6)           not null,
			   ORIGEN             nvarchar(50)         not null,
			   DESTINO            nvarchar(50)         not null,
			   TIPO               int                  not null,
			   DURACION           int                  not null,
			   ESTADO             int                  not null
			)
			-- Insertar elementos
			BULK INSERT #EVENTO 
				FROM 'C:\Users\user\Desktop\data.csv'
				WITH ( FORMAT = 'CSV' , ROWS_PER_BATCH = 100, FIRE_TRIGGERS, MAXERRORS = 100)
			-- No insertar repetidos
			INSERT INTO EVENTO
			  (FECHA,HORA,ORIGEN,DESTINO,TIPO,DURACION,ESTADO)
				SELECT DISTINCT FECHA,HORA,ORIGEN,DESTINO,TIPO,DURACION,ESTADO
				FROM #EVENTO AS s
				WHERE NOT EXISTS (
				  SELECT *
				  FROM EVENTO As t
				);
				
				Select @rowsTotal = Count(1) 
				from #EVENTO;

				SELECT DISTINCT @rowsAffected = COUNT(1)
				FROM #EVENTO AS s
				WHERE NOT EXISTS (
				  SELECT *
				  FROM EVENTO As t
				);

			IF (@rowsAffected <> @rowsTotal)
				Print('Error: Se han econtrado elementos repetidos')
				
			DROP TABLE #EVENTO
			COMMIT TRANSACTION
		END TRY
	BEGIN CATCH
		Print('Error formato incorrecto')
		ROLLBACK TRANSACTION
	END CATCH
END

exec uspIngresarEventos