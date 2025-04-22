const { Survey, SurveyResponse, UserProgress } = require('../models/surveyModel');
const User = require('../models/userModel');
const asyncHandler = require('../middleware/asyncMiddleware');
const { createError } = require('../utils/errorUtils');

// @desc    Create a new survey
// @route   POST /api/v1/surveys
// @access  Admin
const createSurvey = asyncHandler(async (req, res) => {
  const {
    title,
    description,
    questions,
    estimatedTime,
    reward,
    expiresAt,
    tags,
    targetDepartments
  } = req.body;

  // Validate required fields
  if (!title || !description || !questions || !estimatedTime || !reward || !expiresAt) {
    throw createError(400, 'Please provide all required fields');
  }

  // Ensure questions is an array
  if (!Array.isArray(questions) || questions.length === 0) {
    throw createError(400, 'Please provide at least one question');
  }

  // Create survey
  const survey = await Survey.create({
    title,
    description,
    questions,
    estimatedTime,
    reward,
    expiresAt: new Date(expiresAt),
    tags: tags || [],
    targetDepartments: targetDepartments || ['all'],
    createdAt: new Date()
  });

  res.status(201).json({
    success: true,
    data: survey,
    message: `Survey "${title}" created successfully`
  });
});

const getSurveys = asyncHandler(async (req, res) => {
  const now = new Date();
  const surveys = await Survey.find({
    archived: false,
    expiresAt: { $gt: now }
  }).sort({ createdAt: -1 });
  
  const filteredSurveys = req.query.department
    ? surveys.filter(survey => 
        survey.targetDepartments.includes('all') || 
        survey.targetDepartments.includes(req.query.department))
    : surveys;

  res.status(200).json({
    success: true,
    count: filteredSurveys.length,
    data: filteredSurveys
  });
});

const getDailySurveys = asyncHandler(async (req, res) => {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const tomorrow = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
  
  const surveys = await Survey.find({
    archived: false,
    tags: 'dagelijks',
    expiresAt: { 
      $gte: today,
      $lt: tomorrow
    }
  });

  const userResponses = await SurveyResponse.find({
    userId: req.user._id,
    completedAt: { 
      $gte: today,
      $lt: tomorrow
    }
  });

  const completedSurveyIds = userResponses.map(response => 
    response.surveyId.toString()
  );
  
  const availableSurveys = surveys.filter(
    survey => !completedSurveyIds.includes(survey._id.toString())
  );

  res.status(200).json({
    success: true,
    count: availableSurveys.length,
    data: availableSurveys
  });
});

const getSurveyById = asyncHandler(async (req, res) => {
  const survey = await Survey.findById(req.params.id);
  
  if (!survey) {
    throw createError(404, `Survey with id ${req.params.id} not found`);
  }
  
  const userProgress = await UserProgress.findOne({
    userId: req.user._id,
    surveyId: req.params.id
  });

  res.status(200).json({
    success: true,
    data: {
      survey,
      progress: userProgress || null
    }
  });
});

const submitSurveyResponse = asyncHandler(async (req, res) => {
  const { answers } = req.body;
  const survey = await Survey.findById(req.params.id);
  
  if (!survey) {
    throw createError(404, `Survey with id ${req.params.id} not found`);
  }
  
  if (new Date(survey.expiresAt) < new Date()) {
    throw createError(400, 'Survey has expired');
  }
  
  const existingResponse = await SurveyResponse.findOne({
    userId: req.user._id,
    surveyId: req.params.id
  });
  
  if (existingResponse) {
    throw createError(400, 'You have already completed this survey');
  }
  
  const response = await SurveyResponse.create({
    surveyId: req.params.id,
    userId: req.user._id,
    answers
  });
  
  const user = await User.findById(req.user._id);
  
  if (user) {
    // Update surveys completed
    user.stats.surveysCompleted += 1;
    
    // Award XP and coins
    user.stats.totalXp += survey.reward.xp;
    user.stats.totalCoins += survey.reward.coins;
    
    // Update streak
    const lastMidnight = new Date();
    lastMidnight.setHours(0, 0, 0, 0);
    
    const yesterdayStart = new Date(lastMidnight);
    yesterdayStart.setDate(yesterdayStart.getDate() - 1);
    
    const yesterdayEnd = new Date(lastMidnight);
    
    const yesterdayResponse = await SurveyResponse.findOne({
      userId: req.user._id,
      completedAt: { 
        $gte: yesterdayStart,
        $lt: yesterdayEnd
      }
    });
    
    if (yesterdayResponse) {
      user.stats.streak.current += 1;
      
      if (user.stats.streak.current > user.stats.streak.best) {
        user.stats.streak.best = user.stats.streak.current;
      }
    } else {
      user.stats.streak.current = 1;
    }
    
    // Calculate participation rate
    const totalSurveys = await Survey.countDocuments();
    const totalResponses = await SurveyResponse.countDocuments({ 
      userId: req.user._id 
    });
    
    user.stats.participationRate = totalResponses / totalSurveys;
    
    // Update user XP and total XP stats
    if (survey.reward && survey.reward.xp) {
      user.level.xp.current += survey.reward.xp;
      user.stats.totalXp += survey.reward.xp;
      
      // Check if user should level up
      if (user.level.xp.current >= user.level.xp.nextLevel) {
        user.level.current += 1;
        user.level.xp.current = user.level.xp.current - user.level.xp.nextLevel;
        user.level.xp.nextLevel = Math.floor(user.level.xp.nextLevel * 1.5); // Increase XP needed for next level
      }
    }
    
    // Update coins if reward includes coins
    if (survey.reward && survey.reward.coins) {
      user.stats.totalCoins += survey.reward.coins;
    }
    
    await user.save();
  }
  
  res.status(201).json({
    success: true,
    data: response,
    rewards: {
      xp: survey.reward.xp,
      coins: survey.reward.coins
    }
  });
});

const updateSurveyProgress = asyncHandler(async (req, res) => {
  const { answers, completed } = req.body;
  const survey = await Survey.findById(req.params.id);
  
  if (!survey) {
    throw createError(404, `Survey with id ${req.params.id} not found`);
  }
  
  let userProgress = await UserProgress.findOne({
    userId: req.user._id,
    surveyId: req.params.id
  });
  
  if (userProgress) {
    userProgress.answers = answers;
    userProgress.completed = completed;
    userProgress.lastUpdated = Date.now();
    await userProgress.save();
  } else {
    userProgress = await UserProgress.create({
      userId: req.user._id,
      surveyId: req.params.id,
      completed,
      totalQuestions: survey.questions.length,
      answers
    });
  }
  
  res.status(200).json({
    success: true,
    data: userProgress
  });
});

module.exports = {
  getSurveys,
  getDailySurveys,
  getSurveyById,
  createSurvey, // Add the new function to exports
  submitSurveyResponse,
  updateSurveyProgress
};
