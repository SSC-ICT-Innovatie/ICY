const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');
const authenticateToken = require('../middleware/authenticateToken');

router.post('/insights', authenticateToken, aiController.generateAIInsights);

module.exports = router;
