const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const VerificationCode = require('../models/verificationCodeModel');
const asyncHandler = require('../middleware/asyncMiddleware');
const { createError } = require('../utils/errorUtils');
const crypto = require('crypto');
const { sendEmail } = require('../utils/emailUtils');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Generate JWT token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRY
  });
};

// Generate refresh token
const generateRefreshToken = (id) => {
  return jwt.sign({ id }, process.env.REFRESH_TOKEN_SECRET, {
    expiresIn: process.env.REFRESH_TOKEN_EXPIRY
  });
};

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    const uploadDir = path.join(__dirname, '../../uploads/avatars');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function(req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max file size
  },
  fileFilter: function(req, file, cb) {
    // Accept only image files
    if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
      return cb(new Error('Only image files are allowed!'), false);
    }
    cb(null, true);
  }
});

// @desc    Login user & get token
// @route   POST /api/v1/auth/login
// @access  Public
const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  // Check for user email
  const user = await User.findOne({ email }).select('+password');

  if (!user || !(await user.matchPassword(password))) {
    throw createError(401, 'Invalid email or password');
  }

  // Check if user email is verified
  if (!user.isVerified) {
    throw createError(401, 'Email not verified. Please verify your email to continue.');
  }

  // Generate tokens
  const token = generateToken(user._id);
  const refreshToken = generateRefreshToken(user._id);
  
  // Save refresh token to DB
  user.refreshToken = refreshToken;
  await user.save();

  // Remove password from response
  user.password = undefined;
  
  res.status(200).json({
    success: true,
    token,
    refreshToken,
    user
  });
});

// @desc    Register a new user
// @route   POST /api/v1/auth/register
// @access  Public
const register = asyncHandler(async (req, res) => {
  const { username, email, password, fullName, department, avatarId, verificationCode } = req.body;

  // Check if user already exists
  const userExists = await User.findOne({ email });

  if (userExists) {
    throw createError(400, 'User with this email already exists');
  }

  // Verify the email code if verification system is enabled
  if (process.env.EMAIL_VERIFICATION_REQUIRED === 'true') {
    // First verify the email code
    if (!verificationCode) {
      throw createError(400, 'Verification code is required');
    }
    
    const hashedCode = crypto.createHash('sha256').update(verificationCode).digest('hex');
    const verificationRecord = await VerificationCode.findOne({ email });
    
    if (!verificationRecord || verificationRecord.code !== hashedCode || verificationRecord.expiresAt < new Date()) {
      throw createError(400, 'Invalid or expired verification code');
    }
  }

  // Set profile image path if an avatar was uploaded
  let avatarPath = null;
  if (req.file) {
    avatarPath = `/uploads/avatars/${req.file.filename}`;
  }

  // Create user
  const user = await User.create({
    username: username || email.split('@')[0],
    email,
    password,
    fullName,
    department,
    avatar: avatarPath || `/default/avatar-${Math.floor(Math.random() * 10)}.png`,
    isVerified: true // Set to true since we've verified the email
  });

  if (user) {
    // Generate tokens
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);
    
    // Save refresh token
    user.refreshToken = refreshToken;
    await user.save();
    
    // Remove password from response
    user.password = undefined;

    // If there was a verification record, delete it
    if (process.env.EMAIL_VERIFICATION_REQUIRED === 'true') {
      await VerificationCode.deleteOne({ email });
    }

    res.status(201).json({
      success: true,
      token,
      refreshToken,
      user
    });
  } else {
    throw createError(400, 'Invalid user data');
  }
});

// @desc    Refresh access token
// @route   POST /api/v1/auth/refresh-token
// @access  Public
const refreshToken = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  
  if (!refreshToken) {
    throw createError(401, 'No refresh token provided');
  }

  try {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
    
    // Check if user exists and token matches
    const user = await User.findById(decoded.id);
    
    if (!user || user.refreshToken !== refreshToken) {
      throw createError(401, 'Invalid refresh token');
    }
    
    // Generate new access token
    const newToken = generateToken(user._id);
    
    res.status(200).json({
      success: true,
      token: newToken
    });
  } catch (error) {
    throw createError(401, 'Invalid refresh token');
  }
});

