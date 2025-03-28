const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true,
    select: false
  },
  fullName: {
    type: String,
    required: true
  },
  avatar: {
    type: String,
    default: 'https://placehold.co/400x400?text=User'
  },
  department: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['user', 'team_lead', 'admin'],
    default: 'user'
  },
  level: {
    current: {
      type: Number,
      default: 1
    },
    title: {
      type: String,
      default: 'Enquête Beginner'
    },
    xp: {
      current: {
        type: Number,
        default: 0
      },
      nextLevel: {
        type: Number,
        default: 300
      }
    }
  },
  stats: {
    surveysCompleted: {
      type: Number,
      default: 0
    },
    streak: {
      current: {
        type: Number,
        default: 0
      },
      best: {
        type: Number,
        default: 0
      }
    },
    totalXp: {
      type: Number,
      default: 0
    },
    participationRate: {
      type: Number,
      default: 0
    },
    averageResponseTime: {
      type: Number,
      default: 0
    },
    totalCoins: {
      type: Number,
      default: 0
    }
  },
  preferences: {
    notifications: {
      type: Boolean,
      default: true
    },
    dailyReminderTime: {
      type: String,
      default: '09:00'
    },
    language: {
      type: String,
      default: 'nl'
    },
    theme: {
      type: String,
      default: 'light'
    }
  },
  notifications: [{
    id: {
      type: String,
      required: true
    },
    title: {
      type: String,
      required: true
    },
    body: {
      type: String,
      required: true
    },
    type: {
      type: String,
      enum: ['survey', 'achievement', 'team', 'general'],
      default: 'general'
    },
    isRead: {
      type: Boolean,
      default: false
    },
    createdAt: {
      type: Date,
      default: Date.now
    },
    actionId: String,
    actionUrl: {
      type: String,
      default: '/'
    }
  }],
  refreshToken: String,
  passwordResetToken: String,
  passwordResetExpires: Date,
}, {
  timestamps: true
});

// Method to compare passwords
userSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Encrypt password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) {
    next();
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

const User = mongoose.model('User', userSchema);
module.exports = User;
