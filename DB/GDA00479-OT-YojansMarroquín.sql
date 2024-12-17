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
	@nombre VARCHAR(15)
AS
	BEGIN
	IF EXISTS(SELECT 1 FROM estados WHERE nombre=@nombre)
	BEGIN 
		PRINT 'El estado ya existe.';
	END
	ELSE
	BEGIN
		INSERT INTO estados(nombre)
		VALUES(@nombre);
		PRINT 'Estado insertado correctamente.';
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
	IF EXISTS (SELECT 1 FROM Clientes WHERE email=@email)
	BEGIN
		PRINT 'El correro electronico ya ha sido registrado'
	END
	ELSE
	BEGIN
		IF @email LIKE '%_@__%.__%'
		BEGIN
			INSERT INTO Clientes(razon_social, nombre_comercial, direccion_entrega, telefono, email)
			VALUES(@razon_social, @nombre_comercial, @direccion_entrega, @telefono, @email);
			PRINT 'Producto insertado correctamente'
		END
		ELSE
        BEGIN
            PRINT 'El formato del correo electrónico no es válido';
        END
	END
END;
----------------USUARIOS:
CREATE PROCEDURE p_InsertarUsuarios
	@rol_idrol INT,
	@estados_idestados INT,
	@correo_electronico VARCHAR(45),
	@nombre_completo VARCHAR(45),
	@password VARCHAR(45),
	@telefono VARCHAR(9) = NULL,
	@fecha_nacimiento DATE = NULL,
	@Clientes_idClientes INT = NULL
AS
BEGIN
	IF EXISTS (SELECT 1 FROM usuarios WHERE correo_electronico = @correo_electronico)
	BEGIN
		PRINT 'El correo electrónico ya ha sido registrado';
	END
	ELSE
	BEGIN
		IF @correo_electronico LIKE '%_@__%.__%'
		BEGIN
			INSERT INTO usuarios (
				rol_idrol,
				estados_idestados,
				correo_electronico,
				nombre_completo,
				password,
				telefono,
				fecha_nacimiento,
				Clientes_idClientes
			)
			VALUES (
				@rol_idrol,
				@estados_idestados,
				@correo_electronico,
				@nombre_completo,
				@password,
				@telefono,
				@fecha_nacimiento,
				@Clientes_idClientes
			);
			PRINT 'Usuario insertado correctamente';
		END
		ELSE
		BEGIN
			PRINT 'El formato del correo electrónico no es válido';
		END
	END
END;
----------------CATEGORIA PRODUCTO:
CREATE PROCEDURE p_InsertarCategoriaProd
    @usuarios_idusuarios INT,
    @estados_idestados INT,
    @nombre VARCHAR(45)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM CategoriaProductos WHERE nombre = @nombre)
    BEGIN
        PRINT 'La categoría ya está registrada.';
    END
    ELSE
    BEGIN
        INSERT INTO CategoriaProductos (usuarios_idusuarios, estados_idestados, nombre)
        VALUES (@usuarios_idusuarios, @estados_idestados, @nombre);

        PRINT 'Categoría insertada correctamente.';
    END
END;

----------------PRODUCTO:
CREATE PROCEDURE p_InsertarProducto
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

        PRINT 'Producto insertado correctamente';
    END
    ELSE
    BEGIN
        PRINT 'La imagen no puede estar vacía';
    END
END;

----------------ORDEN:
CREATE PROCEDURE p_InsertarOrden
	@usuarios_idusuarios INT,
	@estados_idestados INT,
	@nombre_completo VARCHAR(45),
	@direccion VARCHAR(100),
	@telefono VARCHAR(9),
	@correo_electronico VARCHAR(45),
	@fecha_entrega DATE,
	@total_orden FLOAT
AS
BEGIN
	INSERT INTO Orden(usuarios_idusuarios, estados_idestados, nombre_completo, direccion,
						telefono, correo_electronico, fecha_entrega, total_orden)
	VALUES(@usuarios_idusuarios, @estados_idestados, @nombre_completo,
			@direccion,@telefono, @correo_electronico,
			@fecha_entrega, @total_orden);
	PRINT 'Orden insertada correctamente'
