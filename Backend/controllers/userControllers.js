const conexion = require('../DBConection/db');
const bcryptjs = require('bcryptjs');
//require('dotenv').config({path:'../.env'})
const config = require('../config/settings');
const jwt = require('jsonwebtoken');
const { secret_word } = config;


// Crear usuario (solo usuarios con rol "Operador")
exports.createUser = async (req, res) => {
    const pool = await conexion();
    const { rol_idrol } = req.user; // Datos del token
    const { 
        rol_idrol: nuevoRol, 
        estados_idestados, 
        correo_electronico, 
        nombre_completo, 
        password, 
        telefono, 
        fecha_nacimiento, 
        Clientes_idClientes 
    } = req.body;

    try {
        // Verificar si el rol es "Operador"
        if (rol_idrol !== 2) { // 2 es el idrol para "Operador"
            return res.status(403).json({ msg: 'Solo los usuarios con rol Operador pueden crear usuarios' });
        }

        // Hasheo de la contraseña
        const salt = await bcryptjs.genSalt(10);
        const hashedPassword = await bcryptjs.hash(password, salt);

        // Ejecutar procedimiento almacenado
        const [result] = await pool.query(
            `DECLARE @mensaje NVARCHAR(50), @usuario_id INT;
             EXEC p_InsertarUsuarios
                 @rol_idrol=:nuevoRol,
                 @estados_idestados=:estados_idestados,
                 @correo_electronico=:correo_electronico,
                 @nombre_completo=:nombre_completo,
                 @password=:hashedPassword,
                 @telefono=:telefono,
                 @fecha_nacimiento=:fecha_nacimiento,
                 @Clientes_idClientes=:Clientes_idClientes,
                 @mensaje=@mensaje OUTPUT,
                 @usuario_id = @usuario_id OUTPUT;
             SELECT @mensaje AS mensaje, @usuario_id AS usuario_id;`,
            {
                replacements: { 
                    nuevoRol, 
                    estados_idestados, 
                    correo_electronico, 
                    nombre_completo, 
                    hashedPassword, 
                    telefono, 
                    fecha_nacimiento, 
                    Clientes_idClientes 
                },
            }
        );

        const mensaje = result[0]?.mensaje;
        const idUsuario = result[0]?.usuario_id;

        const payload = {
            user: {
                id: idUsuario,
                firstName: nombre_completo,
                email: correo_electronico,
                userRol: nuevoRol,
                belognsToCliente: Clientes_idClientes
            }
        };

        jwt.sign(payload, secret_word, { expiresIn: '24h' }, (error, token) => {
            if (error) throw error;
            res.status(200).json({ msg: mensaje, data: { ...payload, token } });
        });
    } catch (error) {
        console.error('Error al insertar usuario:', error);
        res.status(500).json({ error: 'Error al insertar usuario' });
    } finally {
        await pool.close();
    }
};


// Obtener usuarios (solo Operador)
exports.getUsers = async (req, res) => {
    const pool = await conexion();
    const { rol_idrol } = req.user; // Datos del token
    const { 
        rol_idrol: nuevoRol, 
        estados_idestados, 
        correo_electronico, 
        nombre_completo, 
        password, 
        telefono, 
        fecha_nacimiento, 
        Clientes_idClientes 
    } = req.body;


    try {
        // Verificar si el rol es "Operador"
        if (rol_idrol !== 2) { // 2 es el idrol para "Operador"
            return res.status(403).json({ msg: 'Solo los usuarios con rol Operador pueden ver los usuarios' });
        }

        const [users] = await pool.query('SELECT * FROM usuarios');
        res.status(200).json({ msg: 'Usuarios encontrados', users });
    } catch (error) {
        console.error('Error al obtener usuarios:', error);
        res.status(500).json({ msg: 'Error al obtener usuarios' });
    } finally {
        await pool.close();
    }
};

// Actualizar usuario (solo Operador)
exports.updateUser = async (req, res) => {
    const pool = await conexion();
    const { id } = req.params;
    const { rol_idrol, estados_idestados, correo_electronico, nombre_completo, password, telefono, fecha_nacimiento, Clientes_idClientes } = req.body;

    try {
        // Extraer el rol del usuario autenticado desde el token
        const { rol_idrol } = req.user; // Se espera que el middleware de autenticación haya añadido esta información a `req.user`

        // Verificar si el usuario autenticado tiene el rol de "Operador"
        if (rol_idrol !== 2) { // Si el rol no es "Operador" (id 2)
            return res.status(403).json({ msg: 'Solo los usuarios con rol Operador pueden editar usuarios' });
        }

        // Ejecutar la actualización del usuario
        const [result] = await pool.query(
            `DECLARE @mensaje NVARCHAR(50);
             EXEC p_ActualizarUsuario
                 @idusuarios=:id,
                 @rol_idrol=:rol_idrol,
                 @estados_idestados=:estados_idestados,
                 @correo_electronico=:correo_electronico,
                 @nombre_completo=:nombre_completo,
                 @password=:password,
                 @telefono=:telefono,
                 @fecha_nacimiento=:fecha_nacimiento,
                 @Clientes_idClientes=:Clientes_idClientes,
                 @mensaje=@mensaje OUTPUT;
             SELECT @mensaje AS mensaje;`,
            {
                replacements: { id, rol_idrol, estados_idestados, correo_electronico, nombre_completo, password, telefono, fecha_nacimiento, Clientes_idClientes },
            }
        );

        const mensaje = result[0]?.mensaje;
        res.json({ msg: mensaje });
    } catch (error) {
        console.error('Error al actualizar usuario:', error);
        res.status(500).json({ msg: 'Error al actualizar usuario' });
    } finally {
        await pool.close();
    }
};
