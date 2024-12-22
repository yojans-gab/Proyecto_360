const express = require('express');
const router = express.Router();
const clientesControllers = require('../controllers/clientesControllers')


//Rutas para Clientes
router.get('/clientes', clientesControllers.getCliente);
router.post('/clientes', clientesControllers.createCliete);
router.patch('/clientes/update/:id', clientesControllers.updateEstado)

module.exports = router;