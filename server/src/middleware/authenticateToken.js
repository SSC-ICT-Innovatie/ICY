// middleware/authenticateToken.js
const jwt = require('jsonwebtoken');
const User = require('../mongodb_server/models/user');
const Subscription = require('../mongodb_server/models/subscription');
const loadConfig = require('../config');

let JWT_SECRET;
(async () => {
  const config = await loadConfig();
  JWT_SECRET = config.JWT_SECRET;
})();

// Routes that are accessible even with inactive subscription
const ALLOWED_ROUTES = [
  '/api/auth',
  '/api/subscriptions',
  '/api/settings',
  '/api/account'
];

const authenticateToken = async (req, res, next) => {
  if (req.method === 'OPTIONS') {
    return next();
  }

  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: "No token provided" });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await User.findById(decoded.userId);

    if (!user) {
      return res.status(401).json({ error: "User not found" });
    }

    req.user = {
      userId: decoded.userId,
      companyId: decoded.companyId
    };
    req.companyId = decoded.companyId;

    // Check if route is always allowed
    if (ALLOWED_ROUTES.some(route => req.originalUrl.startsWith(route))) {
      return next();
    }

    // Check subscription status
    const subscription = await Subscription.findOne({ company_id: decoded.companyId });
    if (!subscription || subscription.status === 'inactive' || subscription.status === 'canceled') {
      return res.status(403).json({ 
        error: "Subscription required",
        message: "Your subscription has expired. Please renew your subscription to continue."
      });
    }

    next();
  } catch (error) {
    console.error("Error in authenticateToken middleware:", error);
    return res.status(403).json({ error: "Invalid token" });
  }
};

module.exports = authenticateToken;