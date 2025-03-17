#!/bin/bash

# MongoDB Helper Script
# ---------------------
# Helps set up, check, and troubleshoot MongoDB

# Function to check if MongoDB is installed
check_mongodb_installed() {
  if ! command -v mongod &> /dev/null; then
    echo "❌ MongoDB is NOT installed"
    echo
    echo "To install MongoDB on macOS using Homebrew:"
    echo "1. brew tap mongodb/brew"
    echo "2. brew install mongodb-community"
    echo
    return 1
  else
    echo "✅ MongoDB is installed"
    return 0
  fi
}

# Function to check if MongoDB is running
check_mongodb_running() {
  if pgrep -x "mongod" > /dev/null; then
    echo "✅ MongoDB is running"
    return 0
  else
    echo "❌ MongoDB is NOT running"
    return 1
  fi
}

# Function to start MongoDB
start_mongodb() {
  echo "Starting MongoDB..."
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    brew services start mongodb-community
    
    if [ $? -eq 0 ]; then
      echo "✅ MongoDB started successfully"
      return 0
    else
      echo "❌ Failed to start MongoDB using brew services"
      echo "Trying alternative method..."
      
      # Create data directory if it doesn't exist
      mkdir -p ~/data/db
      
      # Start MongoDB as a background process
      mongod --dbpath ~/data/db &
      
      if [ $? -eq 0 ]; then
        echo "✅ MongoDB started successfully using direct command"
        return 0
      else
        echo "❌ Failed to start MongoDB"
        return 1
      fi
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    sudo systemctl start mongod
    
    if [ $? -eq 0 ]; then
      echo "✅ MongoDB started successfully"
      return 0
    else
      echo "❌ Failed to start MongoDB"
      return 1
    fi
  else
    echo "❌ Unsupported operating system"
    return 1
  fi
}

# Function to setup initial data
setup_initial_data() {
  echo "Setting up initial database data..."
  
  # Create a simple setup script
  cat > /tmp/icy_db_setup.js << EOL
// Connect to database
db = db.getSiblingDB('icy_app');

// Create departments collection and add some departments
if (db.departments.count() === 0) {
  db.departments.insertMany([
    { name: "ICT", description: "Information and Communication Technology Department", active: true },
    { name: "HR", description: "Human Resources Department", active: true },
    { name: "Finance", description: "Finance Department", active: true },
    { name: "Marketing", description: "Marketing Department", active: true },
    { name: "Operations", description: "Operations Department", active: true }
  ]);
  print("✅ Departments created");
}

// Create admin user if it doesn't exist
if (db.users.countDocuments({ role: "admin" }) === 0) {
  db.users.insertOne({
    username: "admin",
    email: "admin@example.com",
    password: "\$2a\$10\$aqjJ4bc.nXAFUJY9tJ.wbuQG9jJp.1CPiwE3IHLRJZcs4qR9gMwSS", // "admin123"
    fullName: "System Admin",
    role: "admin",
    department: "ICT",
    createdAt: new Date(),
    updatedAt: new Date()
  });
  print("✅ Admin user created");
}

print("Database setup complete!");
EOL

  # Run the script
  if command -v mongosh &> /dev/null; then
    mongosh mongodb://localhost:27017 /tmp/icy_db_setup.js
  else
    mongo mongodb://localhost:27017 /tmp/icy_db_setup.js
  fi
}

# Function to show Atlas setup instructions
show_atlas_instructions() {
  echo "=== MongoDB Atlas Setup Instructions ==="
  echo
  echo "1. Create a free MongoDB Atlas account at: https://www.mongodb.com/cloud/atlas/register"
  echo "2. Create a new cluster (the free tier is sufficient)"
  echo "3. Click 'Connect' on your cluster"
  echo "4. Choose 'Connect your application'"
  echo "5. Copy the connection string"
  echo "6. Replace the MONGODB_URI in your .env file with the connection string"
  echo "7. Replace <password> with your database user password"
  echo "8. Replace myFirstDatabase with 'icy_app'"
  echo
  echo "Example connection string format:"
  echo "mongodb+srv://username:password@cluster.mongodb.net/icy_app?retryWrites=true&w=majority"
  echo
}

# Main menu
main_menu() {
  clear
  echo "=== MongoDB Helper for ICY Application ==="
  echo
  echo "1. Check MongoDB installation"
  echo "2. Start MongoDB (local)"
  echo "3. Setup initial database data"
  echo "4. MongoDB Atlas instructions"
  echo "5. Exit"
  echo
  read -p "Enter your choice [1-5]: " choice
  
  case $choice in
    1) 
      check_mongodb_installed
      read -p "Press Enter to continue..."
      main_menu
      ;;
    2)
      if check_mongodb_installed; then
        if ! check_mongodb_running; then
          start_mongodb
        fi
      fi
      read -p "Press Enter to continue..."
      main_menu
      ;;
    3)
      if check_mongodb_installed && check_mongodb_running; then
        setup_initial_data
      else
        echo "MongoDB must be installed and running to setup data"
      fi
      read -p "Press Enter to continue..."
      main_menu
      ;;
    4)
      show_atlas_instructions
      read -p "Press Enter to continue..."
      main_menu
      ;;
    5)
      exit 0
      ;;
    *)
      echo "Invalid choice"
      sleep 1
      main_menu
      ;;
  esac
}

# Start the script
main_menu
