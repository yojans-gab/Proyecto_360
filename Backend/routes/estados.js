const express = require('express');
const router = express.Router();
const estadosController = require('../controllers/estadosController')


//Rutas para estados
router.get('/estados', estadosController.getEstado);
router.post('/estados', estadosController.createEstado);
router.patch('/estados/update/:id', estadosController.updateEstado)

module.exports = router;
