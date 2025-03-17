const mongoose = require('mongoose');
const logger = require('../utils/logger');

/**
 * Connect to MongoDB database with improved error handling
 * @returns {Promise<mongoose.Connection>} - MongoDB connection
 */
const connectDB = async () => {
  const maxRetries = 3;
  let retries = 0;
  let connected = false;

  // Get the MongoDB URI from environment variables
  const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/icy_app';

  while (!connected && retries < maxRetries) {
    try {
      logger.info(`Connecting to MongoDB (Attempt ${retries + 1}/${maxRetries})...`);
      
      // Connect to MongoDB
      const conn = await mongoose.connect(mongoURI, {
        // For Mongoose 6+, these are now the defaults
        // useNewUrlParser: true,
        // useUnifiedTopology: true,
        serverSelectionTimeoutMS: 5000 // Short timeout for faster feedback
      });

      connected = true;
      logger.info(`MongoDB Connected: ${conn.connection.host}`);
      
      // Return the connection for reference
      return conn.connection;
    } catch (error) {
      retries += 1;
      logger.error(`MongoDB connection attempt ${retries} failed: ${error.message}`, { error });
      
      if (retries < maxRetries) {
        // Wait exponentially longer between each retry
        const waitTime = Math.pow(2, retries) * 1000;
        logger.info(`Retrying in ${waitTime / 1000} seconds...`);
        await new Promise(resolve => setTimeout(resolve, waitTime));
      } else {
        logger.error(`All ${maxRetries} MongoDB connection attempts failed.`);
        
        // Provide helpful information for users
        const helpText = `
=== MongoDB Connection Troubleshooting ===

1. For local development:
   • Make sure MongoDB is installed: brew list mongodb-community
   • Start MongoDB locally: brew services start mongodb-community
   • Check MongoDB status: brew services list

2. Using MongoDB Atlas:
   • Sign up at https://www.mongodb.com/cloud/atlas/register
   • Create a free cluster
   • Get your connection string and update MONGODB_URI in .env

Current connection string: ${mongoURI}
`;
        logger.info(helpText);
        
        throw new Error(`Failed to connect to MongoDB after ${maxRetries} attempts`);
      }
    }
  }
};

module.exports = connectDB;
