// routes/receiptRoutes.js
const express = require('express');
const router = express.Router();
const receiptController = require('../controllers/receiptController');

router.post('/send', receiptController.sendReceipt);

module.exports = router;