const Department = require('../models/departmentModel');
const mongoose = require('mongoose');
// Remove colors dependency and use a simple function instead
// const colors = require('colors');

// Simple colorize function
const colorText = (text, color) => {
  const colors = {
    cyan: '\x1b[36m',
    yellow: '\x1b[33m', 
    green: '\x1b[32m',
    red: '\x1b[31m',
    reset: '\x1b[0m'
  };
  return `${colors[color] || ''}${text}${colors.reset}`;
};

const departments = [
  {
    name: 'ICT',
    description: 'Information and Communication Technology Department'
  },
  {
    name: 'HR',
    description: 'Human Resources Department'
  },
  {
    name: 'Finance',
    description: 'Finance Department'
  },
  {
    name: 'Marketing',
    description: 'Marketing Department'
  },
  {
    name: 'Operations',
    description: 'Operations Department'
  },
  {
    name: 'Sales',
    description: 'Sales Department'
  },
  {
    name: 'Customer Service',
    description: 'Customer Service Department'
  },
  {
    name: 'Research & Development',
    description: 'Research and Development Department'
  }
];

const seedDepartments = async () => {
  try {
    console.log(colorText('Seeding departments...', 'cyan'));
    
    // Check if departments already exist
    const count = await Department.countDocuments();
    if (count > 0) {
      console.log(colorText('Departments already exist. Skipping seed.', 'yellow'));
      return;
    }
    
    // Insert the departments
    await Department.insertMany(departments);
    console.log(colorText('Departments successfully seeded!', 'green'));
  } catch (error) {
    console.error(colorText('Error seeding departments:', 'red'), error);
  }
};

module.exports = seedDepartments;
