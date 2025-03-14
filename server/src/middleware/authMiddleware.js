const jwt = require('jsonwebtoken');
const asyncHandler = require('./asyncMiddleware');
const { createError } = require('../utils/errorUtils');
const User = require('../models/userModel');

// Protect routes
const protect = asyncHandler(async (req, res, next) => {
  // Get token from header
  let token;
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  // Check if token exists
  if (!token) {
    throw createError(401, 'Not authorized to access this route');
  }

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Get user from the token
    req.user = await User.findById(decoded.id);

    if (!req.user) {
      throw createError(401, 'User not found');
    }

    next();
  } catch (error) {
    throw createError(401, 'Not authorized to access this route');
  }
});

// Grant access to specific roles
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      throw createError(
        403,
        `User role ${req.user.role} is not authorized to access this route`
      );
    }
    next();
  };
};

module.exports = { protect, authorize };
