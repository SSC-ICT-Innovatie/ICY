const { MarketplaceCategory, MarketplaceItem, Purchase } = require('../models/marketplaceModel');
const User = require('../models/userModel');
const asyncHandler = require('../middleware/asyncMiddleware');
const { createError } = require('../utils/errorUtils');

const getCategories = asyncHandler(async (req, res) => {
  const categories = await MarketplaceCategory.find();
  
  res.status(200).json({
    success: true,
    count: categories.length,
    data: categories
  });
});

const getItems = asyncHandler(async (req, res) => {
  let query = {};
  
  if (req.query.categoryId) {
    query.categoryId = req.query.categoryId;
  }
  
  if (req.query.featured === 'true') {
    query.featured = true;
  }
  
  const items = await MarketplaceItem.find(query);
  
  res.status(200).json({
    success: true,
    count: items.length,
    data: items
  });
});

const getItemById = asyncHandler(async (req, res) => {
  const item = await MarketplaceItem.findById(req.params.id);
  
  if (!item) {
    throw createError(404, `Item with id ${req.params.id} not found`);
  }
  
  res.status(200).json({
    success: true,
    data: item
  });
});

const getUserPurchases = asyncHandler(async (req, res) => {
  const purchases = await Purchase.find({ 
    userId: req.user._id 
  })
  .populate('itemId', 'name image description')
  .sort({ purchaseDate: -1 });
  
  res.status(200).json({
    success: true,
    count: purchases.length,
    data: purchases
  });
});

const purchaseItem = asyncHandler(async (req, res) => {
  const item = await MarketplaceItem.findById(req.params.id);
  
  if (!item) {
    throw createError(404, `Item with id ${req.params.id} not found`);
  }
  
  if (!item.available) {
    throw createError(400, 'This item is not available');
  }
  
  const user = await User.findById(req.user._id);
  
  if (user.stats.totalCoins < item.price) {
    throw createError(400, 'Not enough coins to purchase this item');
  }
  
  const existingPurchase = await Purchase.findOne({
    userId: req.user._id,
    itemId: item._id,
    active: true,
    permanent: true
  });
  
  if (existingPurchase) {
    throw createError(400, 'You already own this item');
  }
  
  const purchase = await Purchase.create({
    userId: req.user._id,
    itemId: item._id,
    permanent: item.permanent || false,
    expiryDate: item.expiryDays 
      ? new Date(Date.now() + item.expiryDays * 24 * 60 * 60 * 1000) 
      : null,
    status: item.approvalRequired ? 'pending_approval' : 'active',
    redeemCode: generateRedeemCode()
  });
  
  user.stats.totalCoins -= item.price;
  await user.save();
  
  if (item.quantity) {
    item.quantity -= 1;
    if (item.quantity <= 0) {
      item.available = false;
    }
    await item.save();
  }
  
  res.status(201).json({
    success: true,
    data: purchase,
    remainingCoins: user.stats.totalCoins
  });
});

const redeemPurchase = asyncHandler(async (req, res) => {
  const purchase = await Purchase.findById(req.params.id);
  
  if (!purchase) {
    throw createError(404, `Purchase with id ${req.params.id} not found`);
  }
  
  if (purchase.userId.toString() !== req.user._id.toString()) {
    throw createError(403, 'Not authorized to redeem this purchase');
  }
  
  if (purchase.status !== 'active') {
    throw createError(400, `Cannot redeem purchase with status: ${purchase.status}`);
  }
  
  if (purchase.used) {
    throw createError(400, 'This purchase has already been redeemed');
  }
  
  if (purchase.expiryDate && new Date(purchase.expiryDate) < new Date()) {
    purchase.status = 'expired';
    purchase.active = false;
    await purchase.save();
    
    throw createError(400, 'This purchase has expired');
  }
  
  purchase.used = true;
  purchase.status = 'used';
  await purchase.save();
  
  res.status(200).json({
    success: true,
    data: purchase
  });
});

function generateRedeemCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 8; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

module.exports = {
  getCategories,
  getItems,
  getItemById,
  getUserPurchases,
  purchaseItem,
  redeemPurchase
};
