const loadConfig = require("../config");
const Product = require("../mongodb_server/models/product");
const Transaction = require("../mongodb_server/models/transaction");

let stripe;

(async () => {
  try {
    const config = await loadConfig();
    stripe = require("stripe")(config.STRIPE_SECRET_KEY, {
      apiVersion: config.STRIPE_API_VERSION,
    });
  } catch (error) {
    console.error("Error initializing Stripe:", error);
  }
})();

exports.createConnectionToken = async (req, res) => {
  try {
    const connectionToken = await stripe.terminal.connectionTokens.create();
    console.log('Created connection token:', connectionToken.secret);
    res.status(200).json({ secret: connectionToken.secret });
  } catch (error) {
    console.error("Error creating connection token:", error);
    res.status(400).json({ error: error.message });
  }
};

exports.createPaymentIntent = async (req, res) => {
  const { amount, currency, deviceId } = req.body;
  const companyId = req.companyId;

  console.log(
    `Creating payment intent: Amount: ${amount}, Currency: ${currency}, DeviceID: ${deviceId}, CompanyID: ${companyId}`,
  );

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      metadata: { deviceId, companyId },
    });

    console.log(`Payment intent created: ${JSON.stringify(paymentIntent)}`);

    res.status(200).json({
      client_secret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    console.error("Error creating payment intent:", error);
    res.status(400).json({ error: error.message });
  }
};

exports.processPayment = async (req, res) => {
  const { paymentIntentId, paymentMethodId, products, quantities } = req.body;
  const companyId = req.companyId;

  try {
    const paymentIntent = await stripe.paymentIntents.confirm(paymentIntentId, {
      payment_method: paymentMethodId,
    });

    if (paymentIntent.status === "succeeded") {
      const totalQuantity = quantities.reduce((sum, qty) => sum + qty, 0);
      const totalAmount = paymentIntent.amount / 100; // Convert cents to dollars

      const productsBought = products.map((product, index) => ({
        sectionId: product.section_id,
        productId: product.product_id,
        name: product.name,
        imageUrl: product.image_url,
        date: new Date(),
        wasInBonus: product.is_in_bonus,
        bonusPrice: product.is_in_bonus
          ? product.price * (1 - product.bonus_percentage / 100)
          : null,
        priceBought: product.price,
        quantity: quantities[index],
      }));

      const transaction = new Transaction({
        transactionId: paymentIntent.id,
        deviceId: paymentIntent.metadata.deviceId,
        companyId: companyId,
        transactionDate: new Date(),
        paymentMethod: "nfc",
        status: "paid",
        receiptUrl: paymentIntent.charges.data[0]?.receipt_url || null,
        productsBought: productsBought,
        totalQuantity: totalQuantity,
        totalAmount: totalAmount,
      });

      await transaction.save();

      res.status(200).json({
        status: "succeeded",
        transactionId: paymentIntent.id,
      });
    } else {
      res.status(400).json({ error: "Payment failed" });
    }
  } catch (error) {
    console.error("Error processing payment:", error);
    res.status(400).json({ error: error.message });
  }
};
