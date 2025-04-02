const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const User = require('../models/userModel');
const VerificationCode = require('../models/verificationCodeModel');
const asyncHandler = require('../middleware/asyncMiddleware');
const { createError } = require('../utils/errorUtils');
const emailUtils = require('../utils/emailUtils');
const logger = require('../utils/logger');
const path = require('path');
const fs = require('fs');

// Add these token generation functions
// Generate JWT token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRY || '30d'
  });
};

// Generate refresh token
const generateRefreshToken = (id) => {
  return jwt.sign({ id }, process.env.REFRESH_TOKEN_SECRET || process.env.JWT_SECRET, {
    expiresIn: process.env.REFRESH_TOKEN_EXPIRY || '90d'
  });
};

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
  const { 
    name, 
    email, 
    password, 
    avatarId, 
    department,
    role, // Added role parameter
    verificationCode 
  } = req.body;

  // Log received data for debugging
  console.log(`Registration request received: name=${name}, email=${email}, department=${department}, role=${role || 'user'}`);

  // Check if user already exists
  const userExists = await User.findOne({ email });
  if (userExists) {
    return next(createError(400, 'User with this email already exists'));
  }

  // Only allow admin role if explicitly provided
  const userRole = role === 'admin' ? 'admin' : 'user';
  
  // Make sure department is provided (except for admins who can use 'admin' as department)
  if (!department && userRole !== 'admin') {
    return next(createError(400, 'Department is required'));
  }

  // Handle file upload if present
  let avatarUrl = null;
  if (req.files && req.files.profileImage) {
    try {
      const file = req.files.profileImage;
      const fileName = `user_${Date.now()}${path.extname(file.name)}`;
      const uploadPath = path.join(__dirname, '../../uploads/avatars', fileName);
      
      // Create directory if it doesn't exist
      if (!fs.existsSync(path.dirname(uploadPath))) {
        fs.mkdirSync(path.dirname(uploadPath), { recursive: true });
      }
      
      // Move file to upload directory
      await file.mv(uploadPath);
      
      // Set the avatar URL to be saved with the user
      avatarUrl = `/uploads/avatars/${fileName}`;
      console.log(`File uploaded successfully to ${avatarUrl}`);
    } catch (error) {
      console.error('File upload error:', error);
      return next(createError(500, 'Error uploading profile image'));
    }
  }

  // Create user with avatar if uploaded
  try {
    const user = await User.create({
      username: email.split('@')[0],
      email,
      password,
      fullName: name,
      department: department || 'admin', // Default to 'admin' for admin users
      avatarId: avatarId || '1',
      role: userRole, // Use the determined role
      // Use the uploaded avatar URL if available
      ...(avatarUrl && { avatar: avatarUrl })
    });

    // Generate tokens
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    // Set refresh token in database
    user.refreshToken = refreshToken;
    await user.save();

    // Remove password from response
    user.password = undefined;

    res.status(201).json({
      success: true,
      token,
      refreshToken,
      user
    });
  } catch (error) {
    return next(error);
  }
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
  const { refreshToken } = req.body;
  
  if (!refreshToken) {
    return next(createError(400, 'Refresh token is required'));
  }
  
  try {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET || process.env.JWT_SECRET);
    
    // Find user by ID from decoded token
    const user = await User.findById(decoded.id);
    
    if (!user) {
      return next(createError(401, 'Invalid refresh token - user not found'));
    }
    
    // Verify that the refresh token matches what's stored for the user
    if (user.refreshToken !== refreshToken) {
      return next(createError(401, 'Invalid refresh token - token mismatch'));
    }
    
    // Generate new access and refresh tokens
    const newToken = generateToken(user._id);
    const newRefreshToken = generateRefreshToken(user._id);
    
    // Save new refresh token to the user
    user.refreshToken = newRefreshToken;
    await user.save();
    
    // Send new tokens to client
    res.json({
      success: true,
      token: newToken,
      refreshToken: newRefreshToken
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return next(createError(401, 'Invalid or expired refresh token'));
    }
    next(error);
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

// @desc    Verify email verification code
// @route   POST /api/v1/auth/verify-email-code
// @access  Public
const verifyEmailCode = asyncHandler(async (req, res, next) => {
  const { email, code } = req.body;

  if (!email || !code) {
    return next(createError(400, 'Please provide email and verification code'));
  }

  try {
    // Find the verification code in database
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
  refreshToken,
  logout,
  getCurrentUser,
  requestVerificationCode,
  verifyEmailCode,
  forgotPassword,
  resetPassword,
  generateToken,
  generateRefreshToken
};
