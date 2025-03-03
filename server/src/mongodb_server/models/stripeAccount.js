const mongoose = require('mongoose');

const stripeAccountSchema = new mongoose.Schema({
  company_id: { type: String, required: true, unique: true },
  stripe_account_id: { type: String, required: true, unique: true },
  // stripe_keys: { type: String, required: true },
  country: { type: String, required: true },
  currency: { type: String, required: true },
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now },
});

module.exports = mongoose.model('StripeAccount', stripeAccountSchema);
