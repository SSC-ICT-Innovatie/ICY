const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const { createError } = require('../utils/errorUtils');
const asyncHandler = require('./asyncMiddleware');
const logger = require('../utils/logger');

// Protect routes - authentication middleware
exports.protect = asyncHandler(async (req, res, next) => {
  let token;

  // Check for Bearer token in the Authorization header
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      // Get token from header
      token = req.headers.authorization.split(' ')[1];

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET || "k8HV2p9Y$7ZWXuNdR4cMbPeS5gF#jQn@L6aTsD3vG1yE0hKiB^mAoJzIxUqOwf");

      // Get user from the token
      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        throw createError(401, 'User not found');
      }

      next();
    } catch (error) {
      // Improved error logging with token debugging
      const tokenPreview = token ? `${token.substring(0, 8)}...` : 'none';
      logger.error(`Auth Error (${error.name}): ${error.message}, Token preview: ${tokenPreview}, URL: ${req.originalUrl}`);
      
      // Create a specific error based on the error type
      if (error.name === 'JsonWebTokenError') {
        return next(createError(401, 'Invalid token'));
      } else if (error.name === 'TokenExpiredError') {
        return next(createError(401, 'Token expired'));
      } else {
        return next(createError(401, 'Not authorized to access this route'));
      }
    }
  } else {
    // If in development mode and ALLOW_OPEN_ACCESS is set, bypass auth for testing
    if (process.env.NODE_ENV === 'development' && process.env.ALLOW_OPEN_ACCESS === 'true') {
      logger.warn(`⚠️ BYPASSING AUTH for ${req.method} ${req.originalUrl} - ONLY FOR DEVELOPMENT`);
      // Set a default user for testing
      req.user = { 
        _id: '000000000000000000000001',
        email: 'test@example.com',
        username: 'testuser',
        role: 'user'
      };
      return next();
    }
    
    // No token found
    logger.error(`Not authorized - No token provided - ${req.originalUrl} - ${req.method} - ${req.ip}`);
    return next(createError(401, 'Not authorized, no token'));
  }
});

// Role-based authorization middleware
exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(createError(403, `Role '${req.user?.role}' is not authorized to access this route`));
    }
    next();
  };
};
