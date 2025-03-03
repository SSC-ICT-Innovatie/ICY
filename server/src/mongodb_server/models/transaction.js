// src/mongodb_server/models/transaction.js
const mongoose = require("mongoose");

const productBoughtSchema = new mongoose.Schema({
  sectionId: { type: String, required: true },
  productId: { type: String, required: true },
  name: { type: String, required: true },
  imageUrl: { type: String, required: true },
  date: { type: Date, default: Date.now },
  wasInBonus: { type: Boolean, default: false },
  bonusPrice: { type: Number },
  priceBought: { type: Number, required: true },
  quantity: { type: Number, required: true },
});

const transactionSchema = new mongoose.Schema({
  transactionId: { type: String, required: true},
  sessionId: {type:String,required: false},
  deviceId: { type: String, required: true },
  companyId: { type: String, required: true },
  transactionDate: { type: Date, default: Date.now },
  paymentMethod: { type: String, required: true },
  status: { type: String, required: true, default: "pending" },
  receiptUrl: { type: String, required: true },
  productsBought: [productBoughtSchema],
  totalQuantity: { type: Number, required: true },
  totalAmount: { type: Number, required: true },
});


transactionSchema.index({transactionId: 1, company_id: 1 }, { unique: true });
// efficient indexing for quick checks
transactionSchema.index({ companyId: 1, status: 1, transactionDate: 1 });


module.exports = mongoose.model("Transaction", transactionSchema);
