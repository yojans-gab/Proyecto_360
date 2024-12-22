const express = require('express');
const router = express.Router();
const categoriaControllers = require('../controllers/categoriaControllers')


//Rutas para Categorias
router.get('/categoria', categoriaControllers.getCategoria);
router.post('/categoria', categoriaControllers.createCategoria);
router.patch('/categoria/update/:id', categoriaControllers.updateCategoria)

module.exports = router;