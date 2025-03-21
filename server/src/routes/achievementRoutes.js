const express = require('express');
const router = express.Router();
const {
  getAchievements,
  getAchievementById,
  getUserAchievements,
  getBadges,
  getUserBadges,
  getChallenges,
  getUserChallenges,
  completeChallenge
} = require('../controllers/achievementController');
const { protect } = require('../middleware/authMiddleware');

// Add missing route for recent achievements
router.get('/recent', protect, getRecentAchievements);

// Public routes
router.get('/', getAchievements);
router.get('/:id', getAchievementById);

// Protected routes
router.get('/user/achievements', protect, getUserAchievements);
router.get('/badges', protect, getBadges);
router.get('/badges/my', protect, getUserBadges);
router.get('/challenges', protect, getChallenges);
router.get('/challenges/my', protect, getUserChallenges);
router.post('/challenges/:id/complete', protect, completeChallenge);

// Add this function at the bottom
function getRecentAchievements(req, res) {
  // This is a temporary implementation until proper functionality is added
  res.status(200).json({
    success: true,
    data: [
      {
        id: '1',
        title: 'First Survey',
        description: 'Completed your first survey',
        icon: 'check_circle',
        color: '#4CAF50',
        timestamp: new Date().toISOString(),
        reward: '+50 XP'
      },
      {
        id: '2',
        title: '3-Day Streak',
        description: 'Completed surveys for 3 days in a row',
        icon: 'local_fire_department',
        color: '#FF9800',
        timestamp: new Date(Date.now() - 86400000).toISOString(),
        reward: '+100 XP'
      }
    ]
  });
}

module.exports = router;
