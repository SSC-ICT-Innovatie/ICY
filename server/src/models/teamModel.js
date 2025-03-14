const mongoose = require('mongoose');

const teamSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  description: {
    type: String,
    required: true
  },
  department: {
    type: String,
    required: true
  },
  leader: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  members: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

const leagueSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  requiredParticipation: {
    type: Number,
    required: true
  },
  rewards: {
    xp: {
      type: Number,
      required: true
    },
    coins: {
      type: Number,
      required: true
    }
  }
}, {
  timestamps: true
});

const teamStatsSchema = new mongoose.Schema({
  teamId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Team',
    required: true
  },
  league: {
    type: String,
    required: true
  },
  rank: {
    type: Number,
    required: true
  },
  totalTeams: {
    type: Number,
    required: true
  },
  activeRate: {
    type: Number,
    required: true
  },
  goldLeagueProgress: {
    type: Number
  },
  silverLeagueProgress: {
    type: Number
  },
  averageLevel: {
    type: Number,
    required: true
  },
  totalSurveysCompleted: {
    type: Number,
    required: true
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

const leaderboardTeamSchema = new mongoose.Schema({
  teamId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Team',
    required: true
  },
  name: {
    type: String,
    required: true
  },
  score: {
    type: Number,
    required: true
  },
  surveysCompleted: {
    type: Number,
    required: true
  }
}, { _id: false });

const leaderboardPeriodSchema = new mongoose.Schema({
  startDate: {
    type: Date,
    required: true
  },
  endDate: {
    type: Date,
    required: true
  },
  teams: [leaderboardTeamSchema]
}, { _id: false });

const leaderboardSchema = new mongoose.Schema({
  currentWeek: leaderboardPeriodSchema,
  previousWeek: leaderboardPeriodSchema
}, {
  timestamps: true
});

const Team = mongoose.model('Team', teamSchema);
const League = mongoose.model('League', leagueSchema);
const TeamStats = mongoose.model('TeamStats', teamStatsSchema);
const Leaderboard = mongoose.model('Leaderboard', leaderboardSchema);

module.exports = {
  Team,
  League,
  TeamStats,
  Leaderboard
};
