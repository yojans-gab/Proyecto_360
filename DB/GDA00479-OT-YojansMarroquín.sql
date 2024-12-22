-- 1. Creación de la Base de Datos
CREATE DATABASE [GDA00479-OT-YojansMarroquín]

USE [GDA00479-OT-YojansMarroquín];

-- 2-4. Creación de Tablas, Campos y Creacion de relaciones
CREATE TABLE estados (
    idestados INT identity,
    nombre VARCHAR(15) NOT NULL,
	CONSTRAINT PK_Estados PRIMARY KEY(idestados)
);

CREATE TABLE rol (
    idrol INT identity,
    nombre VARCHAR(15) NOT NULL,
	CONSTRAINT PK_Rol PRIMARY KEY(idrol)
);

CREATE TABLE Clientes (
    idClientes INT identity,
    razon_social VARCHAR(245) NOT NULL,
    nombre_comercial VARCHAR(345),
    direccion_entrega VARCHAR(45),
    telefono VARCHAR(9),
    email VARCHAR(45),
	CONSTRAINT PK_Clientes PRIMARY KEY(idClientes)
);

CREATE TABLE usuarios (
    idusuarios INT identity,
    rol_idrol INT NOT NULL,
    estados_idestados INT NOT NULL,
    correo_electronico VARCHAR(45) NOT NULL,
    nombre_completo VARCHAR(45) NOT NULL,
    password VARCHAR(45) NOT NULL,
    telefono VARCHAR(9),
    fecha_nacimiento DATE,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    Clientes_idClientes INT,
	CONSTRAINT PK_Usuarios PRIMARY KEY(idusuarios),
    FOREIGN KEY (rol_idrol) REFERENCES rol(idrol),
    FOREIGN KEY (estados_idestados) REFERENCES estados(idestados),
    FOREIGN KEY (Clientes_idClientes) REFERENCES Clientes(idClientes)
);

CREATE TABLE CategoriaProductos (
    idCategoriaProductos INT identity,
    usuarios_idusuarios INT NOT NULL,
    estados_idestados INT NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT PK_Categoria PRIMARY KEY(idCategoriaProductos),
    FOREIGN KEY (usuarios_idusuarios) REFERENCES usuarios(idusuarios),
    FOREIGN KEY (estados_idestados) REFERENCES estados(idestados)
);

CREATE TABLE Productos (
    idProductos INT identity,
    CategoriaProductos_idCategoriaProductos INT NOT NULL,
    usuarios_idusuarios INT NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    marca VARCHAR(45),
    codigo VARCHAR(45),
    stock FLOAT,
    estados_idestados INT NOT NULL,
    precio FLOAT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    foto VARBINARY(MAX),
	CONSTRAINT PK_Productos PRIMARY KEY(idProductos),
    FOREIGN KEY (CategoriaProductos_idCategoriaProductos) REFERENCES CategoriaProductos(idCategoriaProductos),
    FOREIGN KEY (usuarios_idusuarios) REFERENCES usuarios(idusuarios),
    FOREIGN KEY (estados_idestados) REFERENCES estados(idestados)
);

CREATE TABLE Orden (
    idOrden INT identity,
    usuarios_idusuarios INT NOT NULL,
    estados_idestados INT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    nombre_completo VARCHAR(45),
    direccion VARCHAR(100),
    telefono VARCHAR(9),
    correo_electronico VARCHAR(45),
    fecha_entrega DATE,
    total_orden FLOAT,
	CONSTRAINT PK_Orden PRIMARY KEY(idOrden),
    FOREIGN KEY (usuarios_idusuarios) REFERENCES usuarios(idusuarios),
    FOREIGN KEY (estados_idestados) REFERENCES estados(idestados)
);

CREATE TABLE OrdenDetalles (
    idOrdenDetalles INT identity,
    Orden_idOrden INT NOT NULL,
    Productos_idProductos INT NOT NULL,
    cantidad INT NOT NULL,
    precio FLOAT NOT NULL,
    subtotal FLOAT NOT NULL,
	CONSTRAINT PK_OrdenDetalles PRIMARY KEY(idOrdenDetalles),
    FOREIGN KEY (Orden_idOrden) REFERENCES Orden(idOrden),
    FOREIGN KEY (Productos_idProductos) REFERENCES Productos(idProductos)
);

