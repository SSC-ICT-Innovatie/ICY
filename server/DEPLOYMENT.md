# ICY Server Deployment Guide

This guide provides instructions for deploying the ICY server in development and production environments.

## Development Setup

1. Clone the repository
2. Install dependencies:
   ```
   npm install
   ```
3. Set up environment variables:
   - Copy `.env.example` to `.env`
   - Update the MongoDB connection string and other settings as needed
4. Start the server:
   ```
   npm start
   ```

## Production Deployment

### Prerequisites
- Node.js 16+ installed on your server
- MongoDB Atlas account (or other MongoDB deployment)
- PM2 for process management (installed automatically by deploy script)

### Deployment Steps

1. Prepare your production environment file:
   - Copy `.env.production` to `.env` on the production server
   - Update all settings marked for replacement, especially:
     - Database connection string
     - JWT secrets
     - Admin password
     - Email configuration

2. Run the deployment script:
   ```
   sudo ./scripts/deploy.sh
   ```
   
3. Verify the deployment:
   ```
   pm2 status
   pm2 logs icy-server
   ```

### Environment Variables to Update for Production

- `MONGODB_URI`: Your production MongoDB connection string
- `JWT_SECRET` and `REFRESH_TOKEN_SECRET`: New secure random strings
- `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_USER`, `EMAIL_PASS`: Production email service credentials
- `CORS_ORIGIN`: List of allowed origins (your frontend domains)
- `ADMIN_EMAIL` and `ADMIN_PASSWORD`: Production admin credentials

### SSL Configuration

The application expects to be deployed behind a reverse proxy (like Nginx) that handles SSL termination. If you need to configure SSL directly in the app, modify the `index.js` file to use HTTPS.

## Switching Between Environments

### Server:
- Development: Uses the `.env` file with `NODE_ENV=development`
- Production: Uses the `.env` file with `NODE_ENV=production`

### Client:
To switch the Flutter client between environments:
1. Open `lib/abstractions/utils/api_constants.dart`
2. Change `isProduction` to `true` for production or `false` for development
3. Rebuild the application
