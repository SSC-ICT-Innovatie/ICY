require('dotenv').config();
const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');
const colors = require('colors');
const User = require('../models/userModel');
const { Survey } = require('../models/surveyModel');
const { MarketplaceCategory, MarketplaceItem } = require('../models/marketplaceModel');
const { Badge, Challenge, Achievement } = require('../models/achievementModel');
const { Team, League } = require('../models/teamModel');
const connectDB = require('../config/database');
const seedDepartments = require('../seeds/departmentSeeds');
const { seedMarketplace: seedMarketplaceData } = require('../seeds/marketplaceSeeds');

const importData = async () => {
  try {
    // Connect to database
    await connectDB();
    console.log('Connected to MongoDB');

    // Clear existing data
    await clearDatabase();
    console.log('Database cleared');

    // Seed data
    await seedAdminUser();
    console.log('Admin user seeded');

    await seedSampleUsers();
    console.log('Sample users seeded');

    await seedSurveys();
    console.log('Surveys seeded');

    await seedMarketplace();
    console.log('Marketplace seeded');

    await seedAchievements();
    console.log('Achievements seeded');

    await seedTeams();
    console.log('Teams seeded');

    console.log('Data import complete!');
    process.exit();
  } catch (error) {
    console.error(`Error importing data: ${error.message}`);
    process.exit(1);
  }
};

const clearDatabase = async () => {
  await User.deleteMany({});
  await Survey.deleteMany({});
  await MarketplaceCategory.deleteMany({});
  await MarketplaceItem.deleteMany({});
  await Badge.deleteMany({});
  await Challenge.deleteMany({});
  await Achievement.deleteMany({});
  await Team.deleteMany({});
  await League.deleteMany({});
};

const seedAdminUser = async () => {
  const hashedPassword = await bcrypt.hash(process.env.ADMIN_PASSWORD, 10);
  
  await User.create({
    username: 'admin',
    email: process.env.ADMIN_EMAIL,
    password: hashedPassword,
    fullName: 'System Administrator',
    department: 'IT Beheer',
    role: 'admin',
    avatar: 'https://placehold.co/400x400?text=Admin'
  });
};

const seedSampleUsers = async () => {
  const userDataPath = path.join(__dirname, '../data/users.json');
  const userData = JSON.parse(fs.readFileSync(userDataPath));
  
  const hashedPassword = await bcrypt.hash('password123', 10);
  
  const usersToCreate = userData.users.map(user => ({
    ...user,
    password: hashedPassword
  }));
  
  await User.insertMany(usersToCreate);
};

const seedSurveys = async () => {
  const surveyDataPath = path.join(__dirname, '../data/surveys.json');
  const surveyData = JSON.parse(fs.readFileSync(surveyDataPath));
  
  await Survey.insertMany(surveyData.surveys);
};

const seedMarketplace = async () => {
  await seedMarketplaceData();
};

const seedAchievements = async () => {
  const dataPath = path.join(__dirname, '../data/badges_challenges.json');
  const data = JSON.parse(fs.readFileSync(dataPath));
  
  await Badge.insertMany(data.badges.available);
  await Challenge.insertMany(data.challenges.available);
  await Achievement.insertMany(data.achievements);
};

const seedTeams = async () => {
  const dataPath = path.join(__dirname, '../data/teams.json');
  const data = JSON.parse(fs.readFileSync(dataPath));
  
  await League.insertMany(data.leagues);
  
  const users = await User.find();
  const usersMap = users.reduce((map, user) => {
    map[user.username] = user._id;
    return map;
  }, {});
  
  const teamsWithUserIds = data.teams.map(team => {
    const userId = usersMap[team.leader] || usersMap["admin"];
    const memberIds = team.members.map(member => usersMap[member] || usersMap["admin"]);
    
    return {
      name: team.name,
      description: team.description,
      department: team.department,
      leader: userId,
      members: memberIds,
      createdAt: team.createdAt
    };
  });
  
  await Team.insertMany(teamsWithUserIds);
};

const seedAllData = async () => {
  try {
    // Connect to MongoDB
    await connectDB();
    
    // Seed departments
    await seedDepartments();
    
    // Seed marketplace data
    await seedMarketplace();
    
    console.log('Database seeding completed!'.green.bold);
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:'.red.bold, error);
    process.exit(1);
  }
};

seedAllData();

