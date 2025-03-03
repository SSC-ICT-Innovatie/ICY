const Stripe = require('stripe');
const loadConfig = require('../config');
const Transaction = require("../mongodb_server/models/transaction");
const Product = require("../mongodb_server/models/product");

let stripe;

(async () => {
    try {
        const config = await loadConfig();
        stripe = new Stripe(config.STRIPE_SECRET_KEY);
    } catch (error) {
        console.error('Error initializing Stripe:', error);
    }
})();

exports.handleStripeWebhook = async (req, res) => {
    if (!stripe) {
        console.error('Stripe not initialized.');
        return res.status(500).send('Server not ready to handle webhooks');
    }

    const sig = req.headers["stripe-signature"];
    let event;

    try {
        const config = await loadConfig();
        event = stripe.webhooks.constructEvent(
            req.body, // Express.raw() makes this the raw body
            sig,
            config.STRIPE_WEBHOOK_SECRET_TRANSACTION
        );
    } catch (err) {
        console.error("Webhook signature verification failed:", err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    console.log("Received event:", event.type, "for account:", event.account);
    console.log("Full event object:", JSON.stringify(event, null, 2));

    try {
        switch (event.type) {
            case "checkout.session.completed":
                console.log("Handling checkout.session.completed");
                await handleCheckoutSessionCompleted(event.data.object);
                break;
            case "checkout.session.expired":
                console.log("Handling checkout.session.expired");
                await handleCheckoutSessionExpired(event.data.object);
                break;
            case "payment_intent.succeeded":
                console.log("Handling payment_intent.succeeded");
                await handlePaymentIntentSucceeded(event.data.object);
                break;
            case "payment_intent.payment_failed":
                console.log("Handling payment_intent.payment_failed");
                await handlePaymentIntentFailed(event.data.object);
                break;
            case "charge.succeeded":
                console.log("Handling charge.succeeded");
                await handleChargeSucceeded(event.data.object);
                break;
            case "charge.failed":
                console.log("Handling charge.failed");
                await handleChargeFailed(event.data.object);
                break;
            case "charge.refunded":
                console.log("Handling charge.refunded");
                await handleChargeRefunded(event.data.object);
                break;
            default:
                console.log(`Unhandled event type ${event.type}`);
        }

        res.json({ received: true });
    } catch (err) {
        console.error("Error processing webhook:", err);
        res.status(500).send(`Webhook processing error: ${err.message}`);
    }
};

async function handleCheckoutSessionCompleted(session) {
    try {
        const paymentIntent = await stripe.paymentIntents.retrieve(
            session.payment_intent,
            {
                stripeAccount: session.metadata.stripeAccountId,
            }
        );
        console.log("PaymentIntent:", JSON.stringify(paymentIntent, null, 2));

        let transaction = await Transaction.findOne({
            transactionId: session.id,
        });

        if (!transaction) {
            console.log("Transaction not found for session ID:", session.id);
            return;
        }
        
        transaction.sessionId = session.id;
        transaction.transactionId = paymentIntent.id;
        

        const lineItems = await stripe.checkout.sessions.listLineItems(
            session.id,
            { expand: ['data.price.product'] },
            {
                stripeAccount: session.metadata.stripeAccountId,
            }
        );

        console.log("Line items:", JSON.stringify(lineItems, null, 2));

        let paymentMethod;
        let receiptUrl = null;

        const paymentMethodDetails = await stripe.paymentMethods.retrieve(
            paymentIntent.payment_method,
            {
                stripeAccount: session.metadata.stripeAccountId,
            }
        );
        paymentMethod = paymentMethodDetails.type;

        if (paymentIntent.latest_charge) {
            const charge = await stripe.charges.retrieve(
                paymentIntent.latest_charge,
                {
                    stripeAccount: session.metadata.stripeAccountId,
                }
            );
            receiptUrl = charge.receipt_url;
        } else {
            console.log("No latest_charge found on PaymentIntent");
        }

        transaction.transactionDate = new Date(session.created * 1000);
        transaction.paymentMethod = paymentMethod;
        transaction.status = session.payment_status;
        transaction.receiptUrl = receiptUrl;
        transaction.stripeAccountId = session.metadata.stripeAccountId;

        for (let i = 0; i < transaction.productsBought.length; i++) {
            const product = transaction.productsBought[i];
            const lineItem = lineItems.data[i];

            const updatedProduct = await Product.findOneAndUpdate(
                { product_id: product.productId, company_id: session.metadata.companyId },
                { $inc: { item_number: -lineItem.quantity } },
                { new: true }
            );

            if (!updatedProduct) {
                console.warn(`Product not found: ${product.productId}`);
            } else {
                console.log(`Updated stock for product ${updatedProduct.product_id}: ${updatedProduct.item_number}`);
            }

            product.priceBought = lineItem.price.unit_amount / 100;
            product.quantity = lineItem.quantity;
        }

        transaction.totalQuantity = lineItems.data.reduce(
            (sum, item) => sum + item.quantity,
            0
        );
        transaction.totalAmount = session.amount_total / 100;

        await transaction.save();
        console.log("Transaction updated in MongoDB");

    } catch (error) {
        console.error("Error handling checkout.session.completed:", error);
        throw error;
    }
}

async function handleCheckoutSessionExpired(session) {
    console.log("Checkout session expired:", session.id);
    try {
        await Transaction.findOneAndDelete({ transactionId: session.id });
        console.log(`Transaction deleted for expired session ID: ${session.id}`);
    } catch (error) {
        console.error("Error handling checkout.session.expired:", error);
        throw error;
    }
}

async function handlePaymentIntentSucceeded(paymentIntent) {
    console.log("Payment intent succeeded:", paymentIntent.id);
    // Add any additional logic for successful payment intents if needed
}

async function handlePaymentIntentFailed(paymentIntent) {
    console.log("Payment intent failed:", paymentIntent.id);
    console.log("Failure reason:", paymentIntent.last_payment_error?.message);
    // Add logic to update transaction status and handle the failure
}

async function handleChargeSucceeded(charge) {
    console.log("Charge succeeded:", charge.id);
    // Add logic to update transaction status if needed
}

async function handleChargeFailed(charge) {
    console.log("Charge failed:", charge.id);
    console.log("Failure reason:", charge.failure_message);
    // Add logic to update transaction status and handle the failure
}

async function handleChargeRefunded(charge) {
    console.log("Charge refunded:", charge.id);
    // Add logic to handle refunds, update transaction status, etc.
}

module.exports = exports;const { json } = require('express');
const { body } = require('express-validator');
const { error, log, warn } = require('winston');
const { findOne, findOneAndUpdate, findOneAndDelete } = require('../mongodb_server/models/clientMachine');
