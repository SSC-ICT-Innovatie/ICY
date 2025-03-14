const User = require('../models/userModel');
const asyncHandler = require('../middleware/asyncMiddleware');
const { createError } = require('../utils/errorUtils');

// @desc    Get all users
// @route   GET /api/v1/users
// @access  Private/Admin
const getUsers = asyncHandler(async (req, res) => {
  const users = await User.find();
  
  res.status(200).json({
    success: true,
    count: users.length,
    data: users
  });
});

// @desc    Get user by ID
// @route   GET /api/v1/users/:id
// @access  Private/Admin
const getUserById = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  
  if (!user) {
    throw createError(404, `User with id ${req.params.id} not found`);
  }
  
  res.status(200).json({
    success: true,
    data: user
  });
});

// @desc    Update user profile
// @route   PUT /api/v1/users/:id
// @access  Private/Admin
const updateUser = asyncHandler(async (req, res) => {
  // Check if user exists
  const user = await User.findById(req.params.id);
  
  if (!user) {
    throw createError(404, `User with id ${req.params.id} not found`);
  }

  // Make sure only admins can update other users
  if (req.user.role !== 'admin' && req.user._id.toString() !== req.params.id) {
    throw createError(403, 'Not authorized to update this user');
  }

  // Don't allow role changes unless admin
  if (req.body.role && req.user.role !== 'admin') {
    throw createError(403, 'Not authorized to change role');
  }

  // Update user
  const updatedUser = await User.findByIdAndUpdate(
    req.params.id,
    req.body,
    {
      new: true,
      runValidators: true
    }
  );
  
  res.status(200).json({
    success: true,
    data: updatedUser
  });
});

// @desc    Update user preferences
// @route   PUT /api/v1/users/preferences
// @access  Private
const updatePreferences = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  
  if (!user) {
    throw createError(404, 'User not found');
  }

  // Only update preference fields
  const { notifications, dailyReminderTime, language, theme } = req.body;
  
  user.preferences = {
    ...user.preferences,
    ...(notifications !== undefined && { notifications }),
    ...(dailyReminderTime !== undefined && { dailyReminderTime }),
    ...(language !== undefined && { language }),
    ...(theme !== undefined && { theme })
  };

  await user.save();
  
  res.status(200).json({
    success: true,
    data: user.preferences
  });
});

// @desc    Get user stats
// @route   GET /api/v1/users/stats
// @access  Private
const getUserStats = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  
  if (!user) {
    throw createError(404, 'User not found');
  }
  
  res.status(200).json({
    success: true,
    data: {
      level: user.level,
      stats: user.stats
    }
  });
});

module.exports = {
  getUsers,
  getUserById,
  updateUser,
  updatePreferences,
  getUserStats
};
