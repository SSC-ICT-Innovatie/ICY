const mongoose = require('mongoose');

const questionSchema = new mongoose.Schema({
  id: {
    type: String,
    required: true
  },
  text: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['rating', 'multiple_choice', 'single_choice', 'text', 'yes_no'],
    required: true
  },
  options: {
    type: Array,
    default: []
  },
  optional: {
    type: Boolean,
    default: false
  }
}, { _id: false });

const surveySchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  questions: [questionSchema],
  estimatedTime: {
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
    }
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  expiresAt: {
    type: Date,
    required: true
  },
  tags: [String],
  targetDepartments: [String],
  archived: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

const responseSchema = new mongoose.Schema({
  surveyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Survey',
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  completedAt: {
    type: Date,
    default: Date.now
  },
  answers: [{
    questionId: String,
    answer: mongoose.Schema.Types.Mixed
  }]
}, {
  timestamps: true
});

const userProgressSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  surveyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Survey',
    required: true
  },
  completed: {
    type: Number,
    default: 0
  },
  totalQuestions: {
    type: Number,
    required: true
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  },
  answers: [{
    questionId: String,
    answer: mongoose.Schema.Types.Mixed
  }]
}, {
  timestamps: true
});

const Survey = mongoose.model('Survey', surveySchema);
const SurveyResponse = mongoose.model('SurveyResponse', responseSchema);
const UserProgress = mongoose.model('UserProgress', userProgressSchema);

module.exports = {
  Survey,
  SurveyResponse,
  UserProgress
};
