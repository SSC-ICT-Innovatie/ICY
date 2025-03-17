# MongoDB Setup Guide for ICY Application

This guide explains how to set up MongoDB for the ICY application in both development and production environments.

## Option 1: Local MongoDB (Development)

### Installation

**On macOS:**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install MongoDB
brew tap mongodb/brew
brew install mongodb-community

# Start MongoDB service
brew services start mongodb-community
```

**On Windows:**
1. Download MongoDB Community Server from https://www.mongodb.com/try/download/community
2. Follow the installation instructions
3. Start MongoDB service

### Verification

Run the following to make sure MongoDB is properly installed and running:
```bash
# Check if MongoDB is running
brew services list | grep mongodb

# Connect to MongoDB
mongosh
```

You should see the MongoDB shell prompt if successful.

### Configuration

In your `.env` file, set:
