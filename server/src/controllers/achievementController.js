const asyncHandler = require('../middleware/asyncMiddleware');
const { Badge, UserBadge } = require('../models/achievementModel');
const { createError } = require('../utils/errorUtils');
const logger = require('../utils/logger');

// @desc    Get all badges
// @route   GET /api/v1/achievements/badges
// @access  Private
exports.getBadges = asyncHandler(async (req, res, next) => {
  try {
    const badges = await Badge.find();
    
    res.status(200).json({
      success: true,
      count: badges.length,
      data: badges
    });
  } catch (error) {
    logger.error(`Error retrieving badges: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Get user's badges
// @route   GET /api/v1/achievements/badges/my
// @access  Private
exports.getUserBadges = asyncHandler(async (req, res, next) => {
  try {
    // Get badges earned by the user
    const earnedBadges = await UserBadge.find({ userId: req.user.id })
      .populate('badgeId');
    
    // Get all badges to determine which ones are in progress
    const allBadges = await Badge.find();
    
    // Filter out badges that user has already earned
    const earnedBadgeIds = earnedBadges.map(eb => eb.badgeId._id.toString());
    const inProgressBadges = allBadges.filter(
      badge => !earnedBadgeIds.includes(badge._id.toString())
    );
    
    // Format in-progress badges with progress info
    // In a real app, you'd calculate actual progress from user stats
    const formattedInProgress = inProgressBadges.map(badge => {
      return {
        badgeId: badge,
        progress: Math.random() // This is just a placeholder - real progress would be calculated
      };
    });
    
    res.status(200).json({
      success: true,
      data: {
        earned: earnedBadges,
        inProgress: formattedInProgress
      }
    });
  } catch (error) {
    logger.error(`Error retrieving user badges: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Get active challenges
// @route   GET /api/v1/achievements/challenges
// @access  Private
exports.getChallenges = asyncHandler(async (req, res, next) => {
  try {
    // In a real app, challenges might be a separate model
    // For now, we're just returning a subset of badges as challenges
    const challenges = await Badge.find().limit(5);
    
    res.status(200).json({
      success: true,
      count: challenges.length,
      data: challenges
    });
  } catch (error) {
    logger.error(`Error retrieving challenges: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Get recent achievements
// @route   GET /api/v1/achievements/recent
// @access  Private
exports.getRecentAchievements = asyncHandler(async (req, res, next) => {
  try {
    // Get most recently earned badges
    const recentAchievements = await UserBadge.find({ userId: req.user.id })
      .sort({ dateEarned: -1 })
      .limit(5)
      .populate('badgeId');
    
    res.status(200).json({
      success: true,
      count: recentAchievements.length,
      data: recentAchievements
    });
  } catch (error) {
    logger.error(`Error retrieving recent achievements: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Create a new badge
// @route   POST /api/v1/achievements/badges
// @access  Admin
exports.createBadge = asyncHandler(async (req, res, next) => {
  try {
    const badge = await Badge.create(req.body);
    
    res.status(201).json({
      success: true,
      data: badge
    });
  } catch (error) {
    logger.error(`Error creating badge: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Update a badge
// @route   PUT /api/v1/achievements/badges/:id
// @access  Admin
exports.updateBadge = asyncHandler(async (req, res, next) => {
  try {
    const badge = await Badge.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });
    
    if (!badge) {
      return next(createError(404, `Badge not found with id of ${req.params.id}`));
    }
    
    res.status(200).json({
      success: true,
      data: badge
    });
  } catch (error) {
    logger.error(`Error updating badge: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Delete a badge
// @route   DELETE /api/v1/achievements/badges/:id
// @access  Admin
exports.deleteBadge = asyncHandler(async (req, res, next) => {
  try {
    const badge = await Badge.findById(req.params.id);
    
    if (!badge) {
      return next(createError(404, `Badge not found with id of ${req.params.id}`));
    }
    
    await badge.deleteOne();
    
    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (error) {
    logger.error(`Error deleting badge: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Mark achievement as complete
// @route   POST /api/v1/achievements/complete/:id
// @access  Private
exports.markAchievementAsComplete = asyncHandler(async (req, res, next) => {
  try {
    const badgeId = req.params.id;
    const userId = req.user.id;
    
    // Check if badge exists
    const badge = await Badge.findById(badgeId);
    
    if (!badge) {
      return next(createError(404, `Badge not found with id of ${badgeId}`));
    }
    
    // Check if user already has this badge
    const existingBadge = await UserBadge.findOne({
      userId,
      badgeId
    });
    
    if (existingBadge) {
      return next(createError(400, 'You already have this badge'));
    }
    
    // Award the badge to user
    const userBadge = await UserBadge.create({
      userId,
      badgeId,
      dateEarned: new Date(),
      xpAwarded: badge.xpReward || 0
    });
    
    res.status(201).json({
      success: true,
      data: userBadge
    });
  } catch (error) {
    logger.error(`Error completing achievement: ${error.message}`, { error });
    return next(error);
  }
});
