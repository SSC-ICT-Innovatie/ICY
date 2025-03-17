const mongoose = require('mongoose');

const verificationCodeSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true
  },
  code: {
    type: String, 
    required: true
  },
  expiresAt: {
    type: Date,
    required: true,
    index: { expires: 0 } 
  }
}, {
  timestamps: true
});

const VerificationCode = mongoose.model('VerificationCode', verificationCodeSchema);

module.exports = VerificationCode;
