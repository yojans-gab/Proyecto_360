const express = require('express');
const router = express.Router();
const loginControllers = require('../controllers/loginControllers')


//Ruta para login

router.post('/login', loginControllers.loginUser)

module.exports = router;