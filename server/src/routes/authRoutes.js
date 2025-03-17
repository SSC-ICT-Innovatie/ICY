const express = require('express');
const router = express.Router();
const {
  login,
  register,
  requestVerificationCode,
  verifyEmailCode,
  uploadAvatar,
  refreshToken,
  logout,
  getCurrentUser
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');
const asyncHandler = require('express-async-handler');

// Public routes
router.post('/login', login);
router.post('/request-verification', requestVerificationCode);
router.post('/verify-email-code', verifyEmailCode);
router.post('/register', uploadAvatar, register);
router.post('/refresh-token', refreshToken);

// Protected routes
router.post('/logout', protect, logout);
router.get('/me', protect, getCurrentUser);

// Add this new route to help debug authentication
router.get('/debug-token', protect, asyncHandler(async (req, res) => {
  // Return information about the authenticated user
  res.status(200).json({
    success: true,
    message: 'Token is valid',
    user: {
      id: req.user._id,
      email: req.user.email,
      fullName: req.user.fullName,
      role: req.user.role
    },
    tokenInfo: {
      // Get information from the original Authorization header
      authHeader: req.headers.authorization ? 
        req.headers.authorization.substring(0, 20) + '...' : 'Not provided'
    }
  });
}));

module.exports = router;
