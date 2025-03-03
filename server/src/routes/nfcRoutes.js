const express = require("express");
const router = express.Router();
const nfcController = require("../controllers/nfcController");
const { check } = require("express-validator");
const validateRequest = require("../middleware/validateRequest");
const authenticateToken = require("../middleware/authenticateToken");

// Create NFC payment intent
router.post(
  "/create-intent",
  [
    check("amount").isNumeric().withMessage("Amount must be a number"),
    check("currency").isString().withMessage("Currency must be a string"),
    check("deviceId").isString().withMessage("Device ID must be a string"),
  ],
  validateRequest,
  authenticateToken,
  nfcController.createPaymentIntent
);

// Process NFC payment
router.post(
  "/process-payment",
  [
    check("paymentIntentId").isString().withMessage("Payment Intent ID must be a string"),
    check("paymentMethodId").isString().withMessage("Payment Method ID must be a string"),
    check("products").isArray().withMessage("Products must be an array"),
    check("quantities").isArray().withMessage("Quantities must be an array"),
  ],
  validateRequest,
  authenticateToken,
  nfcController.processPayment
);

// Create Stripe Terminal connection token
router.post(
  "/connection-token",
  authenticateToken,
  nfcController.createConnectionToken
);

module.exports = router;