-- 5. Creacion de Procedimientos Almacenados
--INSERTAR:
----------------ESTADOS:
CREATE PROCEDURE p_InsertarEstados
    @nombre VARCHAR(15),
    @resultado NVARCHAR(50) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM estados WHERE nombre = @nombre)
    BEGIN
        SET @resultado = 'El estado ya existe.';
    END
    ELSE
    BEGIN
        INSERT INTO estados(nombre)
        VALUES(@nombre);
        SET @resultado = 'Estado insertado correctamente.';
    END
END;


----------------ROL:
CREATE PROCEDURE p_InsertarRol
	@nombre VARCHAR(15)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM rol WHERE nombre=@nombre)
	BEGIN
		PRINT 'El ROL ya existe'
	END
	ELSE
	BEGIN
		INSERT INTO rol(nombre)
		VALUES(@nombre);
		PRINT 'ROL insertado correctamente.';
	END
END;
----------------CLIENTES:
CREATE PROCEDURE p_InsertarClientes
    @razon_social VARCHAR(245),
    @nombre_comercial VARCHAR(345),
    @direccion_entrega VARCHAR(45),
    @telefono VARCHAR(9),
    @email VARCHAR(45)
AS
BEGIN
    DECLARE @mensaje NVARCHAR(50);

    IF EXISTS (SELECT 1 FROM Clientes WHERE email = @email)
    BEGIN
        SET @mensaje = 'El correo electrónico ya ha sido registrado';
    END
    ELSE IF @email LIKE '%_@__%.__%'
    BEGIN
        INSERT INTO Clientes (razon_social, nombre_comercial, direccion_entrega, telefono, email)
        VALUES (@razon_social, @nombre_comercial, @direccion_entrega, @telefono, @email);
        
        SET @mensaje = 'Cliente insertado correctamente';
    END
    ELSE
    BEGIN
        SET @mensaje = 'El formato del correo electrónico no es válido';
    END

    SELECT @mensaje AS mensaje;
END;


----------------USUARIOS:

CREATE OR ALTER PROCEDURE p_InsertarUsuarios
    @rol_idrol INT,
    @estados_idestados INT,
    @correo_electronico VARCHAR(45),
    @nombre_completo VARCHAR(45),
    @password VARCHAR(45),
    @telefono VARCHAR(9) = NULL,
    @fecha_nacimiento DATE = NULL,
    @Clientes_idClientes INT = NULL,
    @mensaje NVARCHAR(50) OUTPUT,
    @usuario_id INT OUTPUT -- Add an OUTPUT parameter for the new user ID
AS
BEGIN
    -- Initialize @usuario_id to NULL in case no insertion occurs
    SET @usuario_id = NULL;

    IF EXISTS (SELECT 1 FROM usuarios WHERE correo_electronico = @correo_electronico)
    BEGIN
        SET @mensaje = 'El correo electrónico ya ha sido registrado';
    END
    ELSE IF @correo_electronico LIKE '%@%._%'
    BEGIN
        INSERT INTO usuarios (
            rol_idrol, estados_idestados, correo_electronico, 
            nombre_completo, password, telefono, 
            fecha_nacimiento, Clientes_idClientes
        )
        VALUES (
            @rol_idrol, @estados_idestados, @correo_electronico, 
            @nombre_completo, @password, @telefono, 
            @fecha_nacimiento, @Clientes_idClientes
        );

        -- Get the ID of the newly inserted user
        SET @usuario_id = SCOPE_IDENTITY();
        SET @mensaje = 'Usuario insertado correctamente';
    END
    ELSE
    BEGIN
        SET @mensaje = 'El formato del correo electrónico no es válido';
    END

    -- Return the message and the user ID
    SELECT @mensaje AS mensaje, @usuario_id AS usuario_id;
END;

----------------CATEGORIA PRODUCTO:
CREATE OR ALTER PROCEDURE p_InsertarCategoriaProd
    @usuarios_idusuarios INT,
    @estados_idestados INT,
    @nombre VARCHAR(45),
    @mensaje NVARCHAR(100) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM CategoriaProductos WHERE nombre = @nombre)
    BEGIN
        SET @mensaje = 'La categoría ya está registrada.';
    END
    ELSE
    BEGIN
        INSERT INTO CategoriaProductos (usuarios_idusuarios, estados_idestados, nombre)
        VALUES (@usuarios_idusuarios, @estados_idestados, @nombre);
        
        SET @mensaje = 'Categoría insertada correctamente.';
    END
    SELECT @mensaje AS mensaje;
