const mongoose = require('mongoose');
const loadConfig = require('../config');

let isConnected = false;

async function connectToDatabase() {
  if (isConnected) {
    console.log('Using existing database connection');
    return;
  }

  try {
    const config = await loadConfig();
    const mongodbUrl = `mongodb+srv://${config.DB_USRNAME}:${config.DB_PASS}@${config.DB_HOST}`;
    await mongoose.connect(mongodbUrl);
    isConnected = true;
    console.log('Connected to MongoDB');
  } catch (error) {
    console.error('Error connecting to MongoDB:', error);
    throw error;
  }
}

module.exports = connectToDatabase;