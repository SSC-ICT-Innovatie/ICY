const User = require('../models/userModel');
const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');

/**
 * Service to handle notification creation and management
 */
class NotificationService {
  /**
   * Create a notification for a specific user
   * @param {string} userId - The user ID
   * @param {Object} notificationData - Notification data
   * @returns {Object} The created notification
   */
  async createUserNotification(userId, notificationData) {
    try {
      const { title, body, type, actionId, actionUrl } = notificationData;
      
      const user = await User.findById(userId);
      if (!user) {
        throw new Error(`User with ID ${userId} not found`);
      }
      
      const notification = {
        id: uuidv4(),
        title,
        body,
        type: type || 'general',
        isRead: false,
        createdAt: new Date(),
        actionId,
        actionUrl: actionUrl || '/'
      };
      
      user.notifications.push(notification);
      await user.save();
      
      logger.info(`Created notification for user ${userId}: ${title}`);
      return notification;
    } catch (error) {
      logger.error(`Error creating notification: ${error.message}`);
      throw error;
    }
  }
  
  /**
   * Create notification for all users in a department
   * @param {string} department - Department name
   * @param {Object} notificationData - Notification data
   * @returns {number} Number of notifications created
   */
  async createDepartmentNotification(department, notificationData) {
    try {
      const users = await User.find({ department });
      
      let count = 0;
      for (const user of users) {
        await this.createUserNotification(user._id, notificationData);
        count++;
      }
      
      logger.info(`Created notification for ${count} users in ${department} department`);
      return count;
    } catch (error) {
      logger.error(`Error creating department notification: ${error.message}`);
      throw error;
    }
  }
  
  /**
   * Create notification for all users in the system
   * @param {Object} notificationData - Notification data 
   * @returns {number} Number of notifications created
   */
  async createSystemNotification(notificationData) {
    try {
      const users = await User.find();
      
      let count = 0;
      for (const user of users) {
        await this.createUserNotification(user._id, notificationData);
        count++;
      }
      
      logger.info(`Created system notification for ${count} users`);
      return count;
    } catch (error) {
      logger.error(`Error creating system notification: ${error.message}`);
      throw error;
    }
  }
}

module.exports = new NotificationService();
