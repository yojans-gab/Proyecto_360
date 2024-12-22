const conexion = require('../DBConection/db');
const bcryptjs = require('bcryptjs');
//require('dotenv').config({path:'../.env'})
const config = require('../config/settings');
const jwt = require('jsonwebtoken');
const { secret_word } = config;

exports.loginUser = async (req, res) => {
    const { correo_electronico, password } = req.body;
    const pool = await conexion();

    try {
        // Verificar si el correo electrónico existe
        const [user] = await pool.query(
            `SELECT * FROM usuarios WHERE correo_electronico=:correo_electronico`,
            { replacements: { correo_electronico }, }
        );  

        if (!user[0]) {
            return res.status(400).json({ msg: "El correo electrónico no está registrado" });
        }

        const usuario = user[0];

        if(usuario.password !== password){
            return res.status(401).json({ msg: "Contraseña incorrecta" });  
        }

        // Verificar si el usuario está activo
        if (usuario.estados_idestados === 2) {
            return res.status(403).json({ msg: "El usuario está inactivo" });
        }

        // Crear token
        const payload = {
            user: {
                id: usuario.idusuarios,
                firstName: usuario.nombre_completo,
                email: usuario.correo_electronico,
                userRol: usuario.rol_idrol,
                belognsToCliente: usuario.Clientes_idClientes
            }
        };

        jwt.sign(payload, secret_word, { expiresIn: '24h' }, (error, token) => {
            if (error) throw error;
            res.status(200).json({ msg: "Inicio de sesión exitoso", data: { ...payload, token } });
        });
    } catch (error) {
        console.error("Error al iniciar sesión:", error);
        res.status(500).json({ msg: "Error al iniciar sesión" });
    } finally {
        await pool.close();
    }
};