END;

----------------ORDEN DETALLE:
CREATE PROCEDURE p_InsertarOrdenDetalles
	@Orden_idOrden INT,
	@Productos_idProductos INT,
	@cantidad INT, 
	@precio FLOAT,
	@subtotal FLOAT
AS
BEGIN
	INSERT INTO OrdenDetalles(Orden_idOrden, Productos_idProductos, cantidad, precio, subtotal)
	VALUES(@Orden_idOrden, @Productos_idProductos, @cantidad, @precio, @subtotal);
	PRINT 'Registro insertado correctamente'
END;

------------------------------REGISTROS DE PRUEBA-------------------

----------------ESTADOS:
EXEC p_InsertarEstados
@nombre = 'Activo';

EXEC p_InsertarEstados
@nombre = 'Inactivo';
----------------ROL:
EXEC p_InsertarRol
@nombre = 'Cliente';

EXEC p_InsertarRol
@nombre = 'Operador';

----------------CLIENTES:
EXEC p_InsertarClientes
	@razon_social = 'Comercial El Sol',
	@nombre_comercial = 'El Sol S.A.',
	@direccion_entrega = 'Zona 10, Ciudad de Guatemala' ,
	@telefono = '1234-5678' ,
	@email = 'contacto@elsol.com' ;

EXEC p_InsertarClientes
	@razon_social = 'Distribuidora La Luna',
	@nombre_comercial = 'La Luna S.A.',
	@direccion_entrega = 'Zona 5, Ciudad de Guatemala',
	@telefono = '8765-4321',
	@email = 'contacto@laluna.com';

EXEC p_InsertarClientes
	@razon_social = 'Ferretería El Martillo',
	@nombre_comercial = 'El Martillo S.A.',
	@direccion_entrega = 'Zona 8, Ciudad de Guatemala',
	@telefono = '1111-2222',
	@email = 'contacto@elmartillo.com';

EXEC p_InsertarClientes
	@razon_social = 'Tecnología Avanzada',
	@nombre_comercial = 'TechAdv S.A.',
	@direccion_entrega = 'Zona 4, Mixco',
	@telefono = '3333-4444',
	@email = 'ventas@techadv.com';

EXEC p_InsertarClientes
	@razon_social = 'Tienda Las Flores',
	@nombre_comercial = 'Flores y Más S.A.',
	@direccion_entrega = 'Zona 2, Antigua Guatemala',
	@telefono = '5555-6666',
	@email = 'contacto@floresymas.com';

EXEC p_InsertarClientes
	@razon_social = 'Alimentos Delicias',
	@nombre_comercial = 'Delicias S.A.',
	@direccion_entrega = 'Zona 7, Ciudad de Guatemala',
	@telefono = '7777-8888',
	@email = 'info@delicias.com';

EXEC p_InsertarClientes
	@razon_social = 'Papelería Central',
	@nombre_comercial = 'PapelCentral S.A.',
	@direccion_entrega = 'Zona 1, Escuintla',
	@telefono = '9999-0000',
	@email = 'ventas@papelcentral.com';

EXEC p_InsertarClientes
	@razon_social = 'Ropa Moderna',
	@nombre_comercial = 'Moderna S.A.',
	@direccion_entrega = 'Zona 3, Quetzaltenango',
	@telefono = '1122-3344',
	@email = 'contacto@moderna.com';

EXEC p_InsertarClientes
	@razon_social = 'Accesorios y Más',
	@nombre_comercial = 'AccesoryMax S.A.',
	@direccion_entrega = 'Zona 6, Chimaltenango',
	@telefono = '2233-4455',
	@email = 'ventas@accesorymax.com';

EXEC p_InsertarClientes
	@razon_social = 'Librería Educativa',
	@nombre_comercial = 'LibEdu S.A.',
	@direccion_entrega = 'Zona 9, Ciudad de Guatemala',
	@telefono = '3344-5566',
	@email = 'info@libedu.com';

