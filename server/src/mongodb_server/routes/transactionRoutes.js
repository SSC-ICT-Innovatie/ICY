const express = require("express");
const router = express.Router();
const transactionController = require("../controllers/transactionController");

router.get("/", transactionController.getTransactions);
router.get("/count", transactionController.getTransactionCount);
router.get("/all", transactionController.getAllTransactions);
router.post("/", transactionController.addTransaction);


module.exports = router;
