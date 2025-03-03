const express = require("express");
const router = express.Router();
const qrController = require("../controllers/qrController");
const { check } = require("express-validator");
const validateRequest = require("../middleware/validateRequest");
const authenticateToken = require("../middleware/authenticateToken");
const checkTransactionLimits = require('../middleware/checkTransactionLimits');
router.post(
  "/generate",
  [
    check("currency").isString().withMessage("Currency must be a string"),
    check("deviceId").isString().withMessage("Device ID must be a string"),
    check("products").isArray().withMessage("Products must be an array"),
    check("quantities").isArray().withMessage("Quantities must be an array"),
    check("stripeAccount").isString().withMessage("Stripe Account must be a string"),
  ],
  validateRequest,
  authenticateToken,
  checkTransactionLimits,  // This will now properly enforce limits
  qrController.generateQR
);

router.get(
  "/check-latest-transaction",
   authenticateToken,
  qrController.checkLatestTransactionStatus,
);

module.exports = router;
