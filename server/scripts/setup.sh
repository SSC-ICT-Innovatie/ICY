#!/bin/bash

echo "Setting up ICY Server dependencies..."

# Navigate to server directory
cd "$(dirname "$0")/.."

# Check if .gitignore exists and contains node_modules
if [ ! -f .gitignore ] || ! grep -q "node_modules" .gitignore; then
  echo "Warning: .gitignore file is missing or doesn't exclude node_modules!"
  echo "This could cause node_modules to be committed to git."
  echo "Adding node_modules to .gitignore..."
  echo "node_modules/" >> .gitignore
fi

# Install dependencies
echo "Installing npm packages..."
npm install

# Create uploads directory for multer (if doesn't exist)
echo "Creating uploads directory structure..."
mkdir -p uploads/avatars
mkdir -p uploads/temp

echo "Setup complete! You can now start the server with 'npm start'"
