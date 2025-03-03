const Transaction = require("../models/transaction");

exports.getTransactions = async (req, res) => {
  try {
    const { page = 1, limit = 10, todayOnly } = req.query;
    const skip = (page - 1) * limit;

    let query = { companyId: req.companyId };

    if (todayOnly === 'true') {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      query.transactionDate = {
        $gte: today,
        $lt: tomorrow
      };
    }

    console.log('Query:', query);

    const transactions = await Transaction.find(query)
      .skip(skip)
      .limit(parseInt(limit));

    console.log(`Found ${transactions.length} transactions`);

    res.json(transactions);
  } catch (error) {
    console.error('Error in getTransactions:', error);
    res.status(500).json({ message: error.message });
  }
};

exports.getTransactionCount = async (req, res) => {
  try {
    const count = await Transaction.countDocuments({
      companyId: req.companyId,
    });
    res.json({ count });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAllTransactions = async (req, res) => {
  try {
    const transactions = await Transaction.find({
      companyId: req.companyId,
    });
    res.json(transactions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.addTransaction = async (req, res) => {
  try {
    const transaction = new Transaction(req.body);
    await transaction.save();
    res.status(201).json(transaction);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};


