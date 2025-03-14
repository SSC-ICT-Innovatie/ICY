const express = require('express');
const {
  getCategories,
  getItems,
  getItemById,
  getUserPurchases,
  purchaseItem,
  redeemPurchase
} = require('../controllers/marketplaceController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);

router.route('/categories')
  .get(getCategories);

router.route('/items')
  .get(getItems);

router.route('/items/:id')
  .get(getItemById);

router.route('/purchases')
  .get(getUserPurchases);

router.route('/items/:id/purchase')
  .post(purchaseItem);

router.route('/purchases/:id/redeem')
  .post(redeemPurchase);

module.exports = router;
