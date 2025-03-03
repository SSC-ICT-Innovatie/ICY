const mongoose = require("mongoose");

const productSchema = new mongoose.Schema({
  product_id: { type: String, required: true },
  company_id: { type: String, required: true },
  section_id: { type: String, required: true },
  name: { type: String, required: true },
  image_url: { type: String, required: false },
  date_added: { type: Date, default: Date.now },
  date_modified: { type: Date, default: Date.now },
  item_number: { type: Number, required: true, default: 0.0 },
  price: { type: Number, required: true, default: 0 },
  bonus_percentage: { type: Number, default: 0 },
  is_in_bonus: { type: Boolean, default: false },
  is_selling: { type: Boolean, default: true },
  info: { type: String, default: "" },
  extra_note: { type: String, default: "" },
});

// Create a compound index on product_id and company_id
productSchema.index({ product_id: 1, company_id: 1 }, { unique: true });

module.exports = mongoose.model("Product", productSchema);