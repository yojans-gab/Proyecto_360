const express = require('express');
const router = express.Router();
const productsController = require('../controllers/productsController')

// Rutas para producto

router.get('/products', productsController.getProducts);
router.post('/products', productsController.createProduct);
router.patch('/products/update/:id',productsController.updateProductById)

module.exports = router;
