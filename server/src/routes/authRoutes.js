const express = require('express');
const router = express.Router();
const { 
  login,
  register,
  logout,
  refreshToken,
  getCurrentUser,
  requestVerificationCode,
  verifyEmailCode,
  forgotPassword,
  resetPassword
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

// Public routes
router.post('/login', login);
router.post('/register', register);
router.post('/refresh-token', refreshToken);
router.post('/request-verification-code', requestVerificationCode);
router.post('/verify-email-code', verifyEmailCode);
router.post('/forgot-password', forgotPassword);
router.put('/reset-password/:resettoken', resetPassword);

// Protected routes (require auth)
router.get('/me', protect, getCurrentUser);
router.post('/logout', protect, logout);

module.exports = router;
