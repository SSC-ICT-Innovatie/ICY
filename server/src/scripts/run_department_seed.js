// This script runs the department seeding process
require('dotenv').config();
const seedDepartments = require('./seed_departments');

console.log('Starting department seeding process...');
seedDepartments()
  .then(() => {
    console.log('Department seeding completed successfully');
    process.exit(0);
  })
  .catch(err => {
    console.error('Department seeding failed:', err);
    process.exit(1);
  });
