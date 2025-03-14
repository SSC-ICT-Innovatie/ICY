const express = require('express');
const {
  getUsers,
  getUserById,
  updateUser,
  updatePreferences,
  getUserStats
} = require('../controllers/userController');
const { protect, authorize } = require('../middleware/authMiddleware');

const router = express.Router();

// Apply protection to all routes
router.use(protect);

// User routes
router.route('/preferences').put(updatePreferences);
router.route('/stats').get(getUserStats);

// Admin routes
router.route('/')
  .get(authorize('admin'), getUsers);

router.route('/:id')
  .get(authorize('admin', 'team_lead'), getUserById)
  .put(updateUser);

module.exports = router;
