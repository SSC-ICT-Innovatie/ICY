const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose'); // Add this import
const User = require('../models/userModel');
const VerificationCode = require('../models/verificationCodeModel');
const asyncHandler = require('../middleware/asyncMiddleware');
const { createError } = require('../utils/errorUtils');
const emailUtils = require('../utils/emailUtils');
const logger = require('../utils/logger');

// @desc    Login user
// @route   POST /api/v1/auth/login
// @access  Public
const login = asyncHandler(async (req, res, next) => {
  const { email, password } = req.body;

  // Validate email & password
  if (!email || !password) {
    return next(createError(400, 'Please provide email and password'));
  }

  // Check for user
  const user = await User.findOne({ email }).select('+password');
  if (!user) {
    return next(createError(401, 'Invalid email or password'));
  }

  // Check if password matches
  const isMatch = await user.matchPassword(password);
  if (!isMatch) {
    return next(createError(401, 'Invalid email or password'));
  }

  // Create token
  const token = jwt.sign(
    { id: user._id },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRY }
  );

  // Create refresh token
  const refreshToken = jwt.sign(
    { id: user._id },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRY }
  );

  // Save refresh token to user
  user.refreshToken = refreshToken;
  await user.save();

  // Return token
  res.status(200).json({
    success: true,
    message: 'Login successful',
    token,
    refreshToken,
    user
  });
});

// @desc    Register new user
// @route   POST /api/v1/auth/register
// @access  Public
const register = asyncHandler(async (req, res, next) => {
  const { fullName, email, password, department, verificationCode } = req.body;

  // Validate required fields
  if (!fullName || !email || !password) {
    return next(createError(400, 'Please provide all required fields'));
  }

  // Check if verification code is required and valid
  if (process.env.REQUIRE_EMAIL_VERIFICATION === 'true') {
    if (!verificationCode) {
      return next(createError(400, 'Email verification code is required'));
    }

    // Verify the code
    const codeDoc = await VerificationCode.findOne({ email });
    if (!codeDoc || codeDoc.code !== verificationCode) {
      return next(createError(400, 'Invalid or expired verification code'));
    }
  }

  // Check if user already exists
  const userExists = await User.findOne({ email });
  if (userExists) {
    return next(createError(400, 'User with this email already exists'));
  }

  // Generate a username from email if not provided
  const username = req.body.username || email.split('@')[0];

  // Create user
  const user = await User.create({
    fullName,
    username,
    email,
    password,
    department,
    avatar: req.body.avatar || `https://ui-avatars.com/api/?name=${encodeURIComponent(fullName)}&background=random`,
  });

  // Create token
  const token = jwt.sign(
    { id: user._id },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRY }
  );

  // Create refresh token
  const refreshToken = jwt.sign(
    { id: user._id },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRY }
  );

  // Save refresh token to user
  user.refreshToken = refreshToken;
  await user.save();

  // Clean up the verification code if it was used
  if (codeDoc) {
    await VerificationCode.deleteOne({ _id: codeDoc._id });
  }

  // Return token
  res.status(201).json({
    success: true,
    message: 'Registration successful',
    token,
    refreshToken,
    user
  });
});

// @desc    Logout user / clear cookie
// @route   POST /api/v1/auth/logout
// @access  Private
const logout = asyncHandler(async (req, res, next) => {
  // Clear refresh token from user
  if (req.user) {
    req.user.refreshToken = undefined;
    await req.user.save();
  }

  res.status(200).json({
    success: true,
    message: 'Logged out successfully',
    data: {}
  });
});

// @desc    Refresh token
// @route   POST /api/v1/auth/refresh-token
// @access  Public
const refreshToken = asyncHandler(async (req, res, next) => {
  const { refreshToken: token } = req.body;

  if (!token) {
    return next(createError(400, 'Please provide refresh token'));
  }

  try {
    // Verify refresh token
    const decoded = jwt.verify(token, process.env.REFRESH_TOKEN_SECRET);

    // Get user from refresh token
    const user = await User.findById(decoded.id);
    if (!user) {
      return next(createError(401, 'Invalid refresh token'));
    }

    // Check if refresh token matches
    if (user.refreshToken !== token) {
      return next(createError(401, 'Invalid refresh token'));
    }

    // Create new token
    const newToken = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRY }
    );

    // Return new token
    res.status(200).json({
      success: true,
      token: newToken
    });
  } catch (err) {
    return next(createError(401, 'Invalid refresh token'));
  }
});

