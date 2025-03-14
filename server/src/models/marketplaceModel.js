const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  icon: {
    type: String,
    required: true
  }
}, {
  timestamps: true
});

const itemSchema = new mongoose.Schema({
  categoryId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MarketplaceCategory',
    required: true
  },
  name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  image: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true
  },
  available: {
    type: Boolean,
    default: true
  },
  featured: {
    type: Boolean,
    default: false
  },
  quantity: {
    type: Number
  },
  expiryDays: {
    type: Number
  },
  permanent: {
    type: Boolean,
    default: false
  },
  approvalRequired: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

const purchaseSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  itemId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MarketplaceItem',
    required: true
  },
  purchaseDate: {
    type: Date,
    default: Date.now
  },
  expiryDate: {
    type: Date
  },
  used: {
    type: Boolean,
    default: false
  },
  redeemCode: {
    type: String
  },
  status: {
    type: String,
    enum: ['active', 'used', 'expired', 'pending_approval', 'approved', 'rejected'],
    default: 'active'
  },
  permanent: {
    type: Boolean,
    default: false
  },
  active: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

const MarketplaceCategory = mongoose.model('MarketplaceCategory', categorySchema);
const MarketplaceItem = mongoose.model('MarketplaceItem', itemSchema);
const Purchase = mongoose.model('Purchase', purchaseSchema);

module.exports = {
  MarketplaceCategory,
  MarketplaceItem,
  Purchase
};
