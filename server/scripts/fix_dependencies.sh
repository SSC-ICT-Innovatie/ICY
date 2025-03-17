#!/bin/bash

echo "Installing missing dependencies..."

# Navigate to server directory
cd "$(dirname "$0")/.."

# Install specific missing packages
npm install colors@1.4.0

# Verify installation
if [ $? -eq 0 ]; then
  echo "Successfully installed missing dependencies!"
  echo "You can now run the server with 'npm start'"
else
  echo "Failed to install dependencies. Please check your npm configuration."
fi