EXEC p_InsertarClientes
	@razon_social = 'Muebles Elegantes',
	@nombre_comercial = 'Elegance S.A.',
	@direccion_entrega = 'Zona 10, Cobán',
	@telefono = '4455-6677',
	@email = 'ventas@elegance.com';

----------------USUARIOS:
EXEC p_InsertarUsuarios
	@rol_idrol = 1,
	@estados_idestados = 1,
	@correo_electronico = 'usuario@example.com',
	@nombre_completo = 'Yojan Melendez',
	@password = 'password123',
	@telefono = '5678-1234',
	@fecha_nacimiento = '2003-05-19',
	@Clientes_idClientes = 1;

EXEC p_InsertarUsuarios
	@rol_idrol = 1,
	@estados_idestados = 1,
	@correo_electronico = 'usuario2@example.com',
	@nombre_completo = 'Ana López',
	@password = 'pass456',
	@telefono = '5567-8901',
	@fecha_nacimiento = '1990-04-22',
	@Clientes_idClientes = 2;

EXEC p_InsertarUsuarios
	@rol_idrol = 1,
	@estados_idestados = 1,
	@correo_electronico = 'usuario3@example.com',
	@nombre_completo = 'Luis Pérez',
	@password = 'pass789',
	@telefono = '7890-1234',
	@fecha_nacimiento = '1988-09-15',
	@Clientes_idClientes = 3;

EXEC p_InsertarUsuarios
	@rol_idrol = 1,
	@estados_idestados = 1,
	@correo_electronico = 'usuario4@example.com',
	@nombre_completo = 'Carlos Méndez',
	@password = 'clave123',
	@telefono = '4421-3345',
	@fecha_nacimiento = '1995-07-20',
	@Clientes_idClientes = 4;

EXEC p_InsertarUsuarios
	@rol_idrol = 1,
	@estados_idestados = 1,
	@correo_electronico = 'usuario5@example.com',
	@nombre_completo = 'María González',
	@password = 'clave456',
	@telefono = '5544-6677',
	@fecha_nacimiento = '1992-01-18',
	@Clientes_idClientes = 5;

EXEC p_InsertarUsuarios
	@rol_idrol = 1, @estados_idestados = 1, 
	@correo_electronico = 'usuario6@example.com', 
	@nombre_completo = 'Ana López', 
	@password = 'clave789', 
	@telefono = '6678-1234', 
	@fecha_nacimiento = '1998-03-12', 
	@Clientes_idClientes = 6;

EXEC p_InsertarUsuarios
	@rol_idrol = 1, @estados_idestados = 1, 
	@correo_electronico = 'usuario7@example.com', 
	@nombre_completo = 'Luis Pérez', 
	@password = 'clave101', 
	@telefono = '7788-5678', 
	@fecha_nacimiento = '1985-11-24', 
	@Clientes_idClientes = 7;

EXEC p_InsertarUsuarios
	@rol_idrol = 1, @estados_idestados = 1, 
	@correo_electronico = 'usuario8@example.com', 
	@nombre_completo = 'Sofía Ramírez', 
	@password = 'clave202', 
	@telefono = '8899-2345', 
	@fecha_nacimiento = '2000-04-25', 
	@Clientes_idClientes = 8;

EXEC p_InsertarUsuarios
	@rol_idrol = 1, @estados_idestados = 1, 
	@correo_electronico = 'usuario9@example.com', 
	@nombre_completo = 'Pedro Castillo', 
	@password = 'clave303', 
	@telefono = '9900-8765', 
	@fecha_nacimiento = '1990-06-30', 
	@Clientes_idClientes = 9;

EXEC p_InsertarUsuarios
	@rol_idrol = 1, @estados_idestados = 1, 
	@correo_electronico = 'usuario10@example.com', 
	@nombre_completo = 'Gloria Martínez', 
	@password = 'clave404', 
	@telefono = '1234-5678', 
	@fecha_nacimiento = '1993-02-18', 
	@Clientes_idClientes = 10;

