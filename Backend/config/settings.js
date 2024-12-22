const { config } = require('dotenv');

// Cargar las variables de entorno
config();

module.exports = {
    secret_word: process.env.SECRET_WORD,
    db: {
        name: process.env.DB_NAME,       // Nombre de la base de datos
        user: process.env.DB_USER,       // Usuario de la base de datos
        password: process.env.DB_PASSWORD, // Contraseña
        host: process.env.DB_HOST,       // Host
        port: process.env.DB_PORT,       // Puerto
        dialect: process.env.DB_DIALECT  // Dialecto 
    }
};
