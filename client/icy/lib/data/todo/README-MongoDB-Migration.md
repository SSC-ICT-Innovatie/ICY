# ICY App - MongoDB Migration Guide

This guide outlines the process for migrating the ICY application's JSON data structure to MongoDB.

## Table of Contents

- [Database Design](#database-design)
- [Setup](#setup)
- [Migration Process](#migration-process)
- [Data Validation](#data-validation)
- [Sample Scripts](#sample-scripts)
- [Post-Migration Tasks](#post-migration-tasks)

## Database Design

### Collection Structure

Our JSON files will map to MongoDB collections as follows:

| JSON File | MongoDB Collection | Description |
|-----------|-------------------|-------------|
| users.json | users | User accounts and authentication |
| user_data.json | user_profiles | User-specific data and preferences |
| teams.json | teams | Team structure and statistics |
| surveys.json | surveys | Survey definitions and questions |
| surveys.json (responses) | survey_responses | User survey answers |
| marketplace.json | marketplace_items | Available marketplace items |
| marketplace.json (purchaseHistory) | user_purchases | User purchase records |
| badges_challenges.json (badges) | badges | Badge definitions |
| badges_challenges.json (challenges) | challenges | Challenge definitions |
| levels_rewards.json | levels | Level definitions and rewards |

### Data Relationships

MongoDB relationships will be implemented using document references:

- **One-to-Many**: Store the ID of the "one" side in the "many" side documents
  - Example: User ID in survey responses
  
- **Many-to-Many**: Store arrays of IDs in both collections or use a join collection
  - Example: Users and teams relationship

## Setup

### Prerequisites

1. [MongoDB Community Server](https://www.mongodb.com/try/download/community) (4.4+) or MongoDB Atlas account
2. [MongoDB Compass](https://www.mongodb.com/products/compass) (optional, for GUI management)
3. Node.js (14+) with npm or yarn

### Installation

```bash
# Install MongoDB driver and migration tools
npm install mongodb mongoose
npm install -D mongodb-migrate-cli

# Install data transformation utilities (optional)
npm install lodash
```

### Creating the MongoDB Connection

```javascript
// db/connection.js
const { MongoClient } = require('mongodb');

const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/icy_app';

let client;
let database;

async function connectToDatabase() {
  if (database) return database;
  
  try {
    client = new MongoClient(uri);
    await client.connect();
    database = client.db();
    console.log('Connected to MongoDB');
    return database;
  } catch (error) {
    console.error('MongoDB connection error:', error);
    throw error;
  }
}

module.exports = {
  connectToDatabase,
  getDatabase: () => database,
  closeConnection: () => client && client.close()
};
```

## Migration Process

### Step 1: Schema Setup

Create schema definitions for MongoDB collections to ensure data integrity:

```javascript
// db/schemas/userSchema.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { 
    type: String, 
    required: true, 
    unique: true 
  },
  email: { 
    type: String, 
    required: true, 
    unique: true 
  },
  fullName: { 
    type: String, 
    required: true 
  },
  password: { 
    type: String, 
    required: true 
  },
  avatar: String,
  department: String,
  role: {
    type: String,
    enum: ['user', 'team_lead', 'admin'],
    default: 'user'
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  }
});

module.exports = mongoose.model('User', userSchema);
```

### Step 2: Data Migration Scripts

Create scripts to migrate each JSON file to its corresponding MongoDB collection:

```javascript
// scripts/migrateUsers.js
const fs = require('fs');
const path = require('path');
const { connectToDatabase, closeConnection } = require('../db/connection');

async function migrateUsers() {
  try {
    // Read JSON file
    const rawData = fs.readFileSync(
      path.join(__dirname, '../lib/data/users.json')
    );
    const userData = JSON.parse(rawData).users;
    
    // Connect to database
    const db = await connectToDatabase();
    const usersCollection = db.collection('users');
    
    // Clear existing data (optional)
    await usersCollection.deleteMany({});
    
    // Insert data
    const result = await usersCollection.insertMany(userData);
    
    console.log(`${result.insertedCount} users migrated successfully`);
    
  } catch (error) {
    console.error('Error migrating users:', error);
  } finally {
    await closeConnection();
  }
}

migrateUsers();
```

### Step 3: Running Migrations

Execute each migration script in sequence:

```bash
# Create a master migration script
node scripts/runAllMigrations.js

# Or run individual migrations
node scripts/migrateUsers.js
node scripts/migrateUserProfiles.js
# etc.
```

## Data Validation

After migration, validate the data integrity:

```javascript
// scripts/validateMigration.js
const { connectToDatabase, closeConnection } = require('../db/connection');

async function validateMigration() {
  try {
    const db = await connectToDatabase();
    
    // Check counts
    const userCount = await db.collection('users').countDocuments();
    const profileCount = await db.collection('user_profiles').countDocuments();
    const teamCount = await db.collection('teams').countDocuments();
    
    console.log('Validation Results:');
    console.log(`Users: ${userCount}`);
    console.log(`Profiles: ${profileCount}`);
    console.log(`Teams: ${teamCount}`);
    
    // Validate relationships
    const randomUser = await db.collection('users').findOne();
    if (randomUser) {
      const userProfile = await db.collection('user_profiles').findOne({ userId: randomUser._id.toString() });
      console.log('User Profile Found:', !!userProfile);
    }
    
  } catch (error) {
    console.error('Validation error:', error);
  } finally {
    await closeConnection();
  }
}

validateMigration();
```

## Sample Scripts

### Complete Migration Script

```javascript
// scripts/runAllMigrations.js
const { migrateUsers } = require('./migrateUsers');
const { migrateUserProfiles } = require('./migrateUserProfiles');
const { migrateTeams } = require('./migrateTeams');
const { migrateSurveys } = require('./migrateSurveys');
const { migrateBadgesAndChallenges } = require('./migrateBadgesAndChallenges');
const { migrateMarketplace } = require('./migrateMarketplace');
const { migrateLevels } = require('./migrateLevels');

async function runAllMigrations() {
  try {
    console.log('Starting migration process...');
    
    // Run migrations in order (to respect data dependencies)
    await migrateUsers();
    await migrateUserProfiles();
    await migrateTeams();
    await migrateSurveys();
    await migrateBadgesAndChallenges();
    await migrateMarketplace();
    await migrateLevels();
    
    console.log('All migrations completed successfully!');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

runAllMigrations();
```

## Post-Migration Tasks

1. **Update Application Configuration**: 
   - Update connection strings in app_config.json
   - Set up authentication for the MongoDB instance

2. **Implement Data Access Layer**:
   - Create MongoDB repository classes
   - Replace JSON file operations with MongoDB queries

3. **Performance Optimization**:
   - Create appropriate indexes
   ```javascript
   db.users.createIndex({ "username": 1 }, { unique: true });
   db.users.createIndex({ "email": 1 }, { unique: true });
   db.user_profiles.createIndex({ "userId": 1 }, { unique: true });
   db.survey_responses.createIndex({ "userId": 1, "surveyId": 1 });
   ```

4. **Backup Strategy**:
   - Set up automated backups for the MongoDB database
   - Test backup and restore procedures

## Best Practices

1. **Use Transactions** for operations that modify multiple documents
2. **Implement Retry Logic** for handling transient errors
3. **Validate Data** before and after migration
4. **Index Heavily Used Fields** to improve query performance
5. **Monitor Performance** using MongoDB's built-in tools

## Additional Resources

- [MongoDB Documentation](https://docs.mongodb.com/)
- [Mongoose Documentation](https://mongoosejs.com/docs/)
- [MongoDB University](https://university.mongodb.com/) - Free courses on MongoDB
