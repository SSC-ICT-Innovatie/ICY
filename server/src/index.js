require('dotenv').config();
const express = require('express');
const path = require('path');
const cors = require('cors');
const morgan = require('morgan');
const connectDB = require('./config/database');
const { notFound, errorHandler } = require('./middleware/errorMiddleware');
const logger = require('./utils/logger');
const fileUpload = require('express-fileupload');

// Add a simple colorize function
const colorText = (text, color) => {
  if (process.env.NODE_ENV !== 'production') {
    const colors = process.env.NODE_ENV !== 'production' ? {
      cyan: '\x1b[36m',
      yellow: '\x1b[33m',
      green: '\x1b[32m',
      red: '\x1b[31m',
      reset: '\x1b[0m'
    } : {};
    return colors[color] ? `${colors[color]}${text}${colors.reset}` : text;
  }
  return text;
};

// Import routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const surveyRoutes = require('./routes/surveyRoutes');
const achievementRoutes = require('./routes/achievementRoutes');
const marketplaceRoutes = require('./routes/marketplaceRoutes');
const teamRoutes = require('./routes/teamRoutes');
const departmentRoutes = require('./routes/departmentRoutes');
const healthRoutes = require('./routes/healthRoutes');
const notificationRoutes = require('./routes/notificationRoutes'); // Add notifications routes

// Import file utils
const fileUtils = require('./utils/fileUtils');

// Initialize express app
const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Enable CORS
const corsOptions = {
  origin: process.env.CORS_ORIGIN?.split(',') || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
};
app.use(cors(corsOptions));

// Logging middleware
const morganFormat = process.env.NODE_ENV === 'development' ? 'dev' : 'combined';
app.use(morgan(morganFormat, {
  stream: { write: message => logger.http(message.trim()) }
}));

app.use(fileUpload());

// Static files
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// API version and base URL
const apiVersion = process.env.API_VERSION || 'v1';
const baseUrl = `/api/${apiVersion}`;

// Mount routes
app.use(`${baseUrl}/auth`, authRoutes);
app.use(`${baseUrl}/users`, userRoutes);
app.use(`${baseUrl}/surveys`, surveyRoutes);
app.use(`${baseUrl}/achievements`, achievementRoutes);
app.use(`${baseUrl}/marketplace`, marketplaceRoutes);
app.use(`${baseUrl}/teams`, teamRoutes);
app.use(`${baseUrl}/departments`, departmentRoutes);
app.use(`${baseUrl}/notifications`, notificationRoutes); // Add notifications routes
app.use(`${baseUrl}`, healthRoutes);

// API root route
app.get(`${baseUrl}`, (req, res) => {
  res.json({
    message: 'Welcome to ICY API',
    version: apiVersion,
    documentation: '/api-docs'
  });
});

// Error handling middleware
app.use(notFound);
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 5001;
let server;

// Function to gracefully start the server
const startServer = async () => {
  try {
    // Ensure required directories exist before starting the server
    fileUtils.ensureDirectories();

    // Connect to MongoDB - this is critical and shouldn't be skipped
    await connectDB();

    // Start Express server
    server = app.listen(PORT, () => {
      console.log(colorText(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`, 'yellow'));
      console.log(colorText(`MongoDB connection established successfully`, 'green'));
    });
    return server;
  } catch (error) {
    logger.error(`Failed to start server: ${error.message}`, { error });
    console.error(colorText(`Failed to start server: ${error.message}`, 'red'));
    console.log(colorText(`Please run './scripts/mongodb_helper.sh' to troubleshoot MongoDB issues`, 'yellow'));
    
    // Exit with failure in both development and production
    process.exit(1);
  }
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (err, promise) => {
  console.log(colorText(`Error: ${err.message}`, 'red'));
  logger.error(`Unhandled Rejection: ${err.message}`, { error: err });
  // Close server & exit process with failure only if the server was started
  if (server) {
    server.close(() => process.exit(1));
  } else {
    process.exit(1);
  }
});

// Start the server
startServer();

// Export app for testing
module.exports = { app, server };