END;


----------------PRODUCTO:
CREATE OR ALTER PROCEDURE p_InsertarProducto
    @CategoriaProductos_idCategoriaProductos INT,
    @usuarios_idusuarios INT,
    @nombre VARCHAR(45),
    @marca VARCHAR(45),
    @codigo VARCHAR(45),
    @stock FLOAT,
    @estados_idestados INT,
    @precio FLOAT,
    @foto VARBINARY(MAX),
    @mensaje NVARCHAR(100) OUTPUT
AS
BEGIN
    IF @foto IS NOT NULL
    BEGIN
        INSERT INTO Productos (
            CategoriaProductos_idCategoriaProductos, usuarios_idusuarios, 
            nombre, marca, codigo, stock, estados_idestados, precio, foto
        )
        VALUES (
            @CategoriaProductos_idCategoriaProductos, @usuarios_idusuarios, 
            @nombre, @marca, @codigo, @stock, @estados_idestados, @precio, @foto
        );
        
        SET @mensaje = 'Producto insertado correctamente';
    END
    ELSE
    BEGIN
        SET @mensaje = 'La imagen no puede estar vacía';
    END
    SELECT @mensaje AS mensaje;
END;


----------------ORDEN:
CREATE OR ALTER PROCEDURE CrearOrdenConDetalles
	@usuarios_idusuarios INT,
	@detalles NVARCHAR(MAX)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		DECLARE @idOrden INT;
		DECLARE @mensaje NVARCHAR(50);

		-- Inserta la orden
		INSERT INTO Orden (
			usuarios_idusuarios,
			estados_idestados,
			nombre_completo,
			direccion,
			telefono,
			correo_electronico
		)
		SELECT TOP 1
			u.idusuarios,
			(
				SELECT idestados
				FROM estados
				WHERE nombre = 'Confirmado'
			),
			u.nombre_completo, 
			c.direccion_entrega,
			u.telefono,
			u.correo_electronico
		FROM usuarios AS u
		JOIN Clientes AS c ON u.Clientes_idClientes = c.idClientes
		WHERE u.idusuarios = @usuarios_idusuarios;

		-- Obtiene el ID de la orden creada
		SET @idOrden = SCOPE_IDENTITY();
		
		-- Inserta los detalles de la orden
		INSERT INTO OrdenDetalles (
			Orden_idOrden,
			Productos_idProductos,
			cantidad,
			precio,
			subtotal
		)
		SELECT 
			@idOrden,
			JSON_VALUE(value, '$.Productos_idProductos'),
			JSON_VALUE(value, '$.cantidad'),
			JSON_VALUE(value, '$.precio'),
			JSON_VALUE(value, '$.subtotal')
		FROM OPENJSON(@detalles);

		-- Actualiza el total de la orden
		UPDATE Orden
		SET total_orden = (
			SELECT SUM(subtotal)
			FROM OrdenDetalles
			WHERE Orden_idOrden = @idOrden
		)
		WHERE idOrden = @idOrden;

		-- Mensaje de éxito
		SET @mensaje = 'Orden creada correctamente';
		SELECT @mensaje AS mensaje;

		COMMIT;
	END TRY 
	BEGIN CATCH 
		ROLLBACK;
		THROW;
	END CATCH
END;




--ACTUALIZAR:
----------------ESTADOS:
CREATE PROCEDURE p_ActualizarEstado
	@idestados INT,
	@nombre VARCHAR(15),
	@mensaje NVARCHAR(50) OUTPUT
AS
BEGIN
    IF EXISTS(SELECT * FROM estados WHERE idestados = @idestados)
    BEGIN
        UPDATE estados 
        SET nombre = @nombre 
        WHERE idestados = @idestados;
        SET @mensaje = 'Estado actualizado correctamente';
    END
    ELSE
    BEGIN
        SET @mensaje = 'El cliente no existe';
    END
END;


