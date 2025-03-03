const express = require('express');
const router = express.Router();
const clientMachineController = require('../controllers/clientMachineController');
const authMiddleware = require('../../middleware/authenticateToken');

router.use(authMiddleware);

// More general routes first
router.get('/', clientMachineController.getAllClientMachines);
router.post('/', clientMachineController.addClientMachine);
router.post('/deleteMultiple', clientMachineController.deleteClientMachines);

// Then more specific routes
router.get('/:deviceId', clientMachineController.getClientMachine);
router.put('/:deviceId', clientMachineController.updateClientMachine);
router.delete('/:deviceId', clientMachineController.deleteClientMachine);

module.exports = router;