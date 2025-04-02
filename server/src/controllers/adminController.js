const asyncHandler = require('../middleware/asyncMiddleware');
const User = require('../models/userModel');
const { Survey, SurveyResponse } = require('../models/surveyModel');
const Department = require('../models/departmentModel');
const { Team } = require('../models/teamModel');
const { createError } = require('../utils/errorUtils');
const logger = require('../utils/logger');

// @desc    Get admin dashboard statistics
// @route   GET /api/v1/admin/stats
// @access  Private/Admin
exports.getAdminStats = asyncHandler(async (req, res, next) => {
  try {
    // Get counts
    const totalUsers = await User.countDocuments();
    const totalSurveys = await Survey.countDocuments();
    const totalDepartments = await Department.countDocuments();
    
    // Calculate active users (users who have completed a survey in the last 7 days)
    const now = new Date();
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    
    const activeUsersCount = await SurveyResponse.distinct('userId', {
      completedAt: { $gte: sevenDaysAgo }
    }).then(users => users.length);
    
    // Calculate participation rate
    const totalResponses = await SurveyResponse.countDocuments();
    const participationRate = totalUsers > 0 ? 
      Math.round((activeUsersCount / totalUsers) * 100) : 0;
    
    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        totalSurveys,
        totalDepartments,
        activeUsers: activeUsersCount,
        participationRate
      }
    });
  } catch (error) {
    logger.error(`Error getting admin stats: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Get dashboard data
// @route   GET /api/v1/admin/dashboard
// @access  Private/Admin
exports.getDashboardData = asyncHandler(async (req, res, next) => {
  try {
    // Get recent users
    const recentUsers = await User.find()
      .sort({ createdAt: -1 })
      .limit(5);
    
    // Get recent surveys
    const recentSurveys = await Survey.find()
      .sort({ createdAt: -1 })
      .limit(5);
    
    // Get department distribution
    const departments = await Department.find();
    const usersPerDepartment = await Promise.all(
      departments.map(async (dept) => {
        const count = await User.countDocuments({ department: dept.name });
        return {
          name: dept.name,
          count
        };
      })
    );
    
    res.status(200).json({
      success: true,
      data: {
        recentUsers,
        recentSurveys,
        usersPerDepartment
      }
    });
  } catch (error) {
    logger.error(`Error getting dashboard data: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Get user activity stats
// @route   GET /api/v1/admin/users/activity
// @access  Private/Admin
exports.getUsersActivity = asyncHandler(async (req, res, next) => {
  try {
    const now = new Date();
    
    // Create date ranges
    const ranges = [
      {
        name: 'Today',
        start: new Date(now.getFullYear(), now.getMonth(), now.getDate()),
        end: now
      },
      {
        name: 'Last 7 days',
        start: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
        end: now
      },
      {
        name: 'Last 30 days',
        start: new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000),
        end: now
      }
    ];
    
    // Get activity stats for each range
    const activityStats = await Promise.all(
      ranges.map(async (range) => {
        const responses = await SurveyResponse.countDocuments({
          completedAt: {
            $gte: range.start,
            $lte: range.end
          }
        });
        
        const uniqueUsers = await SurveyResponse.distinct('userId', {
          completedAt: {
            $gte: range.start,
            $lte: range.end
          }
        }).then(users => users.length);
        
        return {
          ...range,
          responses,
          uniqueUsers
        };
      })
    );
    
    res.status(200).json({
      success: true,
      data: activityStats
    });
  } catch (error) {
    logger.error(`Error getting user activity stats: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Get survey completion statistics
// @route   GET /api/v1/admin/surveys/stats
// @access  Private/Admin
exports.getSurveyCompletionStats = asyncHandler(async (req, res, next) => {
  try {
    const surveys = await Survey.find();
    
    // Get completion stats for each survey
    const surveyStats = await Promise.all(
      surveys.map(async (survey) => {
        const responses = await SurveyResponse.countDocuments({
          surveyId: survey._id
        });
        
        const totalUsers = await User.countDocuments();
        const completionRate = totalUsers > 0 ? 
          Math.round((responses / totalUsers) * 100) : 0;
        
        return {
          surveyId: survey._id,
          title: survey.title,
          responses,
          completionRate
        };
      })
    );
    
    res.status(200).json({
      success: true,
      data: surveyStats
    });
  } catch (error) {
    logger.error(`Error getting survey stats: ${error.message}`, { error });
    return next(error);
  }
});