EXEC p_InsertarUsuarios
	@rol_idrol = 1, @estados_idestados = 1, 
	@correo_electronico = 'usuario11@example.com', 
	@nombre_completo = 'Fernando Jiménez', 
	@password = 'clave505', 
	@telefono = '2345-6789', 
	@fecha_nacimiento = '1997-09-15', 
	@Clientes_idClientes = 11;


----------------CATEGORIA PRODUCTO:
EXEC p_InsertarCategoriaProd 
    @usuarios_idusuarios = 1, 
    @estados_idestados = 1, 
    @nombre = 'Bebidas';

EXEC p_InsertarCategoriaProd 
    @usuarios_idusuarios = 1, 
    @estados_idestados = 1, 
    @nombre = 'Cereales';

EXEC p_InsertarCategoriaProd 
	@usuarios_idusuarios = 2, 
	@estados_idestados = 1, 
	@nombre = 'Lácteos';

----------------PRODUCTO:

DECLARE @Imagen VARBINARY(MAX);

-- Carga la imagen desde un archivo
SELECT @Imagen = CAST(BULKCOLUMN AS VARBINARY(MAX))
FROM OPENROWSET(BULK 'C:\Users\Usuario\Desktop\Concurso 360\Ejemplo DB.png', SINGLE_BLOB) AS Imagen; --Cambiar el fichero y la Imagen

EXEC p_InsertarProducto 
    @CategoriaProductos_idCategoriaProductos = 1,
    @usuarios_idusuarios = 1,
    @nombre = 'Producto A',
    @marca = 'Marca X',
    @codigo = 'P001',
    @stock = 100,
    @estados_idestados = 1,
    @precio = 150.75,
    @foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 1,
	@usuarios_idusuarios = 1,
	@nombre = 'Producto B',
	@marca = 'Marca Y',
	@codigo = 'P002',
	@stock = 200,
	@estados_idestados = 1,
	@precio = 250.50,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 1,
	@usuarios_idusuarios = 1,
	@nombre = 'Producto C',
	@marca = 'Marca Z',
	@codigo = 'P003',
	@stock = 150,
	@estados_idestados = 2,
	@precio = 100.25,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 1,
	@usuarios_idusuarios = 1,
	@nombre = 'Producto D',
	@marca = 'Marca W',
	@codigo = 'P004',
	@stock = 50,
	@estados_idestados = 1,
	@precio = 300.00,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 1,
	@usuarios_idusuarios = 1,
	@nombre = 'Producto E',
	@marca = 'Marca V',
	@codigo = 'P005',
	@stock = 80,
	@estados_idestados = 2,
	@precio = 175.75,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 1,
	@usuarios_idusuarios = 1,
	@nombre = 'Producto F',
	@marca = 'Marca U',
	@codigo = 'P006',
	@stock = 120,
	@estados_idestados = 1,
	@precio = 220.60,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 2,
	@usuarios_idusuarios = 1,
	@nombre = 'Producto G',
	@marca = 'Marca T',
	@codigo = 'P007',
	@stock = 90,
	@estados_idestados = 2,
	@precio = 330.45,
	@foto = @Imagen;


EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 1,
	@usuarios_idusuarios = 1,
	@nombre = 'Producto H',
	@marca = 'Marca S',
	@codigo = 'P008',
	@stock = 60,
	@estados_idestados = 1,
	@precio = 410.80,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 2,
	@usuarios_idusuarios = 1,
	@nombre = 'Producto I',
	@marca = 'Marca R',
	@codigo = 'P009',
	@stock = 30,
	@estados_idestados = 2,
	@precio = 275.90,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 2,
	@usuarios_idusuarios = 2,
	@nombre = 'Producto J',
	@marca = 'Marca Q',
	@codigo = 'P010',
	@stock = 70,
	@estados_idestados = 1,
	@precio = 360.30,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 2,
	@usuarios_idusuarios = 2,
	@nombre = 'Producto K',
	@marca = 'Marca P',
	@codigo = 'P011',
	@stock = 110,
	@estados_idestados = 2,
	@precio = 410.99,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 3,
	@usuarios_idusuarios = 1,
	@nombre = 'Queso Mozzarella',
	@marca = 'Marca Láctea',
	@codigo = 'P012',
	@stock = 60,
	@estados_idestados = 1,
	@precio = 45.75,
	@foto = @Imagen;

