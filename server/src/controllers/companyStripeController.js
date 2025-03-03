const loadConfig = require('../config');  // Import loadConfig function

// Import MongoDB models
const ClientMachine = require('../mongodb_server/models/clientMachine');
const Product = require('../mongodb_server/models/product');
const Section = require('../mongodb_server/models/section');
const Transaction = require('../mongodb_server/models/transaction');
const StripeAccount = require('../mongodb_server/models/stripeAccount');
//? just in case, this import of the subs are meant to be used for only deleting subs?!!
const Subscription = require('../mongodb_server/models/subscription');

let stripe;

(async () => {
  try {
    const config = await loadConfig();  // Load the configuration from Google Secret Manager
    stripe = require('stripe')(config.STRIPE_SECRET_KEY, {
      apiVersion: config.STRIPE_API_VERSION,
    });
  } catch (error) {
    console.error('Error initializing Stripe:', error);
  }
})();

exports.createStripeAccount = async (req, res) => {
  const { email, country, business_type } = req.body;
  const companyId = req.companyId; 

  console.log("Creating/Updating account with:", { email, country, business_type, companyId });

  try {
    if (!stripe) {
      throw new Error("Stripe is not properly initialized.");
    }

    // Check if a StripeAccount already exists and update it, or create a new one
    let stripeAccount = await StripeAccount.findOneAndUpdate(
      { company_id: companyId },
      { 
        country: country,
        business_type: business_type,
        updated_at: new Date()
      },
      { 
        new: true, 
        upsert: true, 
        setDefaultsOnInsert: true,
        runValidators: true
      }
    );

    let accountLink;

    if (stripeAccount.stripe_account_id) {
      // Existing account, might want to refresh the account link
      console.log("Existing Stripe account updated in MongoDB:", stripeAccount.stripe_account_id);
      
      accountLink = await stripe.accountLinks.create({
        account: stripeAccount.stripe_account_id,
        refresh_url: "https://api.sellaos.com/reauth",
        return_url: "https://api.sellaos.com/return",
        type: "account_onboarding",
      });
    } else {
      // New account, create in Stripe
      const account = await stripe.accounts.create({
        type: "standard",
        country,
        email,
        business_type,
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
      });

      console.log("New Stripe account created:", account.id);

      accountLink = await stripe.accountLinks.create({
        account: account.id,
        refresh_url: "https://api.sellaos.com/reauth",
        return_url: "https://api.sellaos.com/return",
        type: "account_onboarding",
      });

      const accountDetails = await stripe.accounts.retrieve(account.id);

      // Update the newly created document with Stripe details
      stripeAccount = await StripeAccount.findOneAndUpdate(
        { company_id: companyId },
        {
          stripe_account_id: account.id,
          currency: accountDetails.default_currency,
          charges_enabled: accountDetails.charges_enabled,
          payouts_enabled: accountDetails.payouts_enabled,
          requirements: accountDetails.requirements,
        },
        { new: true }
      );

      console.log("New Stripe account data saved in MongoDB");
    }

    res.status(200).json({
      accountLink: accountLink.url,
      accountId: stripeAccount.stripe_account_id,
      chargesEnabled: stripeAccount.charges_enabled,
      payoutsEnabled: stripeAccount.payouts_enabled,
    });
  } catch (error) {
    console.error("Error in createStripeAccount:", error);
    console.error("Error stack:", error.stack);
    res.status(400).json({ error: error.message });
  }
};

exports.deleteAccount = async (req, res) => {
  const { companyId } = req.params;
  
  try {
    // 1. Delete MongoDB collections
    await Promise.all([
      ClientMachine.deleteMany({ company_id: companyId }),
      Product.deleteMany({ company_id: companyId }),
      Section.deleteMany({ company_id: companyId }),
      Transaction.deleteMany({ companyId: companyId })
    ]);

    console.log('MongoDB collections deleted');

    // 2. Cancel Stripe subscription
    const subscription = await Subscription.findOne({ company_id: companyId });

    if (subscription?.subscription_id) {
      await stripe.subscriptions.cancel(subscription.subscription_id);
      console.log('Stripe subscription canceled');
    }

    // 3. Delete Stripe managed account
    const stripeAccount = await StripeAccount.findOne({ company_id: companyId });

    if (stripeAccount?.stripe_account_id) {
      await stripe.accounts.del(stripeAccount.stripe_account_id);
      console.log('Stripe managed account deleted');
    }

    console.log('Company deleted from MongoDB');

    res.status(200).json({ message: 'Account successfully deleted' });
  } catch (error) {
    console.error('Error deleting account:', error);
    res.status(500).json({ error: 'Failed to delete account', details: error.message });
  }
};

exports.getStripeAccountId = async (req, res) => {
  try {
    const companyId = req.companyId;
    const stripeAccount = await StripeAccount.findOne({ company_id: companyId });

    if (!stripeAccount) {
      return res.status(404).json({ message: 'Stripe account not found for this company' });
    }

    res.json({ stripe_account_id: stripeAccount.stripe_account_id });
  } catch (error) {
    console.error('Error in getStripeAccountId:', error);
    res.status(500).json({ message: error.message });
  }
};

exports.getCompanyCountry = async (req, res) => {
  try {
    const companyId = req.companyId;
    const stripeAccount = await StripeAccount.findOne({ company_id: companyId });

    if (!stripeAccount) {
      return res.status(404).json({ message: 'Country not found for this company' });
    }

    res.json({ country: stripeAccount.country });
  } catch (error) {
    console.error('Error in getCompanyCountry:', error);
    res.status(500).json({ message: error.message });
  }
};

exports.getCompanyCurrency = async (req, res) => {
  try {
    const companyId = req.companyId;
    const stripeAccount = await StripeAccount.findOne({ company_id: companyId });

    if (!stripeAccount) {
      return res.status(404).json({ message: 'Currency not found for this company' });
    }

    res.json({ currency: stripeAccount.currency });
  } catch (error) {
    console.error('Error in getCompanyCurrency:', error);
    res.status(500).json({ message: error.message });
  }
};