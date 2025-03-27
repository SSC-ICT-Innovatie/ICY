const express = require('express');
const router = express.Router();
const {
  login,
  register,
  getCurrentUser,
  logout,
  requestVerificationCode,
  verifyEmailCode,
  forgotPassword,
  resetPassword,
  refreshToken
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

// Public routes
router.post('/login', login);
router.post('/register', register);
router.post('/refresh-token', refreshToken);

router.post('/request-verification', requestVerificationCode);
router.post('/verify-email-code', verifyEmailCode);
router.post('/forgot-password', forgotPassword);
router.put('/reset-password/:resettoken', resetPassword);

// Protected routes
router.get('/me', protect, getCurrentUser);
router.post('/logout', protect, logout);

module.exports = router;
