#!/bin/bash

echo "Starting ICY Server..."

# Navigate to the server directory
cd "$(dirname "$0")/.."

# Check if MongoDB is running
echo "Checking if MongoDB is running..."
mongo --eval "db.adminCommand('ping')" > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "MongoDB is not running. Attempting to start MongoDB..."
  
  # On macOS, start MongoDB using brew services
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew services start mongodb-community
    
    if [ $? -ne 0 ]; then
      echo "Error: Failed to start MongoDB service."
      echo "Please start MongoDB manually before starting the server."
      exit 1
    fi
  else
    # For Linux and other OS
    sudo systemctl start mongod
    
    if [ $? -ne 0 ]; then
      echo "Error: Failed to start MongoDB service."
      echo "Please start MongoDB manually before starting the server."
      exit 1
    fi
  fi
  
  # Wait for MongoDB to start up
  echo "Waiting for MongoDB to start up..."
  sleep 5
  
  # Verify MongoDB is now running
  mongo --eval "db.adminCommand('ping')" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Error: MongoDB still not accessible after starting the service."
    echo "Please check your MongoDB installation and try again."
    exit 1
  fi
  
  echo "MongoDB started successfully."
fi

# Check if .env file exists
if [ ! -f .env ]; then
  echo "Error: .env file not found."
  echo "Creating a default .env file..."
  
  cp .env.example .env
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create .env file from example."
    echo "Please create a .env file manually before starting the server."
    exit 1
  fi
  
  echo ".env file created successfully."
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
  
  if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies."
    exit 1
  fi
  
  echo "Dependencies installed successfully."
fi

# Start the server
echo "Starting server..."
npm start
