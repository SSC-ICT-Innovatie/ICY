const express = require('express');
const router = express.Router();
const { 
  getAdminStats, 
  getDashboardData,
  getUsersActivity,
  getSurveyCompletionStats
} = require('../controllers/adminController');
const { protect, authorize } = require('../middleware/authMiddleware');

// All routes are protected and require admin role
router.use(protect);
router.use(authorize('admin'));

// Admin statistics
router.get('/stats', getAdminStats);
router.get('/dashboard', getDashboardData);
router.get('/users/activity', getUsersActivity);
router.get('/surveys/stats', getSurveyCompletionStats);

module.exports = router;