----------------ROL:
CREATE PROCEDURE p_ActualizarRol
    @idrol INT,
    @nombre VARCHAR(15)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM rol WHERE idrol = @idrol)
    BEGIN
        UPDATE rol
        SET nombre = @nombre
        WHERE idrol = @idrol;

        PRINT 'ROL actualizado correctamente';
    END
    ELSE
    BEGIN
        PRINT 'El ROL no existe';
    END
END;



----------------CLIENTES:
CREATE OR ALTER PROCEDURE p_ActualizarClientes
    @idClientes INT,
    @razon_social VARCHAR(245),
    @nombre_comercial VARCHAR(345),
    @direccion_entrega VARCHAR(45),
    @telefono VARCHAR(9),
    @email VARCHAR(45)  -- Cambiado de @correo_electronico a @email
AS
BEGIN
    DECLARE @mensaje NVARCHAR(50);

    IF @email LIKE '%_@__%.__%'
    BEGIN
        IF EXISTS (SELECT 1 FROM Clientes WHERE idClientes = @idClientes)
        BEGIN
            UPDATE Clientes
            SET 
                razon_social = @razon_social, 
                nombre_comercial = @nombre_comercial, 
                direccion_entrega = @direccion_entrega, 
                telefono = @telefono, 
                email = @email
            WHERE idClientes = @idClientes;

            SET @mensaje = 'Cliente actualizado correctamente';
        END
        ELSE
        BEGIN
            SET @mensaje = 'El cliente no existe';
        END
    END
    ELSE
    BEGIN
        SET @mensaje = 'El formato del correo electrónico no es válido';
    END

    SELECT @mensaje AS mensaje;
END;



----------------USUARIOS:
CREATE or ALTER PROCEDURE p_ActualizarUsuario
	@idusuarios INT,
    @rol_idrol INT,
	@estados_idestados INT,
	@correo_electronico VARCHAR(45),
	@nombre_completo VARCHAR(45),
	@password VARCHAR(45),
	@telefono VARCHAR(9) = NULL,
	@fecha_nacimiento DATE = NULL,
	@Clientes_idClientes INT = NULL,
	@mensaje NVARCHAR(50) OUTPUT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM usuarios WHERE idusuarios = @idusuarios)
	BEGIN
		UPDATE usuarios
		SET 
			rol_idrol = @rol_idrol, 
			estados_idestados = @estados_idestados,
			correo_electronico = @correo_electronico,
			nombre_completo = @nombre_completo,
			password = @password,
			telefono = @telefono,
			fecha_nacimiento = @fecha_nacimiento,
			Clientes_idClientes = @Clientes_idClientes
		WHERE idusuarios = @idusuarios;

		SET @mensaje = 'Usuario actualizado correctamente';
	END
	ELSE
	BEGIN
		SET @mensaje = 'El Usuario no existe';
	END
	SELECT @mensaje AS mensaje;
END;



----------------CATEGORIA:
CREATE or ALTER PROCEDURE p_ActualizarCategoria
	@idCategoriaProductos INT,
	@usuarios_idusuarios INT,
    @estados_idestados INT,
    @nombre VARCHAR(45),
	@mensaje NVARCHAR(50) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM CategoriaProductos WHERE idCategoriaProductos = @idCategoriaProductos)
    BEGIN
        UPDATE CategoriaProductos
        SET usuarios_idusuarios = @usuarios_idusuarios, 
			estados_idestados = @estados_idestados,
			nombre = @nombre
        WHERE idCategoriaProductos = @idCategoriaProductos;

        SET @mensaje = 'Categoria actualizado correctamente';
    END
    ELSE
    BEGIN
        SET @mensaje = 'La Categoria no existe';
    END
	SELECT @mensaje AS mensaje;
END;



