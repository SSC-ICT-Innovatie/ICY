const asyncHandler = require('../middleware/asyncMiddleware');
const User = require('../models/userModel');
const { createError } = require('../utils/errorUtils');
const { v4: uuidv4 } = require('uuid');

// @desc    Get user notifications
// @route   GET /api/v1/notifications
// @access  Private
exports.getUserNotifications = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  
  if (!user) {
    throw createError(404, 'User not found');
  }
  
  res.status(200).json({
    success: true,
    count: user.notifications.length,
    data: user.notifications.sort((a, b) => b.createdAt - a.createdAt)
  });
});

// @desc    Mark notification as read
// @route   PUT /api/v1/notifications/:id/read
// @access  Private
exports.markNotificationAsRead = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  
  if (!user) {
    throw createError(404, 'User not found');
  }
  
  const notification = user.notifications.id(req.params.id);
  
  if (!notification) {
    throw createError(404, 'Notification not found');
  }
  
  notification.isRead = true;
  await user.save();
  
  res.status(200).json({
    success: true,
    data: notification
  });
});

// @desc    Clear all notifications
// @route   DELETE /api/v1/notifications
// @access  Private
exports.clearAllNotifications = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  
  if (!user) {
    throw createError(404, 'User not found');
  }
  
  user.notifications = [];
  await user.save();
  
  res.status(200).json({
    success: true,
    data: {}
  });
});

// @desc    Create notification for a user
// @route   POST /api/v1/notifications/create
// @access  Admin
exports.createNotification = asyncHandler(async (req, res) => {
  const { userId, title, body, type, actionId, actionUrl } = req.body;
  
  if (!userId || !title || !body) {
    throw createError(400, 'Please provide userId, title and body');
  }
  
  const user = await User.findById(userId);
  
  if (!user) {
    throw createError(404, 'User not found');
  }
  
  const notification = {
    id: uuidv4(),
    title,
    body,
    type: type || 'general',
    isRead: false,
    createdAt: new Date(),
    actionId,
    actionUrl: actionUrl || '/'
  };
  
  user.notifications.push(notification);
  await user.save();
  
  res.status(201).json({
    success: true,
    data: notification
  });
});
