const loadConfig = require('../config');
const stripe = require('stripe');
const Subscription = require('../mongodb_server/models/subscription');
const UserAcc = require('../mongodb_server/models/user');

let stripeInstance;
let webhookSecret;
let config;

async function initializeStripe() {
  config = await loadConfig();
  // Direct string access instead of object access
  stripeInstance = stripe(config.STRIPE_SECRET_KEY);
  webhookSecret = config.STRIPE_WEBHOOK_SECRET_SUBSCRIPTION;
  
  // Debug logging
  console.log('Stripe initialized with webhook secret:', !!webhookSecret);
}

async function handleSubscriptionWebhook(req, res) {
  try {
    if (!stripeInstance || !webhookSecret) {
      await initializeStripe();
    }

    if (!webhookSecret) {
      console.error('Webhook secret is undefined');
      return res.status(500).send('Webhook secret not configured');
    }

    const sig = req.headers['stripe-signature'];
    console.log('Received webhook signature:', !!sig);

    let event;
    try {
      event = stripeInstance.webhooks.constructEvent(
        req.body,
        sig,
        webhookSecret
      );
      console.log('Webhook event constructed:', event.type);
    } catch (err) {
      console.error(`Webhook Error:`, err);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Handle the event
    switch (event.type) {
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
      case 'customer.subscription.deleted':
        const subscription = event.data.object;
        await handleSubscriptionChange(subscription);
        break;
      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    res.json({received: true});
  } catch (error) {
    console.error('Error handling webhook:', error);
    res.status(500).send('Internal server error');
  }
}

async function handleSubscriptionChange(subscription) {
  const companyId = subscription.metadata.company_id;
  const status = subscription.status;
  const currentPeriodEnd = new Date(subscription.current_period_end * 1000);

  try {
    const updatedSubscription = await Subscription.findOneAndUpdate(
      { company_id: companyId },
      {
        stripe_customer_id: subscription.customer,
        subscription_id: subscription.id,
        status: status,
        current_period_end: currentPeriodEnd,
        plan: subscription.metadata.plan,
        billingCycle: subscription.metadata.billingCycle,
        updated_at: new Date()
      },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    console.log(`Subscription updated for company ${companyId}:`, updatedSubscription);

    // Update user account if needed
    await UserAcc.findOneAndUpdate(
      { company_id: companyId },
      { $set: { 'subscription.status': status } }
    );

    console.log(`User account updated for company ${companyId}`);
  } catch (error) {
    console.error('Error updating subscription:', error);
  }
}

module.exports = { handleSubscriptionWebhook };