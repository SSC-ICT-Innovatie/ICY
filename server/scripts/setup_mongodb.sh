#!/bin/bash

# This script sets up a local MongoDB instance for development

# Check if MongoDB is installed
if command -v mongod &> /dev/null; then
  echo "MongoDB is already installed"
else
  echo "MongoDB is not installed. Installing MongoDB..."
  
  # Detect OS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "Detected macOS. Installing MongoDB via Homebrew..."
    if ! command -v brew &> /dev/null; then
      echo "Homebrew is not installed. Please install Homebrew first:"
      echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    
    brew tap mongodb/brew
    brew install mongodb-community
    
    # Start MongoDB service
    brew services start mongodb-community
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo "Detected Linux. Please install MongoDB manually:"
    echo "  https://www.mongodb.com/docs/manual/administration/install-on-linux/"
    exit 1
  else
    echo "Unsupported operating system. Please install MongoDB manually:"
    echo "  https://www.mongodb.com/docs/manual/installation/"
    exit 1
  fi
fi

# Create database and collections
echo "Creating ICY database and initial collections..."
cat <<EOT > ./scripts/create_db.js
// Connect to MongoDB
conn = new Mongo();
db = conn.getDB("icy_app");

// Create collections with validation
db.createCollection("users");
db.createCollection("departments");
db.createCollection("surveys");
db.createCollection("achievements");
db.createCollection("teams");
db.createCollection("marketplace");

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
  print("Admin user created");
}

// Create some initial departments
if (db.departments.countDocuments() === 0) {
  db.departments.insertMany([
    { name: "ICT", description: "Information and Communication Technology Department", active: true, createdAt: new Date() },
    { name: "HR", description: "Human Resources Department", active: true, createdAt: new Date() },
    { name: "Finance", description: "Finance Department", active: true, createdAt: new Date() }
  ]);
  print("Initial departments created");
}

print("Database setup complete!");
EOT

# Run MongoDB script
if command -v mongosh &> /dev/null; then
  mongosh mongodb://localhost:27017/icy_app ./scripts/create_db.js
else
  # Fall back to older mongo command
  mongo mongodb://localhost:27017/icy_app ./scripts/create_db.js
fi

echo ""
echo "MongoDB setup complete!"
echo "Make sure your .env file contains: MONGODB_URI=mongodb://localhost:27017/icy_app"
