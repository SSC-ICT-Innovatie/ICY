const loadConfig = require("../config");  // Correct import
const Transaction = require("../mongodb_server/models/transaction");

let stripe;

(async () => {
  try {
    const config = await loadConfig();  // Ensure loadConfig is called correctly
    stripe = require('stripe')(config.STRIPE_SECRET_KEY);
  } catch (error) {
    console.error('Error initializing Stripe:', error);
  }
})();

exports.sendReceipt = async (req, res) => {
  console.log("Received request to send receipt:", req.body);
  const { transactionId, stripeAccountId } = req.body;

  try {
    const transaction = await Transaction.findOne({ transactionId });
    console.log("Found transaction:", transaction);

    if (!transaction) {
      return res.status(404).json({ error: "Transaction not found in our records" });
    }

    if (!stripeAccountId) {
      return res.status(400).json({ error: "Stripe account ID is required" });
    }

    try {
      console.log(`Retrieving payment intent ${transactionId} for account ${stripeAccountId}`);
      const paymentIntent = await stripe.paymentIntents.retrieve(
        transactionId,
        { stripeAccount: stripeAccountId }
      );
      console.log("Retrieved payment intent:", paymentIntent);

      if (
        paymentIntent.latest_charge &&
        paymentIntent.latest_charge.startsWith("py_")
      ) {
        // This is a Bancontact payment
        console.log("Bancontact payment detected");

        if (transaction.receiptUrl) {
          console.log("Receipt URL found:", transaction.receiptUrl);
          return res.status(200).json({
            message: "Receipt URL available",
            receiptUrl: transaction.receiptUrl,
          });
        } else {
          return res.status(400).json({ error: "No receipt URL available for this transaction" });
        }
      }

      if (!paymentIntent.charges || paymentIntent.charges.data.length === 0) {
        console.log("No charges found for payment intent:", paymentIntent.id);
        return res.status(400).json({ error: "No charge found for this payment intent" });
      }

      const charge = paymentIntent.charges.data[0];
      console.log("Found charge:", charge.id);

      if (!charge.receipt_email) {
        return res.status(400).json({ error: "EMAIL_NOT_FOUND" });
      }

      console.log(`Sending receipt for charge ${charge.id} to ${charge.receipt_email}`);
      await stripe.charges.sendReceipt(charge.id, {
        stripeAccount: stripeAccountId,
      });

      console.log("Receipt sent successfully");
      res.status(200).json({ message: "Receipt sent successfully" });
    } catch (stripeError) {
      console.error("Stripe API Error:", stripeError);
      if (stripeError.type === "StripePermissionError") {
        return res.status(403).json({
          error: "Permission denied: Unable to access the Stripe account",
        });
      }
      return res.status(500).json({
        error: "Error interacting with Stripe API",
        details: stripeError.message,
      });
    }
  } catch (error) {
    console.error("Server Error:", error);
    res.status(500).json({ error: "Internal server error", details: error.message });
  }
};

