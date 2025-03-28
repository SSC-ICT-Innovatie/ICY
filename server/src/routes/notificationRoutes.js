const express = require('express');
const {
  getUserNotifications,
  markNotificationAsRead,
  clearAllNotifications,
  createNotification
} = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);

router.route('/')
  .get(getUserNotifications)
  .delete(clearAllNotifications);

router.route('/:id/read')
  .put(markNotificationAsRead);

// Admin only route
router.route('/create')
  .post(createNotification);

module.exports = router;