EXEC p_InsertarProducto 
	@CategoriaProductos_idCategoriaProductos = 3,
	@usuarios_idusuarios = 1,
	@nombre = 'Leche Entera',
	@marca = 'Marca Blanca',
	@codigo = 'P013',
	@stock = 100,
	@estados_idestados = 1,
	@precio = 25.50,
	@foto = @Imagen;

----------------ORDEN:
EXEC p_InsertarOrden 
	@usuarios_idusuarios = 1,
	@estados_idestados = 1,
	@nombre_completo = 'Yojans Gabriel Marroquin Melendez',
	@direccion = 'Zona 10, Ciudad de Guatemala',
	@telefono = '5770788',
	@correo_electronico = 'usuario@example.com',
	@fecha_entrega = '2024-12-24',
	@total_orden = 150.75;

EXEC p_InsertarOrden 
	@usuarios_idusuarios = 2,
	@estados_idestados = 1,
	@nombre_completo = 'Ana López',
	@direccion = 'Zona 11, Ciudad de Guatemala',
	@telefono = '5567-8901',
	@correo_electronico = 'usuario2@example.com',
	@fecha_entrega = '2024-08-15',
	@total_orden = 500.00;


EXEC p_InsertarOrden 
	@usuarios_idusuarios = 3,
	@estados_idestados = 1,
	@nombre_completo = 'Luis Pérez',
	@direccion = 'Zona 3, Mixco',
	@telefono = '7890-1234',
	@correo_electronico = 'usuario3@example.com',
	@fecha_entrega = '2024-08-20',
	@total_orden = 750.00;

EXEC p_InsertarOrden 
	@usuarios_idusuarios = 4,
	@estados_idestados = 1,
	@nombre_completo = 'Carlos Méndez',
	@direccion = 'Zona 8, Ciudad de Guatemala',
	@telefono = '4421-3345',
	@correo_electronico = 'usuario4@example.com',
	@fecha_entrega = '2024-09-05',
	@total_orden = 850.00;

EXEC p_InsertarOrden 
	@usuarios_idusuarios = 5,
	@estados_idestados = 1,
	@nombre_completo = 'María González',
	@direccion = 'Zona 2, Antigua Guatemala',
	@telefono = '5544-6677',
	@correo_electronico = 'usuario5@example.com',
	@fecha_entrega = '2024-09-10',
	@total_orden = 950.00;

EXEC p_InsertarOrden 
	@usuarios_idusuarios = 6, 
	@estados_idestados = 1, 
	@nombre_completo = 'Ana López', 
	@direccion = 'Zona 7, Ciudad de Guatemala', 
	@telefono = '6678-1234', 
	@correo_electronico = 'usuario6@example.com', 
	@fecha_entrega = '2024-10-05', 
	@total_orden = 1200.00;

EXEC p_InsertarOrden 
	@usuarios_idusuarios = 7,
	@estados_idestados = 1, 
	@nombre_completo = 'Luis Pérez', 
	@direccion = 'Zona 1, Escuintla', 
	@telefono = '7788-5678', 
	@correo_electronico = 'usuario7@example.com', 
	@fecha_entrega = '2024-10-10', 
	@total_orden = 1800.00;

EXEC p_InsertarOrden 
	@usuarios_idusuarios = 8,
	@estados_idestados = 1, 
	@nombre_completo = 'Sofía Ramírez', 
	@direccion = 'Zona 3, Quetzaltenango', 
	@telefono = '8899-2345', 
	@correo_electronico = 'usuario8@example.com', 
	@fecha_entrega = '2024-10-15', 
	@total_orden = 1500.00;

