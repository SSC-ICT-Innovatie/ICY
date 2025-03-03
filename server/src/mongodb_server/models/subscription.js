const mongoose = require('mongoose');
const subscriptionSchema = new mongoose.Schema({
  company_id: { type: String, required: true },
  stripe_customer_id: { type: String, required: true },
  subscription_id: { type: String, required: true },
  plan: { type: String, required: true, enum: ['Basic', 'Pro', 'Enterprise'] },
  billingCycle: { type: String, required: true, enum: ['monthly', 'yearly'] },
  status: { type: String, required: true, enum: ['active', 'past_due', 'canceled', 'unpaid'] },
  current_period_end: { type: Date, required: true },
  is_early_access: { type: Boolean, default: false },
  early_access_expiry: Date,
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now },
});
module.exports = mongoose.model('Subscription', subscriptionSchema);