const fs = require('fs');
const path = require('path');
const logger = require('./logger');

/**
 * Ensures that required application directories exist
 */
exports.ensureDirectories = () => {
  const requiredDirs = [
    path.join(__dirname, '../../uploads'),
    path.join(__dirname, '../../uploads/avatars'),
    path.join(__dirname, '../../uploads/temp'),
  ];

  requiredDirs.forEach(dir => {
    if (!fs.existsSync(dir)) {
      try {
        fs.mkdirSync(dir, { recursive: true });
        logger.info(`Created directory: ${dir}`);
      } catch (err) {
        logger.error(`Error creating directory ${dir}: ${err.message}`);
      }
    }
  });
};

/**
 * Safely deletes a file if it exists
 * @param {string} filePath - Path to the file
 */
exports.safeDeleteFile = (filePath) => {
  if (fs.existsSync(filePath)) {
    try {
      fs.unlinkSync(filePath);
      logger.info(`Deleted file: ${filePath}`);
      return true;
    } catch (err) {
      logger.error(`Error deleting file ${filePath}: ${err.message}`);
      return false;
    }
  }
  return false;
};
