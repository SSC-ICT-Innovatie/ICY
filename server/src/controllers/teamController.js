const { Team, League, TeamStats, Leaderboard } = require('../models/teamModel');
const User = require('../models/userModel');
const asyncHandler = require('../middleware/asyncMiddleware');
const { createError } = require('../utils/errorUtils');

const getTeams = asyncHandler(async (req, res) => {
  const teams = await Team.find()
    .populate('leader', 'fullName username avatar')
    .populate('members', 'fullName username avatar');
  
  res.status(200).json({
    success: true,
    count: teams.length,
    data: teams
  });
});

const getTeamById = asyncHandler(async (req, res) => {
  const team = await Team.findById(req.params.id)
    .populate('leader', 'fullName username avatar email')
    .populate('members', 'fullName username avatar email');
  
  if (!team) {
    throw createError(404, `Team with id ${req.params.id} not found`);
  }
  
  const teamStats = await TeamStats.findOne({ teamId: team._id });
  
  res.status(200).json({
    success: true,
    data: {
      team,
      stats: teamStats
    }
  });
});

const getUserTeam = asyncHandler(async (req, res) => {
  const teams = await Team.find({
    $or: [
      { leader: req.user._id },
      { members: req.user._id }
    ]
  })
  .populate('leader', 'fullName username avatar')
  .populate('members', 'fullName username avatar');
  
  if (!teams || teams.length === 0) {
    return res.status(200).json({
      success: true,
      data: null
    });
  }
  
  const team = teams[0]; // Assuming a user belongs to only one team
  const teamStats = await TeamStats.findOne({ teamId: team._id });
  
  res.status(200).json({
    success: true,
    data: {
      team,
      stats: teamStats
    }
  });
});

const getLeaderboard = asyncHandler(async (req, res) => {
  const leaderboard = await Leaderboard.findOne();
  
  if (!leaderboard) {
    throw createError(404, 'Leaderboard not found');
  }
  
  res.status(200).json({
    success: true,
    data: leaderboard
  });
});

const getLeagues = asyncHandler(async (req, res) => {
  const leagues = await League.find();
  
  res.status(200).json({
    success: true,
    count: leagues.length,
    data: leagues
  });
});

module.exports = {
  getTeams,
  getTeamById,
  getUserTeam,
  getLeaderboard,
  getLeagues
};
