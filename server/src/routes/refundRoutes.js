// routes/refundRoutes.js
const express = require('express');
const router = express.Router();
const refundController = require('../controllers/refundController');

router.post('/process', refundController.processRefund);

module.exports = router;