EXEC p_InsertarOrden 
	@usuarios_idusuarios = 9,
	@estados_idestados = 1, 
	@nombre_completo = 'Pedro Castillo', 
	@direccion = 'Zona 9, Antigua Guatemala', 
	@telefono = '9900-8765', 
	@correo_electronico = 'usuario9@example.com', 
	@fecha_entrega = '2024-10-20', 
	@total_orden = 2100.00;

EXEC p_InsertarOrden 
	@usuarios_idusuarios = 10, 
	@estados_idestados = 1, 
	@nombre_completo = 'Gloria Martínez', 
	@direccion = 'Zona 4, Mazatenango', 
	@telefono = '1234-5678', 
	@correo_electronico = 'usuario10@example.com', 
	@fecha_entrega = '2024-10-25', 
	@total_orden = 1700.00;

EXEC p_InsertarOrden 
	@usuarios_idusuarios = 11, 
	@estados_idestados = 1, 
	@nombre_completo = 'Fernando Jiménez', 
	@direccion = 'Zona 2, San Marcos', 
	@telefono = '2345-6789', 
	@correo_electronico = 'usuario11@example.com', 
	@fecha_entrega = '2024-10-30', 
	@total_orden = 1950.00;

----------------ORDEN DETALLE:
EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 1,
	@Productos_idProductos = 1,
	@cantidad = 10, 
	@precio = 50.75,
	@subtotal = 507.50;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 3,
	@Productos_idProductos = 13,
	@cantidad = 20, 
	@precio = 25.50,
	@subtotal = 510.00;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 2,
	@Productos_idProductos = 12,
	@cantidad = 10, 
	@precio = 45.75,
	@subtotal = 457.50;


EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 4,
	@Productos_idProductos = 4,
	@cantidad = 5, 
	@precio = 300.00,
	@subtotal = 1500.00;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 4,
	@Productos_idProductos = 2,
	@cantidad = 8, 
	@precio = 250.50,
	@subtotal = 2004.00;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 5,
	@Productos_idProductos = 5,
	@cantidad = 10, 
	@precio = 175.75,
	@subtotal = 1757.50;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 5,
	@Productos_idProductos = 6,
	@cantidad = 7, 
	@precio = 220.60,
	@subtotal = 1544.20;
	--
EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 6, 
	@Productos_idProductos = 14, 
	@cantidad = 4, 
	@precio = 100.25, 
	@subtotal = 401.00;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 7,
	@Productos_idProductos = 5, 
	@cantidad = 6, 
	@precio = 175.75, 
	@subtotal = 1054.50;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 7, 
	@Productos_idProductos = 16, 
	@cantidad = 3, 
	@precio = 410.80,
	@subtotal = 1232.40;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 8, 
	@Productos_idProductos = 9, 
	@cantidad = 5, 
	@precio = 275.90,
	@subtotal = 1379.50;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 9, 
	@Productos_idProductos = 2, 
	@cantidad = 2, 
	@precio = 850.50, 
	@subtotal = 1701.00;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 10,	
	@Productos_idProductos = 4, 
	@cantidad = 3, 
	@precio = 425.00, 
	@subtotal = 1275.00;

EXEC p_InsertarOrdenDetalles
	@Orden_idOrden = 11, 
	@Productos_idProductos = 6, 
	@cantidad = 4, 
	@precio = 487.50, 
	@subtotal = 1950.00;

--ACTUALIZAR:
----------------ESTADOS:
CREATE PROCEDURE p_ActualizarEstado
	@idestados INT,
	@nombre VARCHAR(15)
AS
BEGIN
    if EXISTS(SELECT * FROM estados
		WHERE idestados = @idestados)
	BEGIN
      update estados SET nombre = @nombre 
	  WHERE idestados = idestados;
	  PRINT 'Estado actualizado correctamente';
	END
	  ELSE
        BEGIN
            PRINT 'El cliente no existe';
        END
