Proyecto Node.js
Este proyecto es una API REST creada con Node.js, Express y PostgreSQL, diseñada para gestionar información de usuarios, categorías y roles, con autenticación basada en JWT y validaciones.

Características Principales
CRUD (Insertar / Actualizar) para:
-Productos.
-Categorías.
-Estados.
-Usuarios.
-Orden/Detalles.
-Clientes
-Autenticación segura mediante JSON Web Tokens (JWT).
-Validación de permisos basada en roles para operaciones específicas.
-Procedimientos almacenados en la base de datos para operaciones CRUD.

Tecnologías Utilizadas
-Node.js
-Express
-Postman
-SQLServer
-Sequelize (ORM)
-JWT para autenticación
-dotenv para configuraciones seguras

Configuración de las variables de entorno:
DB_NAME=GDA00479-OT-YojansMarroquín
DB_USER=sa
DB_PASSWORD=1905
DB_HOST=localhost
DB_PORT=1433
DB_DIALECT=mssql
SECRET_WORD=una_palabra_super_secreta

Rutas del API

Usuarios
Crear Usuario: POST /usuarios
Obtener Usuarios: GET /usuarios
Actualizar Usuario: PATCH /usuarios/:id

Categorías
Crear Categoría: POST /categorias
Obtener Categorías: GET /categorias
Actualizar Categoría: PATCH /categorias/:id

Producto
Crear Producto: POST /products
Obtener Producto: GET /products
Actualizar Producto: PATCH /products/:id

Estados
Crear Estados: POST /estados
Obtener Estados: GET /estados
Actualizar Estados: PATCH /estados/:id

Clientes
Crear Clientes: POST /clientes
Obtener Clientes: GET /clientes
Actualizar Clientes: PATCH /clientes/:id

Login
Login User: POST /login


Dependencias
"bcryptjs"
"cors"
"dotenv"
"express"
"jsonwebtoken"
"sequelize"
"tedious"

