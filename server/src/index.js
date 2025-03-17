require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const { connectDB } = require('./config/database');
const { connectRedis, cacheMiddleware } = require('./config/redis');
const logger = require('./utils/logger');
const { errorHandler, notFound } = require('./middleware/errorMiddleware');

// Import Routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const surveyRoutes = require('./routes/surveyRoutes');
const marketplaceRoutes = require('./routes/marketplaceRoutes');
const teamRoutes = require('./routes/teamRoutes');
const achievementRoutes = require('./routes/achievementRoutes');
const healthRoutes = require('./routes/healthRoutes');

const app = express();

connectDB();

// Connect to Redis (for caching,)
connectRedis();

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : '*',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Rate limiting
const limiter = rateLimit({
  windowMs: process.env.RATE_LIMIT_WINDOW * 60 * 1000 || 15 * 60 * 1000,
  max: process.env.RATE_LIMIT_MAX || 100
});
app.use(limiter);

// API Routes
const apiBaseUrl = process.env.API_BASE_URL || '/api/v1';

app.use(`${apiBaseUrl}/auth`, authRoutes);
app.use(`${apiBaseUrl}/users`, userRoutes);
app.use(`${apiBaseUrl}/surveys`, surveyRoutes);
// Use cache middleware for marketplace routes that are less dynamic
app.use(`${apiBaseUrl}/marketplace/categories`, cacheMiddleware(60 * 60)); // Cache for 1 hour
app.use(`${apiBaseUrl}/marketplace`, marketplaceRoutes);
app.use(`${apiBaseUrl}/teams`, teamRoutes);
app.use(`${apiBaseUrl}/achievements`, achievementRoutes);
app.use('/api/v1', healthRoutes);

// Health check route
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Server is running' });
});

app.use(notFound);
app.use(errorHandler);

// Start server with better error handling
const PORT = process.env.PORT || 5001;
const server = app.listen(PORT, () => {
  logger.info(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
})
.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    logger.error(`Port ${PORT} is already in use. Trying port ${PORT + 1}...`);
    // Try another port
    const newPort = PORT + 1;
    server.close();
    app.listen(newPort, () => {
      logger.info(`Server running in ${process.env.NODE_ENV} mode on port ${newPort}`);
    });
  } else {
    logger.error(`Server error: ${err.message}`);
    process.exit(1);
  }
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  logger.error(`Unhandled Rejection: ${err.message}`);
  // Close server & exit process
  server.close(() => process.exit(1));
});

// Handle SIGTERM signal (e.g., from Docker)
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
  });
});

module.exports = app;
