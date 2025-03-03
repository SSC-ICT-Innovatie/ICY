//! Set this line to false for production:
const DEBUG = false; 
// 
async function loadConfig() {
  return {
    DEBUG: DEBUG,
    OPENAI_API_KEY: process.env.OPENAI_API_KEY,
    STRIPE_API_VERSION: process.env.STRIPE_API_VERSION,
    DOMAIN: "https://api.sellaos.com",
    // Updated to return string directly based on DEBUG
    STRIPE_WEBHOOK_SECRET_SUBSCRIPTION: DEBUG 
      ? process.env.DEMO_STRIPE_WEBHOOK_SECRET_SUBSCRIPTION
      : process.env.STRIPE_WEBHOOK_SECRET_SUBSCRIPTION,
    JWT_SECRET: process.env.JWT_SECRET,
    SMTP_HOST: process.env.SMTP_HOST,
    SMTP_PORT: process.env.SMTP_PORT,
    SMTP_USER: process.env.SMTP_USER,
    SMTP_PASS: process.env.SMTP_PASS,
    // Updated to return string directly based on DEBUG
    STRIPE_WEBHOOK_SECRET_TRANSACTION: DEBUG
      ? process.env.DEMO_STRIPE_WEBHOOK_SECRET_TRANSACTION
      : process.env.STRIPE_WEBHOOK_SECRET_TRANSACTION,
    // Already using string approach
    STRIPE_SECRET_KEY: DEBUG 
      ? process.env.DEMO_STRIPE_SECRET_KEY
      : process.env.STRIPE_SECRET_KEY,
    STRIPE_BASIC_MONTHLY_PRICE_ID: DEBUG
      ? process.env.DEMO_STRIPE_BASIC_MONTHLY_PRICE_ID
      : process.env.STRIPE_BASIC_MONTHLY_PRICE_ID,
    STRIPE_BASIC_YEARLY_PRICE_ID: DEBUG
      ? process.env.DEMO_STRIPE_BASIC_YEARLY_PRICE_ID
      : process.env.STRIPE_BASIC_YEARLY_PRICE_ID,
    STRIPE_PRO_MONTHLY_PRICE_ID: DEBUG
      ? process.env.DEMO_STRIPE_PRO_MONTHLY_PRICE_ID
      : process.env.STRIPE_PRO_MONTHLY_PRICE_ID,
    STRIPE_PRO_YEARLY_PRICE_ID: DEBUG
      ? process.env.DEMO_STRIPE_PRO_YEARLY_PRICE_ID
      : process.env.STRIPE_PRO_YEARLY_PRICE_ID,
    STRIPE_ENTERPRISE_MONTHLY_PRICE_ID: DEBUG
      ? process.env.DEMO_STRIPE_ENTERPRISE_MONTHLY_PRICE_ID
      : process.env.STRIPE_ENTERPRISE_MONTHLY_PRICE_ID,
    STRIPE_ENTERPRISE_YEARLY_PRICE_ID: DEBUG
      ? process.env.DEMO_STRIPE_ENTERPRISE_YEARLY_PRICE_ID
      : process.env.STRIPE_ENTERPRISE_YEARLY_PRICE_ID,
    DB_HOST: process.env.DB_HOST,
    DB_PASS: process.env.DB_PASS,
    DB_USRNAME: process.env.DB_USRNAME,
  };
}
module.exports = loadConfig;