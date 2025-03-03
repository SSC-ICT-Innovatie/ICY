// qrController.js
const loadConfig = require("../config");
const Product = require("../mongodb_server/models/product");

const Transaction = require("../mongodb_server/models/transaction");
const socketIo = require("../socket/socketIo");

let stripe;

(async () => {
  try {
    const config = await loadConfig(); // Load the configuration from Google Secret Manager
    stripe = require("stripe")(config.STRIPE_SECRET_KEY, {
      apiVersion: config.STRIPE_API_VERSION,
    });
  } catch (error) {
    console.error("Error initializing Stripe:", error);
  }
})();

exports.generateQR = async (req, res) => {
  const { currency, deviceId, products, quantities, stripeAccount } = req.body;
  const companyId = req.companyId;

  try {
    if (products.length !== quantities.length) {
      throw new Error("The number of products and quantities do not match.");
    }

    const lineItems = products.map((product, index) => {
      let price = parseFloat(product.price);
      if (product.is_in_bonus) {
        price = parseFloat(
          (price - (price * product.bonus_percentage) / 100).toFixed(2),
        );
      }
      return {
        price_data: {
          currency: currency,
          product_data: {
            name: product.name,
            description: product.info || "No description available",
            images: [product.image_url],
            metadata: {
              product_id: product.product_id,
            },
          },
          unit_amount: Math.round(price * 100),
        },
        quantity: quantities[index],
      };
    });

    console.log("Line items:", JSON.stringify(lineItems, null, 2));

    const session = await stripe.checkout.sessions.create(
      {
        line_items: lineItems,
        mode: "payment",
        success_url: `https://api.sellaos.com/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `https://api.sellaos.com/cancel`,
        metadata: {
          deviceId,
          companyId,
          product_ids: products.map((p) => p.product_id).join(","),
          stripeAccountId: stripeAccount,
        },
      },
      {
        stripeAccount: stripeAccount,
      },
    );

    console.log("Stripe session created:", session.id);

    const totalQuantity = quantities.reduce((sum, qty) => sum + qty, 0);
    const totalAmount = lineItems.reduce(
      (sum, item) => sum + (item.price_data.unit_amount * item.quantity) / 100,
      0,
    );

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
      transactionId: session.id,
      deviceId: deviceId,
      companyId: companyId,
      transactionDate: new Date(),
      paymentMethod: "pending",
      status: "pending",
      receiptUrl: "pending",
      productsBought: productsBought,
      totalQuantity: totalQuantity,
      totalAmount: totalAmount,
    });

    await transaction.save();

    res.status(200).json({
      // qrCode,
      sessionId: session.id,
      sessionUrl: session.url,
    });
  } catch (error) {
    console.error("Error in generateQR:", error);
    res.status(400).json({ error: error.message });
  }
};

exports.checkLatestTransactionStatus = async (req, res) => {
  const companyId = req.companyId;
  console.log("yaaay route checked ");

  try {
    const latestTransaction = await Transaction.findOne({ companyId })
      .sort({ transactionDate: -1 })
      .limit(1);

    if (!latestTransaction) {
      return res.status(404).json({
        status: "error",
        message: "No transactions found for this company",
      });
    }

    const isPaid = latestTransaction.status === "paid";

    res.json({
      status: isPaid ? "paid" : "unpaid",
      transactionId: latestTransaction.transactionId,
      amount: latestTransaction.totalAmount,
      date: latestTransaction.transactionDate,
      receiptUrl: latestTransaction.receiptUrl,
    });
  } catch (error) {
    console.error("Error checking latest transaction status:", error);
    res.status(500).json({
      status: "error",
      message: "An error occurred while checking the latest transaction status",
      details: error.message,
    });
  }
};
