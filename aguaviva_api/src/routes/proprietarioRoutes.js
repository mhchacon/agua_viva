const express = require('express');
const router = express.Router();
const proprietarioController = require('../controllers/proprietarioController');

// Rota para cadastro
router.post('/', proprietarioController.criarProprietario);

// Rota para login
router.post('/login', proprietarioController.loginProprietario);

module.exports = router; 