// @desc    Get current user
// @route   GET /api/v1/auth/me
// @access  Private
const getCurrentUser = asyncHandler(async (req, res, next) => {
  const user = await User.findById(req.user.id);
  
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

  if (!email) {
    return next(createError(400, 'Please provide an email address'));
  }

  // Development mode handling for simplified testing
  if (process.env.NODE_ENV === 'development') {
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Log code in development mode
    logger.info(`[DEV MODE] Generated verification code for ${email}: ${code}`);
    
    try {
      // Still try to check if user exists in database
      const userExists = await User.findOne({ email });
      if (userExists) {
        return next(createError(400, 'User with this email already exists'));
      }
      
      // Try to save code to database
      try {
        // Set expiration time (10 minutes from now)
        const expiresAt = new Date();
        expiresAt.setMinutes(expiresAt.getMinutes() + 10);
        
        await VerificationCode.findOneAndUpdate(
          { email },
          { code, expiresAt },
          { upsert: true, new: true }
        );
      } catch (dbError) {
        logger.warn(`[DEV MODE] Could not save verification code to database: ${dbError.message}`);
        // Continue even if DB save fails in development
      }
      
      // Skip actual email sending in development
      return res.status(200).json({
        success: true,
        message: 'Verification code sent to email',
        devCode: code // Only in development mode, return code directly
      });
    } catch (error) {
      // If database check fails, still return a code in development
      logger.warn(`[DEV MODE] Database check failed, but still returning code: ${code}`);
      return res.status(200).json({
        success: true,
        message: 'Verification code sent to email (database unavailable)',
        devCode: code
      });
    }
  }

  // For production or when DB is connected, proceed with normal flow
  try {
    // Check if user already exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return next(createError(400, 'User with this email already exists'));
    }

    // Generate 6-digit code
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Set expiration time (10 minutes from now)
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 10);

    // Save code to database
    await VerificationCode.findOneAndUpdate(
      { email },
      { 
        code,
        expiresAt
      },
      { upsert: true, new: true }
    );

    // Send email with code
    try {
      await emailUtils.sendEmail({
        to: email,
        subject: 'Your ICY Email Verification Code',
        text: `Your verification code is: ${code}\nThis code will expire in 10 minutes.`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2>Email Verification</h2>
            <p>Please use the following code to verify your email address:</p>
            <div style="background-color: #f5f5f5; padding: 20px; text-align: center; font-size: 24px; letter-spacing: 5px; font-weight: bold;">
              ${code}
            </div>
            <p>This code will expire in 10 minutes.</p>
            <p>If you didn't request this code, you can safely ignore this email.</p>
          </div>
        `
      });

      res.status(200).json({
        success: true,
        message: 'Verification code sent to email'
      });
    } catch (error) {
      return next(createError(500, 'Failed to send verification code'));
    }
  } catch (error) {
    return next(error);
  }
});

// @desc    Verify email code
// @route   POST /api/v1/auth/verify-email-code
// @access  Public
const verifyEmailCode = asyncHandler(async (req, res, next) => {
  const { email, code } = req.body;

  if (!email || !code) {
    return next(createError(400, 'Please provide email and verification code'));
  }

  // Special handling for development mode
  if (process.env.NODE_ENV === 'development') {
    logger.info(`[DEV MODE] Verification code ${code} for ${email} is considered valid`);
    
    // In development, we always return success
    return res.status(200).json({
      success: true,
      message: 'Email verified successfully'
    });
  }

  // For production, do the normal flow
  try {
    // Find the verification code
    const verificationCode = await VerificationCode.findOne({ 
      email,
      expiresAt: { $gt: new Date() }
    });

    if (!verificationCode || verificationCode.code !== code) {
      return next(createError(400, 'Invalid or expired verification code'));
    }

    res.status(200).json({
      success: true,
      message: 'Email verified successfully'
    });
  } catch (error) {
    return next(error);
  }
});

// @desc    Forgot password
// @route   POST /api/v1/auth/forgot-password
// @access  Public
const forgotPassword = asyncHandler(async (req, res, next) => {
  const { email } = req.body;

  if (!email) {
    return next(createError(400, 'Please provide an email address'));
  }

  // Find user
  const user = await User.findOne({ email });
  if (!user) {
    return next(createError(404, 'No user with that email'));
  }

  // Generate reset token
  const resetToken = crypto.randomBytes(20).toString('hex');

  // Hash token and set to resetPasswordToken field
  user.resetPasswordToken = crypto
    .createHash('sha256')
    .update(resetToken)
    .digest('hex');

  // Set expire (10 minutes)
  user.resetPasswordExpire = Date.now() + 10 * 60 * 1000;

  await user.save();

  // Create reset URL
  const resetUrl = `${req.protocol}://${req.get(
    'host'
  )}/api/v1/auth/reset-password/${resetToken}`;

  const message = `You are receiving this email because you (or someone else) has requested the reset of a password. Please click on the following link or paste it into your browser to complete the process:\n\n${resetUrl}`;

  try {
    await emailUtils.sendEmail({
      to: user.email,
      subject: 'Password Reset Token',
      text: message
    });

    res.status(200).json({
      success: true,
      message: 'Email sent'
    });
  } catch (err) {
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;

    await user.save();

    return next(createError(500, 'Email could not be sent'));
  }
});

// @desc    Reset password
// @route   PUT /api/v1/auth/reset-password/:resettoken
// @access  Public
const resetPassword = asyncHandler(async (req, res, next) => {
  // Get hashed token
  const resetPasswordToken = crypto
    .createHash('sha256')
    .update(req.params.resettoken)
    .digest('hex');

  const user = await User.findOne({
    resetPasswordToken,
    resetPasswordExpire: { $gt: Date.now() }
  });

  if (!user) {
    return next(createError(400, 'Invalid token'));
  }

  // Set new password
  user.password = req.body.password;
  user.resetPasswordToken = undefined;
  user.resetPasswordExpire = undefined;
  await user.save();

  res.status(200).json({
    success: true,
    message: 'Password reset successful'
  });
});

// Export the controller functions
module.exports = {
  login,
  register,
  logout,
  refreshToken,
  getCurrentUser,
  requestVerificationCode,
  verifyEmailCode,
  forgotPassword,
  resetPassword
};
