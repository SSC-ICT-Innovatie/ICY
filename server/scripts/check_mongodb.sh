#!/bin/bash

echo "Checking MongoDB connection..."

# Get MongoDB URI from .env file
MONGODB_URI=$(grep "MONGODB_URI=" .env | cut -d'=' -f2)

if [ -z "$MONGODB_URI" ]; then
  echo "Error: MongoDB URI not found in .env file."
  echo "Please make sure your .env file contains a valid MONGODB_URI."
  exit 1
fi

# Install mongosh if not already installed
if ! command -v mongosh &> /dev/null; then
  echo "MongoDB Shell (mongosh) is not installed."
  echo "To check MongoDB connection manually, ensure your MongoDB is running."
  echo "Your current MongoDB URI is: $MONGODB_URI"
  exit 1
fi

# Check if MongoDB is running
echo "Attempting to connect to $MONGODB_URI"
mongosh "$MONGODB_URI" --eval "db.adminCommand('ping')" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "MongoDB connection successful!"
else
  echo "Failed to connect to MongoDB."
  echo "Please check if your MongoDB service is running and the URI is correct."
  
  # Suggest using MongoDB Atlas if using localhost
  if [[ "$MONGODB_URI" == *"localhost"* ]]; then
    echo ""
    echo "You're using a local MongoDB instance. Consider these options:"
    echo "1. Make sure MongoDB is installed and running locally:"
    echo "   - Install: https://www.mongodb.com/try/download/community"
    echo "   - Start MongoDB service"
    echo ""
    echo "2. Use MongoDB Atlas (cloud-hosted MongoDB):"
    echo "   - Create free account: https://www.mongodb.com/cloud/atlas/register"
    echo "   - Create a cluster and get connection string"
    echo "   - Update MONGODB_URI in your .env file"
  fi
fi
