#!/bin/bash

echo "Cleaning node_modules from git tracking..."

# Remove the node_modules folder from git tracking
git rm -r --cached node_modules
echo "node_modules removed from git tracking."

# Make sure .gitignore is updated
if grep -q "node_modules/" .gitignore; then
  echo ".gitignore already contains node_modules exclusion."
else
  echo "Adding node_modules/ to .gitignore"
  echo "node_modules/" >> .gitignore
fi

echo "Changes staged. Now you can commit with a message like:"
echo "git commit -m \"Remove node_modules from git tracking\""
