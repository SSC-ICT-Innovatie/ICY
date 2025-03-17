const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const logger = require('../utils/logger');

let mongoServer;

const connectDB = async () => {
  try {
    // Check if we should skip MongoDB connection (for testing)
    if (process.env.SKIP_MONGODB === 'true') {
      logger.info('MongoDB connection skipped based on environment setting');
      return;
    }

    // Check if we should use in-memory MongoDB (for development/testing)
    if (process.env.USE_MEMORY_DB === 'true') {
      logger.info('Using in-memory MongoDB for development/testing');
      mongoServer = await MongoMemoryServer.create();
      const uri = mongoServer.getUri();
      
      await mongoose.connect(uri, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      });
      
      logger.info('Connected to in-memory MongoDB');
      return;
    }

    // Regular MongoDB connection
    logger.info('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    logger.info('Connected to MongoDB');
  } catch (error) {
    logger.error(`Error connecting to MongoDB: ${error.message}`);
    
    // Try memory server as fallback if main connection fails
    if (!mongoServer && process.env.NODE_ENV === 'development') {
      logger.info('Trying to connect to in-memory MongoDB as fallback...');
      try {
        mongoServer = await MongoMemoryServer.create();
        const uri = mongoServer.getUri();
        
        await mongoose.connect(uri, {
          useNewUrlParser: true,
          useUnifiedTopology: true,
        });
        
        logger.info('Connected to in-memory MongoDB (fallback)');
      } catch (fallbackError) {
        logger.error(`Failed to connect to fallback MongoDB: ${fallbackError.message}`);
        process.exit(1);
      }
    } else {
      // In production, we should exit if MongoDB connection fails
      if (process.env.NODE_ENV === 'production') {
        process.exit(1);
      }
    }
  }
};

const disconnectDB = async () => {
  try {
    await mongoose.disconnect();
    if (mongoServer) {
      await mongoServer.stop();
    }
    logger.info('Disconnected from MongoDB');
  } catch (error) {
    logger.error(`Error disconnecting from MongoDB: ${error.message}`);
  }
};

module.exports = { connectDB, disconnectDB };
