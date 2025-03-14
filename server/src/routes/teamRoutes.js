const express = require('express');
const {
  getTeams,
  getTeamById,
  getUserTeam,
  getLeaderboard,
  getLeagues
} = require('../controllers/teamController');
const { protect, authorize } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);

router.route('/')
  .get(getTeams);

router.route('/my-team')
  .get(getUserTeam);

router.route('/leaderboard')
  .get(getLeaderboard);

router.route('/leagues')
  .get(getLeagues);

router.route('/:id')
  .get(getTeamById);

module.exports = router;
