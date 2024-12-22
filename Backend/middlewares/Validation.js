const conexion = require('../DBConection/db');
const jwt = require('jsonwebtoken');
const config = require('../config/settings');
const { secret_word } = config;

const validateUser = async (req, res, next) => {
    let token;
    const { authorization } = req.headers;

    if (authorization && authorization.startsWith('Bearer')) {
        token = authorization.split(' ')[1];
    } else {
        return res.status(401).json({ msg: 'Falta el encabezado de autorización o no es válido' });
    }

    try {
        // Verificar token
        const decoded = jwt.verify(token, secret_word);
        const pool = await conexion();

        // Consultar usuario
        const [consulta] = await pool.query(
            `SELECT idusuarios, rol_idrol, estados_idestados, Clientes_idClientes 
             FROM usuarios 
             WHERE idusuarios = :userID`,
            { replacements: { userID: decoded.user.id } }
        );

        if (!consulta[0]) {
            return res.status(404).json({ msg: 'Usuario no encontrado' });
        }

        req.user = consulta[0]; // Adjuntar usuario al objeto `req` para los siguientes middlewares
        await pool.close();
        return next();

    } catch (error) {
        console.error('Error de verificación de token:', error);
        return res.status(403).json({ msg: 'Token no válido o caducado' });
    }
};

module.exports = validateUser;
