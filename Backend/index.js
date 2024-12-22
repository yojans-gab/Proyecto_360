const express = require('express');
const { Sequelize } = require('sequelize');
const config = require('./config/settings')
const checkUser = require('./middlewares/Validation')


const productsRoute = require('./routes/products')
const estadosRoute = require('./routes/estados')
const categoriasRoute = require('./routes/categoria')
const usariosRoute = require('./routes/usuarios')
const clientesRoute = require('./routes/clientes')
const ordenRoute = require('./routes/orden')
const loginRoute = require('./routes/login')


// Definir la aplicación
const app = express();

// Habilitar JSON
app.use(express.json({ extended: true}));

// Configurar el puerto
const port = 3000;

app.use('/api', loginRoute)
app.use('/api', checkUser, usariosRoute)
app.use('/api', clientesRoute)
app.use('/api', checkUser, productsRoute)
app.use('/api', checkUser, estadosRoute)
app.use('/api', checkUser, categoriasRoute)
app.use('/api', checkUser, ordenRoute)


// Servidor
app.listen( (port), () => {
    console.log(`La aplicación se está ejecutando en el puerto. ${port}`);
});