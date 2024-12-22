const express = require('express');
const router = express.Router();
const userControllers = require('../controllers/userControllers')


//Rutas para usuarios
router.get('/usuarios', userControllers.getUsers);
router.post('/usuarios', userControllers.createUser);
router.patch('/usuarios/update/:id', userControllers.updateUser)

module.exports = router;