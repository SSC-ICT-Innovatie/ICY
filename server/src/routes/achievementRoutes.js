const express = require('express');
const router = express.Router();
const {
  getBadges,
  getUserBadges,
  getChallenges,
  getRecentAchievements,
  createBadge,
  updateBadge,
  deleteBadge,
  markAchievementAsComplete
} = require('../controllers/achievementController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Public routes (require authentication but no special role)
router.get('/badges', protect, getBadges);
router.get('/badges/my', protect, getUserBadges);
router.get('/challenges', protect, getChallenges);
router.get('/recent', protect, getRecentAchievements);

// Admin only routes
router.post('/badges', protect, authorize('admin'), createBadge);
router.put('/badges/:id', protect, authorize('admin'), updateBadge);
router.delete('/badges/:id', protect, authorize('admin'), deleteBadge);

// User action routes
router.post('/complete/:id', protect, markAchievementAsComplete);

module.exports = router;