----------------PRODUCTOS:
CREATE PROCEDURE p_ActualizarProducto
	@idProductos INT,
	@CategoriaProductos_idCategoriaProductos INT,
    @usuarios_idusuarios INT,
    @nombre VARCHAR(45),
    @marca VARCHAR(45),
    @codigo VARCHAR(45),
    @stock FLOAT,
    @estados_idestados INT,
    @precio FLOAT,
    @foto VARBINARY(MAX)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Productos WHERE idProductos = @idProductos)
    BEGIN
        UPDATE Productos
        SET CategoriaProductos_idCategoriaProductos = @CategoriaProductos_idCategoriaProductos, 
			usuarios_idusuarios = @usuarios_idusuarios,
			nombre = @nombre,
			marca = @marca,
			codigo = @codigo,
			stock = @stock,
			estados_idestados = @estados_idestados,
			precio = @precio,
			foto = @foto
        WHERE idProductos = @idProductos;

        PRINT 'Producto actualizado correctamente';
    END
    ELSE
    BEGIN
        PRINT 'El Producto no existe';
    END
END;


----------------ORDEN:
CREATE OR ALTER PROCEDURE ActualizarOrden 
	@idOrden INT,
	@usuarios_idusuarios INT,
	@detalles NVARCHAR(MAX)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		-- Actualiza la información de la orden
		UPDATE Orden
		SET usuarios_idusuarios = @usuarios_idusuarios
		WHERE idOrden = @idOrden;

		-- Elimina los detalles anteriores
		DELETE FROM OrdenDetalles
		WHERE Orden_idOrden = @idOrden;

		-- Inserta nuevos detalles
		INSERT INTO OrdenDetalles (
			Orden_idOrden,
			Productos_idProductos,
			cantidad,
			precio,
			subtotal
		)
		SELECT 
			@idOrden,
			Productos_idProductos,
			cantidad,
			precio,
			subtotal
		FROM OPENJSON(@detalles)
		WITH (
			Productos_idProductos INT,
			cantidad INT,
			precio FLOAT,
			subtotal FLOAT
		);

		-- Recalcula el total de la orden
		UPDATE Orden
		SET total_orden = (
			SELECT SUM(subtotal)
			FROM OrdenDetalles
			WHERE Orden_idOrden = @idOrden
		)
		WHERE idOrden = @idOrden;

		-- Devuelve la orden actualizada
		SELECT * FROM viewOrden WHERE idOrden = @idOrden;

		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END;
-------------CAMBIAR ESTADO DE PRODUCTOS
CREATE PROCEDURE p_InactivarProducto
	@idProductos INT,
    @estados_idestados INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Productos WHERE idProductos = @idProductos)
    BEGIN
        UPDATE Productos
        SET estados_idestados = @estados_idestados
        WHERE idProductos = @idProductos;

        PRINT 'Estado del producto actualizado correctamente';
    END
    ELSE
    BEGIN
        PRINT 'El Producto no existe';
    END
END;


----------------------------------------------------
-- 6. Creacion de vistas
-----------------------------VISTAS:-------------
--- a)
CREATE VIEW TotalProductosActivos AS
SELECT COUNT(*) AS TotalProductos
FROM Productos
WHERE estados_idestados = 1 AND stock > 0;

--Ejecutar View:
SELECT * FROM TotalProductosActivos;


--- b)
CREATE VIEW TotalQuetzalesAgosto2024 AS
SELECT SUM(total_orden) AS TotalQuetzales
FROM Orden
WHERE MONTH(fecha_creacion) = 8 AND YEAR(fecha_creacion) = 2024;

--Ejecutar View:
SELECT * FROM TotalQuetzalesAgosto2024;


--- c)
CREATE VIEW Top10ClientesConsumo AS
SELECT TOP 10 
    C.idClientes, 
    C.nombre_comercial, 
    SUM(O.total_orden) AS TotalConsumo
FROM Clientes C
JOIN usuarios U ON C.idClientes = U.Clientes_idClientes
JOIN Orden O ON U.idusuarios = O.usuarios_idusuarios
GROUP BY C.idClientes, C.nombre_comercial
ORDER BY TotalConsumo DESC;

--Ejecutar View:
SELECT * FROM Top10ClientesConsumo;


--- d)
CREATE VIEW Top10ProductosVendidos AS
SELECT TOP 10 
    P.idProductos, 
    P.nombre, 
    SUM(OD.cantidad) AS TotalVendidos
FROM Productos P
JOIN OrdenDetalles OD ON P.idProductos = OD.Productos_idProductos
GROUP BY P.idProductos, P.nombre
ORDER BY TotalVendidos DESC;

--Ejecutar View:
SELECT * FROM Top10ProductosVendidos;

