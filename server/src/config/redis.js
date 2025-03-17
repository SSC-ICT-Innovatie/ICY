const redis = require('redis');
const logger = require('../utils/logger');

let redisClient;

const connectRedis = async () => {
  try {
    // Skip Redis if SKIP_REDIS is set to true
    if (process.env.SKIP_REDIS === 'true') {
      logger.info('Redis connection skipped based on environment setting');
      return null;
    }
    
    // Skip Redis connection if not configured in environment
    if (!process.env.REDIS_HOST) {
      logger.info('Redis not configured - running without cache');
      return null;
    }
    
    logger.info('Connecting to Redis...');
    
    const client = redis.createClient({
      url: `redis://${process.env.REDIS_PASSWORD ? process.env.REDIS_PASSWORD + '@' : ''}${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`
    });
    
    await client.connect();
    
    client.on('error', (err) => {
      logger.error(`Redis Error: ${err}`);
    });
    
    client.on('connect', () => {
      logger.info('Connected to Redis');
    });
    
    redisClient = client;
    return client;
  } catch (error) {
    logger.error(`Redis connection error: ${error.message}`);
    logger.info('Continuing without Redis caching');
    return null;
  }
};

const getRedisClient = () => {
  return redisClient;
};

// Cache middleware for Express routes
const cacheMiddleware = (duration) => {
  return async (req, res, next) => {
    // Skip caching if Redis is not configured or connected
    if (!redisClient || !redisClient.isReady) {
      return next();
    }
    
    const key = `cache:${req.originalUrl || req.url}`;
    
    try {
      const cachedResponse = await redisClient.get(key);
      
      if (cachedResponse) {
        const parsedResponse = JSON.parse(cachedResponse);
        return res.json(parsedResponse);
      }
      
      // Store the original json method
      const originalJson = res.json;
      
      // Override res.json to cache the response before sending
      res.json = function(body) {
        // Cache the response
        redisClient.setEx(key, duration, JSON.stringify(body));
        
        // Call the original json method
        return originalJson.call(this, body);
      };
      
      next();
    } catch (error) {
      logger.error(`Cache middleware error: ${error.message}`);
      next();
    }
  };
};

module.exports = {
  connectRedis,
  getRedisClient,
  cacheMiddleware
};
