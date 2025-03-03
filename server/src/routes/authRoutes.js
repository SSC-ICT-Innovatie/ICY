const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authenticateToken = require('../middleware/authenticateToken');

router.post('/register', authController.register);
router.post('/verify-email', authController.verifyEmail);
router.post('/login', authController.login);
router.post('/verify-login', authController.verifyLogin);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);
router.post('/device-login', authController.deviceLogin);
router.post('/refresh-token', authController.refreshToken);
router.get('/user', authenticateToken, authController.getCurrentUser);

module.exports = router;