const express = require('express');
const {
  login,
  register,
  refreshToken,
  logout,
  getCurrentUser
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Public routes
router.post('/login', login);
router.post('/register', register);
router.post('/refresh-token', refreshToken);

// Protected routes
router.post('/logout', protect, logout);
router.get('/me', protect, getCurrentUser);

module.exports = router;
