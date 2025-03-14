const express = require('express');
const {
  getBadges,
  getUserBadges,
  getActiveChallenges,
  getUserAchievements,
  getRecentAchievements
} = require('../controllers/achievementController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);

router.route('/badges')
  .get(getBadges);

router.route('/badges/my')
  .get(getUserBadges);

router.route('/challenges')
  .get(getActiveChallenges);

router.route('/achievements')
  .get(getUserAchievements);

router.route('/achievements/recent')
  .get(getRecentAchievements);

module.exports = router;
