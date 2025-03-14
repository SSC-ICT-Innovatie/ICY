const { 
  Badge, 
  Challenge, 
  Achievement,
  UserAchievement,
  UserBadge,
  UserBadgeProgress
} = require('../models/achievementModel');
const asyncHandler = require('../middleware/asyncMiddleware');
const { createError } = require('../utils/errorUtils');

const getBadges = asyncHandler(async (req, res) => {
  const badges = await Badge.find();
  
  res.status(200).json({
    success: true,
    count: badges.length,
    data: badges
  });
});

const getUserBadges = asyncHandler(async (req, res) => {
  const earnedBadges = await UserBadge.find({ userId: req.user._id })
    .populate('badgeId');
  
  const inProgressBadges = await UserBadgeProgress.find({ userId: req.user._id })
    .populate('badgeId');
  
  res.status(200).json({
    success: true,
    data: {
      earned: earnedBadges,
      inProgress: inProgressBadges
    }
  });
});

const getActiveChallenges = asyncHandler(async (req, res) => {
  const now = new Date();
  
  const challenges = await Challenge.find({
    active: true,
    $or: [
      { startDate: { $exists: false } },
      { startDate: { $lte: now } }
    ],
    $or: [
      { endDate: { $exists: false } },
      { endDate: { $gte: now } }
    ]
  });
  
  res.status(200).json({
    success: true,
    count: challenges.length,
    data: challenges
  });
});

const getUserAchievements = asyncHandler(async (req, res) => {
  const userAchievements = await UserAchievement.find({ userId: req.user._id })
    .populate('achievementId')
    .sort({ timestamp: -1 });
  
  res.status(200).json({
    success: true,
    count: userAchievements.length,
    data: userAchievements
  });
});

const getRecentAchievements = asyncHandler(async (req, res) => {
  const oneWeekAgo = new Date();
  oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
  
  const recentAchievements = await UserAchievement.find({ 
    userId: req.user._id,
    timestamp: { $gte: oneWeekAgo }
  })
  .populate('achievementId')
  .sort({ timestamp: -1 });
  
  res.status(200).json({
    success: true,
    count: recentAchievements.length,
    data: recentAchievements
  });
});

module.exports = {
  getBadges,
  getUserBadges,
  getActiveChallenges,
  getUserAchievements,
  getRecentAchievements
};
