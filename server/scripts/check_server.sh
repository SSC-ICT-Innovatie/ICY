#!/bin/bash

echo "Checking ICY Server Status..."

# Get the port from .env file or use default
PORT=$(grep "PORT=" .env | cut -d'=' -f2 || echo "5001")

# Check if a process is running on the port
PID=$(lsof -i :$PORT -t)

if [ -z "$PID" ]; then
  echo "No process is running on port $PORT"
  echo "Server is not running. Start it with 'npm start'"
else
  echo "Server is running on port $PORT (PID: $PID)"
  
  # Check if the server is responding to requests
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/api/v1/health 2>/dev/null)
  
  if [ "$RESPONSE" == "200" ]; then
    echo "Server is healthy and responding to requests"
  else
    echo "Warning: Server process exists but may not be responding correctly"
    echo "Response code from health endpoint: $RESPONSE"
    
    echo ""
    echo "You may need to kill the existing process with:"
    echo "kill $PID"
    echo "And then restart the server"
  fi
fi
