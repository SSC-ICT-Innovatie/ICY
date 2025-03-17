#!/bin/bash

# ICY Server Deployment Script

# Ensure script is run with correct permissions
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or with sudo"
  exit
fi

echo "===== ICY Server Deployment ====="
echo "This script will deploy the ICY server to production."

# Check if we're deploying to production
read -p "Are you deploying to production? (y/n): " PROD_DEPLOY
if [[ $PROD_DEPLOY == "y" ]]; then
  # Copy production env file
  echo "Setting up production environment..."
  if [ -f .env.production ]; then
    cp .env.production .env
    echo "Production environment configured."
  else
    echo "Error: .env.production file not found!"
    exit 1
  fi
else
  echo "Using development environment."
fi

# Install dependencies
echo "Installing dependencies..."
npm ci

# Build the application if necessary (uncomment if you have a build step)
# echo "Building application..."
# npm run build

# Start or restart the application using PM2
if command -v pm2 &> /dev/null; then
  echo "Starting server with PM2..."
  pm2 restart icy-server || pm2 start src/index.js --name "icy-server"
  pm2 save
  echo "Server started successfully with PM2."
else
  echo "PM2 not found. Installing PM2..."
  npm install -g pm2
  echo "Starting server with PM2..."
  pm2 start src/index.js --name "icy-server"
  pm2 save
  echo "Server started successfully with PM2."
fi

echo "===== Deployment Complete ====="
echo "Server is now running. Check logs with: pm2 logs icy-server"