END;
--> Actualizacion de ejemplo:
EXEC p_ActualizarEstado
	@idestados = 1,
	@nombre = 'Activo';


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

--> Actualizacion de ejemplo:
EXEC p_ActualizarRol
	@idrol = 1,
	@nombre = 'Cliente';

----------------CLIENTES:
CREATE PROCEDURE p_ActualizarClientes
    @idClientes INT,
    @razon_social VARCHAR(245),
    @nombre_comercial VARCHAR(345),
    @direccion_entrega VARCHAR(45),
    @telefono VARCHAR(9),
    @correo_electronico VARCHAR(45)
AS
BEGIN
    -- Validar formato de correo
    IF @correo_electronico LIKE '%_@__%.__%'
    BEGIN
        IF EXISTS (SELECT 1 FROM Clientes WHERE idClientes = @idClientes)
        BEGIN
            -- Actualizar cliente
            UPDATE Clientes
            SET 
                razon_social = @razon_social, 
                nombre_comercial = @nombre_comercial, 
                direccion_entrega = @direccion_entrega, 
                telefono = @telefono, 
                email = @correo_electronico
            WHERE idClientes = @idClientes;

            PRINT 'Cliente actualizado correctamente';
        END
        ELSE
        BEGIN
            PRINT 'El cliente no existe';
        END
    END
    ELSE
    BEGIN
        PRINT 'El formato del correo electrónico no es válido';
    END
END;

--> Actualizacion de ejemplo:
EXEC p_ActualizarClientes
	@idClientes = 1,
    @razon_social = 'Comercial El Sol',
    @nombre_comercial = 'El Sol S.A.',
    @direccion_entrega = 'Zona 10, Ciudad de Guatemala',
    @telefono = '1234-5678',
    @correo_electronico = 'contacto@elsol.com';

----------------USUARIOS:
CREATE PROCEDURE p_ActualizarUsuario
	@idusuarios INT,
    @rol_idrol INT,
	@estados_idestados INT,
	@correo_electronico VARCHAR(45),
	@nombre_completo VARCHAR(45),
	@password VARCHAR(45),
	@telefono VARCHAR(9) = NULL,
	@fecha_nacimiento DATE = NULL,
	@Clientes_idClientes INT = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM usuarios WHERE idusuarios = @idusuarios)
    BEGIN
        UPDATE usuarios
        SET rol_idrol = @rol_idrol, 
			estados_idestados = @estados_idestados,
			correo_electronico = @correo_electronico,
			nombre_completo = @nombre_completo,
			password = @password,
			telefono = @telefono,
			fecha_nacimiento = @fecha_nacimiento,
			Clientes_idClientes = @Clientes_idClientes
        WHERE idusuarios = @idusuarios;

        PRINT 'Usuario actualizado correctamente';
    END
    ELSE
    BEGIN
        PRINT 'El Usuario no existe';
    END
END;

--> Actualizacion de ejemplo:
EXEC p_ActualizarUsuario
	@idusuarios = 1,
	@rol_idrol = 1,
	@estados_idestados = 1,
	@correo_electronico = 'usuario@example.com',
	@nombre_completo = 'Yojans Melendez',
	@password = 'password123',
	@telefono = '5678-1234',
	@fecha_nacimiento = '2003-05-19',
	@Clientes_idClientes = 1;

----------------CATEGORIA:
CREATE PROCEDURE p_ActualizarCategoria
	@idCategoriaProductos INT,
	@usuarios_idusuarios INT,
    @estados_idestados INT,
    @nombre VARCHAR(45)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM CategoriaProductos WHERE idCategoriaProductos = @idCategoriaProductos)
    BEGIN
        UPDATE CategoriaProductos
        SET usuarios_idusuarios = @usuarios_idusuarios, 
			estados_idestados = @estados_idestados,
			nombre = @nombre
        WHERE idCategoriaProductos = @idCategoriaProductos;

        PRINT 'Categoria actualizado correctamente';
    END
    ELSE
    BEGIN
        PRINT 'La Categoria no existe';
    END
