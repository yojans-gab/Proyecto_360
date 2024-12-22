const express = require('express');
const router = express.Router();
const ordenControllers = require('../controllers/ordenControllers')


//Rutas para Ordenes
router.get('/orden', ordenControllers.getOrdenes);
router.post('/orden', ordenControllers.createOrden);
router.patch('/orden/update/:id', ordenControllers.updateOrden)

module.exports = router;
