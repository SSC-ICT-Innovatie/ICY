require('dotenv').config();
const readline = require('readline');
const bcrypt = require('bcryptjs');
const { connectDB } = require('../config/database');
const User = require('../models/userModel');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const question = (query) => new Promise(resolve => rl.question(query, resolve));

const createUser = async () => {
  try {
    await connectDB();
    console.log('Connected to MongoDB');
    
    const username = await question('Enter username: ');
    const email = await question('Enter email: ');
    const password = await question('Enter password: ');
    const fullName = await question('Enter full name: ');
    const department = await question('Enter department: ');
    const role = await question('Enter role (user/team_lead/admin): ');
    
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const user = await User.create({
      username,
      email,
      password: hashedPassword,
      fullName,
      department,
      role: ['user', 'team_lead', 'admin'].includes(role) ? role : 'user',
      avatar: `https://placehold.co/400x400?text=${encodeURIComponent(fullName)}`
    });
    
    console.log(`User created successfully: ${user._id}`);
  } catch (error) {
    console.error(`Error: ${error.message}`);
  } finally {
    rl.close();
    process.exit();
  }
};

createUser();
