const mongoose = require('mongoose');

const badgeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  icon: {
    type: String,
    required: true
  },
  color: {
    type: String,
    required: true
  },
  xpReward: {
    type: Number,
    required: true
  },
  conditions: {
    type: mongoose.Schema.Types.Mixed,
    required: true
  }
}, {
  timestamps: true
});

const challengeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  icon: {
    type: String,
    required: true
  },
  color: {
    type: String,
    required: true
  },
  reward: {
    xp: {
      type: Number,
      required: true
    },
    coins: {
      type: Number,
      required: true
    },
    badge: {
      type: String
    }
  },
  conditions: {
    type: mongoose.Schema.Types.Mixed,
    required: true
  },
  repeatable: {
    type: Boolean,
    default: false
  },
  cooldownDays: {
    type: Number
  },
  startDate: {
    type: Date
  },
  endDate: {
    type: Date
  },
  active: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

const challengeScheduleSchema = new mongoose.Schema({
  challengeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Challenge',
    required: true
  },
  startDate: {
    type: Date,
    required: true
  },
  endDate: {
    type: Date,
    required: true
  }
}, {
  timestamps: true
});

const achievementSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  reward: {
    type: String,
    required: true
  },
  icon: {
    type: String,
    required: true
  },
  color: {
    type: String,
    required: true
  },
  type: {
    type: String,
    required: true
  }
}, {
  timestamps: true
});

const userAchievementSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  achievementId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Achievement',
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

const userBadgeSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  badgeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Badge',
    required: true
  },
  dateEarned: {
    type: Date,
    default: Date.now
  },
  xpAwarded: {
    type: Number,
    required: true
  }
}, {
  timestamps: true
});

const userBadgeProgressSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  badgeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Badge',
    required: true
  },
  progress: {
    type: Number,
    required: true
  },
  current: {
    type: Number
  }
}, {
  timestamps: true
});

const Badge = mongoose.model('Badge', badgeSchema);
const Challenge = mongoose.model('Challenge', challengeSchema);
const ChallengeSchedule = mongoose.model('ChallengeSchedule', challengeScheduleSchema);
const Achievement = mongoose.model('Achievement', achievementSchema);
const UserAchievement = mongoose.model('UserAchievement', userAchievementSchema);
const UserBadge = mongoose.model('UserBadge', userBadgeSchema);
const UserBadgeProgress = mongoose.model('UserBadgeProgress', userBadgeProgressSchema);

module.exports = {
  Badge,
  Challenge,
  ChallengeSchedule,
  Achievement,
  UserAchievement,
  UserBadge,
  UserBadgeProgress
};
