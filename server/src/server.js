const express = require("express");
const axios = require('axios');
const http = require("http");
const helmet = require("helmet");
const cors = require("cors");
const mongoose = require("mongoose");
const authenticateToken = require("./middleware/authenticateToken");
const loadConfig = require("./config");
const path = require("path");
const fs = require("fs");
const connectToDatabase = require("./mongodb_server/db");
const Transaction = require("./mongodb_server/models/transaction");

const { handleSubscriptionWebhook } = require("./webhooks/subscriptionWebhook");
const { handleStripeWebhook } = require("./webhooks/transactionWebhook");

async function startServer() {
  try {
    const config = await loadConfig();
    const app = express();
    const server = http.createServer(app);
    
    app.set('trust proxy', 1);
    app.use(helmet());

    const corsOptions = {
      origin: function (origin, callback) {
        const allowedOrigins = [
          "https://app.sellaos.com",
          "https://sellaos.com",
          "https://api.sellaos.com",
          "https://pos.sellaos.com",
          "https://www.pos.sellaos.com"
          // Add "http://localhost:3000" for local development if needed
        ];
        if (!origin || allowedOrigins.indexOf(origin) !== -1) {
          callback(null, true);
        } else {
          console.log("Origin not allowed by CORS:", origin);
          callback(new Error("Not allowed by CORS"));
        }
      },
      credentials: true,
      methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
      allowedHeaders: [
        "Content-Type", 
        "Authorization",
        "Origin",
        "X-Requested-With",
        "Accept"
      ],
      exposedHeaders: ['Content-Range', 'X-Content-Range'],
      maxAge: 86400 // 24 hours
    };

    app.use(cors(corsOptions));

    // Cors loggings for easy debug
    app.use((req, res, next) => {
      console.log("Incoming request origin:", req.headers.origin);
      cors(corsOptions)(req, res, next);
    });

    // Json Parsing middleware
    app.use((req, res, next) => {
      if (
        req.originalUrl === "/webhooks/subscription" ||
        req.originalUrl === "/webhooks/transaction"
      ) {
        next();
      } else if (req.method !== "GET" && req.method !== "DELETE") {
        express.json()(req, res, next);
      } else {
        next();
      }
    });

    // Stripe webhook routes
    app.post(
      "/webhooks/subscription",
      express.raw({ type: "application/json" }),
      handleSubscriptionWebhook,
    );

    app.post(
      "/webhooks/transaction",
      express.raw({ type: "application/json" }),
      handleStripeWebhook,
    );

    // Regular body parsing middleware for other routes
    app.use(express.urlencoded({ extended: true }));

    // Connect to MongoDB
    await connectToDatabase();
    console.log("Connected to MongoDB");

    // Route imports
    const accountRoutes = require("./routes/accountRoutes");
    const qrRoutes = require("./routes/qrRoutes");
    const refundRoutes = require("./routes/refundRoutes");
    const receiptRoutes = require("./routes/receiptRoutes");
    const subscriptionRoutes = require("./routes/subscriptionPaymentMethodRoutes");
    const sectionRoutes = require("./mongodb_server/routes/sectionRoutes");
    const productRoutes = require("./mongodb_server/routes/productRoutes");
    const clientMachineRoutes = require("./mongodb_server/routes/clientMachineRoutes");
    const transactionRoutes = require("./mongodb_server/routes/transactionRoutes");
    const nfcRoutes = require("./routes/nfcRoutes");
    const authRoutes = require("./routes/authRoutes");
    const aiRoutes = require("./routes/aiRoutes");
    // Routes
    app.use("/api/auth", authRoutes);
    app.use("/api/client_machines", authenticateToken, clientMachineRoutes);
    app.use("/api/sections", authenticateToken, sectionRoutes);
    app.use("/api/products", authenticateToken, productRoutes);
    app.use("/api/transactions", authenticateToken, transactionRoutes);
    app.use("/api/", accountRoutes);
    app.use("/api/refunds", refundRoutes);
    app.use("/api/qr", qrRoutes);
    app.use("/api/nfc", nfcRoutes);
    app.use("/api/receipts", authenticateToken, receiptRoutes);
    app.use("/api/subscriptions", subscriptionRoutes);
    app.use("/api/ai", aiRoutes);

    // Function to read HTML files
    function sendHtmlFile(filename) {
      return (req, res) => {
        const filePath = path.join(__dirname, "pages", filename);
        fs.readFile(filePath, "utf8", (err, data) => {
          if (err) {
            console.error(`Error reading file ${filename}:`, err);
            return res.status(500).send("Internal Server Error");
          }
          res.send(data);
        });
      };
    }
    // ?
    // Route handlers for HTML pages
    app.get("/return", sendHtmlFile("return.html"));
    app.get("/reauth", sendHtmlFile("reauth.html"));
    app.get("/cancelled", sendHtmlFile("cancelled.html"));
    app.get("/subscription-success", sendHtmlFile("subscriptionSuccess.html"));
    
    // download route
    app.get('/download-receipt/:sessionId', async (req, res) => {
        try {
            const transaction = await Transaction.findOne({
                $or: [
                    { sessionId: req.params.sessionId },
                    { transactionId: req.params.sessionId }
                ]
            });
    
            if (!transaction?.receiptUrl) {
                return res.status(404).send('Receipt not found');
            }
    
            // Fetch the receipt from Stripe
            const response = await axios({
                method: 'GET',
                url: transaction.receiptUrl,
                responseType: 'arraybuffer'
            });
    
            // Set headers for file download
            res.setHeader('Content-Type', 'application/pdf');
            res.setHeader('Content-Disposition', `attachment; filename=receipt-${transaction.transactionId}.pdf`);
            
            // Send the file
            res.send(response.data);
        } catch (error) {
            console.error('Download error:', error);
            res.status(500).send('Error downloading receipt');
        }
    });
    //
    app.get("/success", async (req, res) => {
        const sessionId = req.query.session_id;
        console.log('Success route hit with session ID:', sessionId);
    
        try {
            if (!sessionId) {
                console.log('No session ID provided');
                return sendHtmlFile("success.html")(req, res);
            }
    
            const transaction = await Transaction.findOne({
                $or: [
                    { sessionId: sessionId },
                    { transactionId: sessionId }
                ]
            });
            console.log('Found transaction:', transaction);
    
            if (!transaction || !transaction.receiptUrl) {
                console.log('No transaction or receipt URL found');
                return sendHtmlFile("success.html")(req, res);
            }
    
            console.log('Found receipt URL:', transaction.receiptUrl);
    
            const successHtml = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,200..800&display=swap" rel="stylesheet">
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Payment Success</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
        <style>
            body {
                background: linear-gradient(135deg, #f5f7fa 0%, #e4e8eb 100%);
                font-family: 'Bricolage Grotesque', Arial, sans-serif;
                min-height: 100vh;
                margin: 0;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }
    
            .container {
                max-width: 600px;
                width: 90%;
                margin: 0 auto;
                padding: 40px 20px;
                background-color: #fff;
                border-radius: 20px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.1);
                display: flex;
                flex-direction: column;
                align-items: center;
            }
    
            h1 {
                text-align: center;
                color: #2d3748;
                font-size: clamp(24px, 5vw, 32px);
                margin-bottom: 20px;
                width: 100%;
            }
    
            p {
                text-align: center;
                color: #4a5568;
                font-size: clamp(16px, 3vw, 18px);
                line-height: 1.6;
                width: 100%;
            }
    
            .success-icon {
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 30px;
                width: 80px;
                height: 80px;
                background-color: #414EDE;
                border-radius: 50%;
                color: #fff;
                font-size: 40px;
                animation: bounceIn 1s ease-out;
            }
    
            .message {
                text-align: center;
                margin: 20px 0;
                font-size: clamp(16px, 3vw, 18px);
                color: #4a5568;
                width: 100%;
            }
    
            .receipt-container {
                margin: 30px 0;
                padding: 20px;
                background: #f7fafc;
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                width: calc(100% - 40px);
                display: flex;
                flex-direction: column;
                align-items: center;
            }
    
            .receipt-preview {
                width: 100%;
                min-height: 200px;
                border-radius: 8px;
                margin-bottom: 20px;
                background: #fff;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-direction: column;
                gap: 15px;
                padding: 20px;
                box-sizing: border-box;
            }
    
            .buttons-container {
                display: flex;
                gap: 15px;
                justify-content: center;
                width: 100%;
            }
    
            .button {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 12px 24px;
                background-color: #414EDE;
                color: #fff;
                text-decoration: none;
                border-radius: 10px;
                font-size: clamp(16px, 3vw, 18px);
                transition: all 0.3s ease;
                border: none;
                cursor: pointer;
                box-shadow: 0 4px 6px rgba(65, 78, 222, 0.2);
                flex: 1;
                max-width: 200px;
            }
    
            .button:hover {
                background-color: #3540b8;
                transform: translateY(-2px);
                box-shadow: 0 6px 8px rgba(65, 78, 222, 0.3);
                color: #fff;
                text-decoration: none;
            }
    
            .button.secondary {
                background-color: #fff;
                color: #414EDE;
                border: 2px solid #414EDE;
            }
    
            .button.secondary:hover {
                background-color: #f8f9ff;
                color: #3540b8;
                border-color: #3540b8;
            }
    
            .button i {
                margin-right: 8px;
            }
    
            @keyframes bounceIn {
                0% { transform: scale(0); }
                50% { transform: scale(1.2); }
                100% { transform: scale(1); }
            }
    
            @media (max-width: 480px) {
                .container {
                    padding: 30px 15px;
                }
                
                .buttons-container {
                    flex-direction: column;
                    align-items: stretch;
                }
                
                .button {
                    max-width: none;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="success-icon">
                <i class="fas fa-check"></i>
            </div>
            <h1>Payment Successful</h1>
            <p class="message">Your payment has been processed successfully.</p>
            
            <div class="receipt-container">
                <div class="receipt-preview">
                    <i class="fas fa-receipt" style="font-size: 48px; color: #414EDE;"></i>
                    <p style="margin: 0; font-size: 18px;">Your receipt is ready</p>
                </div>
                
                <a href="${transaction.receiptUrl}" class="button secondary" target="_blank">
                        <i class="fas fa-eye"></i>
                        View Receipt
                </a>
            </div>
        </div>
    
        
    </body>
    </html>`;
    
            res.send(successHtml);
    
        } catch (error) {
            console.error('Error processing success page:', error);
            sendHtmlFile("success.html")(req, res);
        }
    });
    //?
    const PORT = config.PORT || 4105;
    server.listen(PORT, "0.0.0.0", () => {
      console.log(`Server is running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
}

startServer();
