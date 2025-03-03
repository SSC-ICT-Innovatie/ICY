const Transaction = require("../mongodb_server/models/transaction");
const Subscription = require("../mongodb_server/models/subscription");

const BASIC_MONTHLY_LIMIT = 1000;

const checkTransactionLimits = async (req, res, next) => {
  try {
    const companyId = req.companyId;
    console.log('Checking limits for company:', companyId);

    // Get current subscription with case-insensitive plan check
    const subscription = await Subscription.findOne({ 
      company_id: companyId,
      plan: { $regex: new RegExp('^basic$', 'i') }  // Case insensitive match
    });

    if (!subscription) {
      console.log('No basic subscription found for company:', companyId);
      return next();
    }

    console.log('Found subscription:', subscription);

    // Calculate current billing period
    const now = new Date();
    const currentPeriodStart = new Date(now.getFullYear(), now.getMonth(), 1); // Start of current month
    const currentPeriodEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0); // End of current month
    currentPeriodEnd.setHours(23, 59, 59, 999); // End of the last day

    console.log('Billing period:', {
      start: currentPeriodStart.toISOString(),
      end: currentPeriodEnd.toISOString()
    });

    // Build query for current month's paid transactions
    const query = {
      companyId,
      status: "paid",
      transactionDate: {
        $gte: currentPeriodStart,
        $lte: currentPeriodEnd
      }
    };

    console.log('Transaction query:', JSON.stringify(query, null, 2));

    // Get current month's transaction count
    const transactionCount = await Transaction.countDocuments(query);
    console.log(`Current transaction count: ${transactionCount} of ${BASIC_MONTHLY_LIMIT} allowed`);

    // Log sample transactions for debugging
    const sampleTransactions = await Transaction.find(query)
      .select('transactionId transactionDate status')
      .sort({ transactionDate: -1 })
      .limit(5);

    console.log('Recent transactions:', JSON.stringify(sampleTransactions, null, 2));

    if (transactionCount >= BASIC_MONTHLY_LIMIT) {
      console.log(`Transaction limit exceeded: ${transactionCount} >= ${BASIC_MONTHLY_LIMIT}`);

      // Calculate days until end of month
      const daysUntilReset = Math.ceil((currentPeriodEnd.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

      return res.status(403).json({
        error: "Transaction limit exceeded",
        message: `You have reached your monthly transaction limit of ${BASIC_MONTHLY_LIMIT}. Your limit will reset in ${daysUntilReset} days. Please upgrade to Pro plan for unlimited transactions.`,
        code: "TRANSACTION_LIMIT_EXCEEDED",
        currentCount: transactionCount,
        limit: BASIC_MONTHLY_LIMIT,
        nextResetDate: currentPeriodEnd,
        daysUntilReset
      });
    }

    console.log(`Transaction allowed: ${transactionCount + 1} of ${BASIC_MONTHLY_LIMIT}`);
    next();

  } catch (error) {
    console.error("Error checking transaction limits:", error);
    console.error("Stack trace:", error.stack);
    next(error);
  }
};

module.exports = checkTransactionLimits;