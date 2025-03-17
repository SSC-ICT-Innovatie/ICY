#!/bin/bash

echo "Starting MongoDB service..."

# Check if MongoDB is installed
if ! command -v mongod &> /dev/null; then
  echo "MongoDB is not installed. Please install MongoDB first:"
  echo "brew tap mongodb/brew"
  echo "brew install mongodb-community"
  exit 1
fi

# Check if MongoDB service is already running
if pgrep -x "mongod" > /dev/null; then
  echo "MongoDB is already running."
else
  # On macOS, start MongoDB using brew services
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Starting MongoDB service using Homebrew..."
    brew services start mongodb-community
    
    if [ $? -eq 0 ]; then
      echo "MongoDB service started successfully."
    else
      echo "Error: Failed to start MongoDB service."
      echo "Trying alternative method with direct mongod command..."
      
      # Create data directory if it doesn't exist
      mkdir -p ~/data/db
      
      # Start MongoDB directly
      mongod --dbpath ~/data/db &
      
      if [ $? -eq 0 ]; then
        echo "MongoDB started successfully with direct mongod command."
      else
        echo "Error: Failed to start MongoDB. Please check MongoDB installation."
        exit 1
      fi
    fi
  else
    # For Linux and other OS
    echo "Starting MongoDB service..."
    sudo systemctl start mongod
    
    if [ $? -eq 0 ]; then
      echo "MongoDB service started successfully."
    else
      echo "Error: Failed to start MongoDB service."
      exit 1
    fi
  fi
fi

# Verify MongoDB connection
echo "Verifying MongoDB connection..."
mongo --eval "db.adminCommand('ping')" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "MongoDB connection successful!"
else
  echo "Failed to connect to MongoDB. Please check MongoDB service status."
  exit 1
fi

echo "MongoDB is ready to use!"
