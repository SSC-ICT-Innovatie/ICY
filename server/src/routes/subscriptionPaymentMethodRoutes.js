const express = require('express');
const router = express.Router();
const loadConfig = require('../config');
const Subscription = require('../mongodb_server/models/subscription');
const UserAcc = require('../mongodb_server/models/user');
const authenticateToken = require('../middleware/authenticateToken');

let stripe;
let config;

// Initialize config and stripe at the start
(async () => {
  config = await loadConfig();
  stripe = require('stripe')(config.STRIPE_SECRET_KEY);
})();

router.post('/create-checkout-session', authenticateToken, async (req, res) => {
  try {
    // Make sure config is loaded
    if (!config) {
      config = await loadConfig();
      stripe = require('stripe')(config.STRIPE_SECRET_KEY);
    }

    console.log('Received request to create checkout session:', req.body);
    const { planName, billingCycle } = req.body;
    const companyId = req.companyId;

    // Fetch company details
    const company = await UserAcc.findOne({ company_id: companyId }).select('company_id email');
    if (!company) {
      throw new Error('Company not found');
    }

    // Normalize planName to ensure consistency
    const normalizedPlanName = planName.toLowerCase().replace(/\s+/g, '');
    
    // Construct priceIdKey with fallback options
    const priceIdKey = `STRIPE_${normalizedPlanName.toUpperCase()}_${billingCycle.toUpperCase()}_PRICE_ID`;
    const priceId = config[priceIdKey];

    console.log('Normalized Plan Name:', normalizedPlanName);
    console.log('Price ID Key:', priceIdKey);
    console.log('Selected Price ID:', priceId);

    if (!priceId) {
      throw new Error(`Price ID not found for ${planName} ${billingCycle} plan`);
    }

    console.log('Creating Stripe checkout session with price ID:', priceId);

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{ price: priceId, quantity: 1 }],
      mode: 'subscription',
      allow_promotion_codes: true,
      success_url: `${config.DOMAIN}/subscription-success`,
      cancel_url: `${config.DOMAIN}/subscription-error`,
      client_reference_id: companyId,
      customer_email: company.email,
      metadata: { company_id: companyId, plan: planName, billingCycle },
      subscription_data: { metadata: { company_id: companyId, plan: planName, billingCycle } },
    });

    console.log('Checkout session created:', session.id);
    res.json({ url: session.url });
  } catch (error) {
    console.error('Error creating checkout session:', error);
    res.status(500).json({ 
      error: 'Failed to create checkout session', 
      details: error.message 
    });
  }
});


  router.get('/check-status', authenticateToken, async (req, res) => {
    const companyId = req.companyId;
    try {
      const subscription = await Subscription.findOne({ company_id: companyId }).select('status');
      res.json({ status: subscription?.status || 'inactive' });
    } catch (error) {
      console.error('Error checking subscription status:', error);
      res.status(500).json({ error: 'Failed to check subscription status' });
    }
  });

  router.post('/cancel', authenticateToken, async (req, res) => {
    try {
      // Make sure config is loaded
      if (!config) {
        config = await loadConfig();
        stripe = require('stripe')(config.STRIPE_SECRET_KEY);
      }
  
      const companyId = req.companyId;
      console.log('Attempting to cancel subscription for company:', companyId);
  
      const subscription = await Subscription.findOne({ company_id: companyId });
      
      if (!subscription) {
        console.log('No subscription found for company:', companyId);
        return res.status(404).json({ error: 'No active subscription found' });
      }
  
      if (!subscription.subscription_id) {
        console.log('No Stripe subscription ID found for company:', companyId);
        return res.status(404).json({ error: 'No active Stripe subscription found' });
      }
  
      console.log('Cancelling Stripe subscription:', subscription.subscription_id);
  
      await stripe.subscriptions.update(subscription.subscription_id, {
        cancel_at_period_end: true
      });
  
      await Subscription.updateOne(
        { company_id: companyId }, 
        { 
          status: 'canceled',
          updated_at: new Date()
        }
      );
  
      console.log('Subscription cancelled successfully');
      res.json({ 
        success: true,
        message: 'Subscription will be cancelled at the end of the current billing period'
      });
    } catch (error) {
      console.error('Error cancelling subscription:', error);
      res.status(500).json({ error: 'Failed to cancel subscription', details: error.message });
    }
  });

  // Details route
  router.get('/details', authenticateToken, async (req, res) => {
    try {
      // Wait for stripe to be initialized
      if (!stripe) {
        const config = await loadConfig();
        stripe = require('stripe')(config.STRIPE_SECRET_KEY);
      }
  
      const companyId = req.companyId;
      const subscription = await Subscription.findOne({ company_id: companyId });
      
      if (!subscription) {
        return res.status(404).json({ error: 'No active subscription found' });
      }
  
      try {
        const stripeSubscription = await stripe.subscriptions.retrieve(
          subscription.subscription_id // Make sure you're using subscription_id, not stripe_customer_id
        );
  
        const subscriptionDetails = {
          status: stripeSubscription.status,
          currentPeriodEnd: new Date(stripeSubscription.current_period_end * 1000).toISOString(),
          cancelAtPeriodEnd: stripeSubscription.cancel_at_period_end,
          plan: subscription.plan,
          billingCycle: subscription.billingCycle
        };
  
        res.json(subscriptionDetails);
      } catch (stripeError) {
        console.error('Stripe API Error:', stripeError);
        res.status(500).json({ 
          error: 'Failed to fetch subscription details from Stripe',
          details: stripeError.message 
        });
      }
    } catch (error) {
      console.error('Error fetching subscription details:', error);
      res.status(500).json({ error: 'Failed to fetch subscription details' });
    }
  });



module.exports = router;