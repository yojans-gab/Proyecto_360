const { Sequelize } = require('sequelize');
const { db } = require('../config/settings'); // Importar configuración

const connectDB = async () => {
    try {
        const sequelize = new Sequelize(
            db.name,      // Nombre de la base de datos
            db.user,      // Usuario
            db.password,  // Contraseña
            {
                host: db.host,      // Host
                dialect: db.dialect, // Dialecto
                port: db.port,      // Puerto
            }
        );
        console.log('Conexion exitosa')
        return sequelize;
    } catch (error) {
        console.log(error, 'No se puede conectar a la base de datos');
    }
};

module.exports = connectDB;
