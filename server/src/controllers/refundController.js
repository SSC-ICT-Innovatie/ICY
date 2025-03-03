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

exports.processRefund = async (req, res) => {
  const { transactionId, stripeAccountId } = req.body;

  try {
    const transaction = await Transaction.findOne({ transactionId });

    if (!transaction) {
      return res.status(404).json({ error: "Transaction not found in our records" });
    }

    if (transaction.status === "refunded") {
      return res.status(400).json({ error: "This transaction has already been refunded" });
    }

    try {
      const refund = await stripe.refunds.create(
        {
          payment_intent: transactionId,
          amount: Math.round(transaction.totalAmount * 100), // Convert to cents
        },
        {
          stripeAccount: stripeAccountId,
        }
      );

      // Update the transaction status in the database
      transaction.status = "refunded";
      transaction.refundId = refund.id;
      transaction.refundDate = new Date();
      await transaction.save();

      res.status(200).json({
        message: "Refund processed successfully",
        refundId: refund.id,
        amount: refund.amount / 100, // Convert back to dollars
        status: refund.status,
      });
    } catch (stripeError) {
      console.error("Stripe API Error:", stripeError);
      if (stripeError.type === "StripePermissionError") {
        return res.status(403).json({
          error: "Permission denied: Unable to process refund on this Stripe account",
        });
      }
      return res.status(500).json({
        error: "Error processing refund with Stripe",
        details: stripeError.message,
      });
    }
  } catch (error) {
    console.error("Server Error:", error);
    res.status(500).json({ error: "Internal server error", details: error.message });
  }
};