END;

--> Actualizacion de ejemplo:
EXEC p_ActualizarCategoria 
	@idCategoriaProductos = 1,
    @usuarios_idusuarios = 1, 
    @estados_idestados = 1, 
    @nombre = 'Bebidas';

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

--> Actualizacion de ejemplo:
DECLARE @Imagen VARBINARY(MAX);

-- Carga la imagen desde un archivo
SELECT @Imagen = CAST(BULKCOLUMN AS VARBINARY(MAX))
FROM OPENROWSET(BULK 'C:\Users\Usuario\Desktop\Concurso 360\Ejemplo DB.png', SINGLE_BLOB) AS Imagen;

EXEC p_ActualizarProducto
	@idProductos = 1,
    @CategoriaProductos_idCategoriaProductos = 1,
    @usuarios_idusuarios = 1,
    @nombre = 'Producto A',
    @marca = 'Marca X',
    @codigo = 'P001',
    @stock = 100,
    @estados_idestados = 1,
    @precio = 150.75,
    @foto = @Imagen;

----------------ORDEN:
CREATE PROCEDURE p_ActualizarOrden
	@idOrden INT,
	@usuarios_idusuarios INT,
	@estados_idestados INT,
	@nombre_completo VARCHAR(45),
	@direccion VARCHAR(100),
	@telefono VARCHAR(9),
	@correo_electronico VARCHAR(45),
	@fecha_entrega DATE,
	@total_orden FLOAT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Orden WHERE idOrden = @idOrden)
    BEGIN
        UPDATE Orden
        SET usuarios_idusuarios = @usuarios_idusuarios, 
			estados_idestados = @estados_idestados,
			nombre_completo = @nombre_completo,
			direccion = @direccion,
			telefono = @telefono,
			correo_electronico = @correo_electronico,
			fecha_entrega = @fecha_entrega,
			total_orden = @total_orden
        WHERE idOrden = @idOrden;

        PRINT 'Orden actualizada correctamente';
    END
    ELSE
    BEGIN
        PRINT 'El numero de la orden no existe';
    END
END;

--> Actualizacion de ejemplo:
EXEC p_ActualizarOrden
	@idOrden = 1,
	@usuarios_idusuarios = 1,
	@estados_idestados = 1,
	@nombre_completo = 'Yojans Gabriel Marroquin Melendez',
	@direccion = 'Zona 10, Ciudad de Guatemala',
	@telefono = '5770788',
	@correo_electronico = 'usuario@example.com',
	@fecha_entrega = '2024-12-24',
	@total_orden = 150.75;

----------------ORDEN DETALLES:

CREATE PROCEDURE p_ActualizarOrdenDetalle
	@idOrdenDetalles INT,
	@Orden_idOrden INT,
	@Productos_idProductos INT,
	@cantidad INT, 
	@precio FLOAT,
	@subtotal FLOAT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM OrdenDetalles WHERE idOrdenDetalles = @idOrdenDetalles)
    BEGIN
        UPDATE OrdenDetalles
        SET Orden_idOrden = @Orden_idOrden, 
			Productos_idProductos = @Productos_idProductos,
			cantidad = @cantidad,
			precio = @precio,
			subtotal = @subtotal
        WHERE idOrdenDetalles = @idOrdenDetalles;

        PRINT 'Registro actualizado correctamente';
    END
    ELSE
    BEGIN
        PRINT 'El numero del registro no existe';
    END
END;

--> Actualizacion de ejemplo:
EXEC p_ActualizarOrdenDetalle
	@idOrdenDetalles = 1,
	@Orden_idOrden = 1,
	@Productos_idProductos = 1,
	@cantidad = 10, 
	@precio = 50.75,
	@subtotal = 507.50;

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

--Ejemplo de Inactivacion:
EXEC p_InactivarProducto
	@idProductos = 1,
    @estados_idestados = 1;

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

