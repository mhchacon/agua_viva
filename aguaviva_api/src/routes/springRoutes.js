const express = require('express');
const router = express.Router();
const springController = require('../controllers/springController');

router.post('/', springController.createSpring);
router.get('/', springController.getAllSprings);
router.get('/:id', springController.getSpringById);
router.put('/:id', springController.updateSpring);
router.delete('/:id', springController.deleteSpring);
router.get('/owner/:ownerId', springController.getSpringsByOwner);

module.exports = router; 