const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const asyncHandler = require('../middleware/asyncMiddleware');
const { createError } = require('../utils/errorUtils');

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
  const { username, email, password, fullName, department, avatarId } = req.body;

  // Check if user already exists
  const userExists = await User.findOne({ email });

  if (userExists) {
    throw createError(400, 'User with this email already exists');
  }

  // Create user
  const user = await User.create({
    username: username || email.split('@')[0],
    email,
    password,
    fullName,
    department,
    avatar: avatarId ? `https://placehold.co/400x400?text=${encodeURIComponent(avatarId)}` : `https://placehold.co/400x400?text=${encodeURIComponent(fullName)}`
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

module.exports = {
  login,
  register,
  refreshToken,
  logout,
  getCurrentUser
};
