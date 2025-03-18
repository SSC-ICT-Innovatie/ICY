const mongoose = require('mongoose');
const Department = require('../models/departmentModel');
const logger = require('../utils/logger');
require('dotenv').config();

// Initial departments to seed
const initialDepartments = [
  {
    name: 'ICT',
    description: 'Information and Communication Technology Department',
    active: true
  },
  {
    name: 'HR',
    description: 'Human Resources Department',
    active: true
  },
  {
    name: 'Finance',
    description: 'Finance Department',
    active: true
  },
  {
    name: 'Marketing',
    description: 'Marketing Department',
    active: true
  },
  {
    name: 'Operations',
    description: 'Operations Department',
    active: true
  },
  {
    name: 'Sales',
    description: 'Sales Department',
    active: true
  },
  {
    name: 'Customer Service',
    description: 'Customer Service Department',
    active: true
  },
  {
    name: 'Research & Development',
    description: 'Research and Development Department',
    active: true
  }
];

// Connect to MongoDB
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      serverSelectionTimeoutMS: 5000
    });
    logger.info(`MongoDB Connected: ${conn.connection.host}`);
    return conn;
  } catch (error) {
    logger.error(`Error connecting to MongoDB: ${error.message}`, { error });
    process.exit(1);
  }
};

// Seed departments
const seedDepartments = async () => {
  try {
    // First connect to the database
    await connectDB();
    
    logger.info('Checking for existing departments...');
    
    // Check if departments already exist
    const count = await Department.countDocuments();
    
    if (count > 0) {
      logger.info(`Found ${count} existing departments, skipping seed`);
    } else {
      logger.info('No departments found, seeding initial departments...');
      
      // Insert the departments
      await Department.insertMany(initialDepartments);
      
      logger.info(`Successfully seeded ${initialDepartments.length} departments`);
    }
    
    // Disconnect from MongoDB
    await mongoose.disconnect();
    logger.info('MongoDB disconnected');
    
  } catch (error) {
    logger.error(`Error seeding departments: ${error.message}`, { error });
    process.exit(1);
  }
};

// Execute the seed function if this script is run directly
if (require.main === module) {
  seedDepartments();
}

module.exports = seedDepartments;