// @desc    Logout user
// @route   POST /api/v1/auth/logout
// @access  Private
const logout = asyncHandler(async (req, res) => {
  // Clear refresh token from database
  const user = await User.findById(req.user._id);
  
  if (user) {
    user.refreshToken = undefined;
    await user.save();
  }
  
  res.status(200).json({
    success: true,
    message: 'Logged out successfully'
  });
});

// @desc    Get current user profile
// @route   GET /api/v1/auth/me
// @access  Private
const getCurrentUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  
  if (!user) {
    throw createError(404, 'User not found');
  }
  
  res.status(200).json({
    success: true,
    data: user
  });
});

// @desc    Request email verification code
// @route   POST /api/v1/auth/request-verification-code
// @access  Public
const requestVerificationCode = asyncHandler(async (req, res, next) => {
  const { email } = req.body;

  // Check if email is provided
  if (!email) {
    return next(createError(400, 'Please provide email'));
  }

  // Check if user with email already exists
  const userExists = await User.findOne({ email });
  if (userExists && userExists.isVerified) {
    return next(createError(400, 'User with this email already exists'));
  }

  // Generate a random 6-digit code
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  
  // Hash the code for storage
  const hashedCode = crypto.createHash('sha256').update(code).digest('hex');

  // Set expiry to 10 minutes from now
  const expiresAt = new Date();
  expiresAt.setMinutes(expiresAt.getMinutes() + 10);

  // Store verification code
  await VerificationCode.findOneAndUpdate(
    { email },
    { code: hashedCode, expiresAt },
    { upsert: true, new: true }
  );

  // Send verification email
  try {
    await sendEmail({
      to: email,
      subject: 'Your ICY App Verification Code',
      text: `Your verification code is: ${code}. It will expire in 10 minutes.`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; text-align: center;">
          <h2>ICY App Email Verification</h2>
          <p>Thank you for registering with ICY App. Please use the following code to verify your email:</p>
          <div style="margin: 20px; padding: 10px; background-color: #f5f5f5; font-size: 24px; font-weight: bold;">
            ${code}
          </div>
          <p>This code will expire in 10 minutes.</p>
        </div>
      `
    });

    res.status(200).json({
      success: true,
      message: 'Verification code sent to email'
    });
  } catch (error) {
    return next(createError(500, 'Error sending verification email'));
  }
});

// @desc    Verify the email code
// @route   POST /api/v1/auth/verify-email-code
// @access  Public
const verifyEmailCode = asyncHandler(async (req, res, next) => {
  const { email, code } = req.body;

  // Check if email and code are provided
  if (!email || !code) {
    return next(createError(400, 'Please provide email and verification code'));
  }

  // Hash the provided code for comparison
  const hashedCode = crypto.createHash('sha256').update(code).digest('hex');

  // Find verification record
  const verificationRecord = await VerificationCode.findOne({ email });
  
  // Check if record exists
  if (!verificationRecord) {
    return next(createError(400, 'Verification code not found'));
  }

  // Check if code is correct
  if (verificationRecord.code !== hashedCode) {
    return next(createError(400, 'Invalid verification code'));
  }

  // Check if code is expired
  if (verificationRecord.expiresAt < new Date()) {
    return next(createError(400, 'Verification code expired'));
  }

  // Return success response
  res.status(200).json({
    success: true,
    message: 'Email verification successful',
    verified: true
  });
});

// Handle avatar upload
const uploadAvatar = upload.single('profileImage');

module.exports = {
  login,
  register,
  refreshToken,
  logout,
  getCurrentUser,
  requestVerificationCode,
  verifyEmailCode,
  uploadAvatar
};
