const express = require('express');
const router = express.Router();


router.get('/products', (req, res)=> {
    res.json({msg:'Hola desde el servidor'})
})

module.exports = router;
