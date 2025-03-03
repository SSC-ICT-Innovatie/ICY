const Subscription = require("../mongodb_server/models/subscription");
const Transaction = require("../mongodb_server/models/transaction");
const OpenAI = require("openai");
const loadConfig = require("../config");

let openai;

(async () => {
  const config = await loadConfig();
  openai = new OpenAI({
    apiKey: config.OPENAI_API_KEY,
  });
})();

const checkSubscription = async (companyId) => {
  const subscription = await Subscription.findOne({ company_id: companyId });
  if (!subscription || (subscription.plan !== "pro" && subscription.plan !== "enterprise")) {
    throw new Error("Pro or Enterprise subscription required");
  }
};

const prepareTransactionData = (transactions) => {
  return transactions.map((t) => ({
    transactionId: t.transactionId,
    date: t.transactionDate,
    paymentMethod: t.paymentMethod,
    totalQuantity: t.totalQuantity,
    totalAmount: t.totalAmount,
    products: t.productsBought.map((p) => ({
      name: p.name,
      quantity: p.quantity,
      price: p.priceBought,
      wasInBonus: p.wasInBonus,
      bonusPrice: p.bonusPrice,
    })),
  }));
};

exports.generateAIInsights = async (req, res) => {
  console.log('AI Insights generation started');
  console.log('Company ID from token:', req.companyId);

  try {
    if (!req.companyId) {
      console.log('Company ID not provided in the request');
      return res.status(400).json({ error: 'Company ID not provided' });
    }

    console.log('Checking subscription for company:', req.companyId);
    await checkSubscription(req.companyId);
    
    const requestTime = new Date(req.body.requestTime || 0);
    const forceFresh = req.body.forceFresh || false;
    
    console.log('Checking for transactions since:', requestTime);
    console.log('Force fresh generation:', forceFresh);

    const newTransactionsCount = await Transaction.countDocuments({
      companyId: req.companyId,
      transactionDate: { $gt: requestTime }
    });

    console.log('New transactions found:', newTransactionsCount);

    if (newTransactionsCount === 0 && !forceFresh && requestTime.getTime() > 0) {
      console.log('No new transactions, frontend should use cached data');
      return res.json({ isCached: true });
    }

    console.log('Fetching transactions for analysis');
    const transactions = await Transaction.find({ companyId: req.companyId })
      .sort({ transactionDate: -1 })
      .limit(100);

    if (transactions.length === 0) {
      return res.status(400).json({ error: 'No transactions found for analysis' });
    }

    const preparedData = prepareTransactionData(transactions);

    const forecastPrompt = `
    As a business analyst, provide a detailed sales forecast for next week, focusing on actionable business metrics.
    
    Rules:
    - Focus on concrete business terms and numbers
    - Keep descriptions professional and clear
    - Show growth both as numbers and percentages
    - Use only real product names from the data
    - Stay factual and focused on trends
    
    Provide the response as clean JSON matching exactly:
    {
      "salesForecast": "[number with % sign]",
      "confidence": "[confidence level with % sign]",
      "topProducts": [
        {
          "name": "[actual product name]",
          "growth": "[growth with % sign]"
        },
        // exactly 3 products total
      ],
      "dailyForecast": [
        {
          "date": "YYYY-MM-DD",
          "revenue": [number],
          "forecastRevenue": [number]
        },
        // exactly 7 days
      ]
    }

    Transaction data: ${JSON.stringify(preparedData)}
    `;

    const analysisPrompt = `
    You are a senior business analyst providing clear insights about historical sales performance.
    
    Rules:
    - Write in clear business language suitable for management presentations
    - Focus on key business metrics and trends
    - Break down different aspects: daily patterns, top items, payment trends
    - No technical jargon or bullet points
    - Use short, focused paragraphs
    - No numbers without context
    - Explain percentage changes in business terms
    
    Write a clear business analysis covering:
    1. Overall sales trends and patterns
    2. Best performing products and times
    3. Customer purchasing behavior
    4. Payment method preferences
    5. Promotion effectiveness

    Transaction data: ${JSON.stringify(preparedData)}
    `;

    const recommendationsPrompt = `
    As a business consultant, provide 5 specific, actionable business recommendations.
    
    Rules:
    - Each recommendation must be specific and implementable
    - Use real product names and numbers from the data
    - Focus on practical business actions
    - Include expected outcomes
    - No technical terms or jargon
    - Write in clear business language
    
    Return ONLY a JSON array of 5 strings. Example format:
    [
      "Increase inventory of [Product] by 20% during peak hours of 2-5pm to meet demonstrated demand patterns",
      "Bundle [Product A] with [Product B] at a 15% discount to boost combined sales by estimated 25%",
      "Launch targeted promotion for [Product] on [Day] when sales historically drop by 30%",
      "Adjust pricing strategy for [Product] during off-peak hours to improve sales volume",
      "Implement express checkout for transactions under $20 to reduce wait times by 40%"
    ]

    Transaction data: ${JSON.stringify(preparedData)}
    `;

    const [forecastResponse, analysisResponse, recommendationsResponse] = 
      await Promise.all([
        openai.chat.completions.create({
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: forecastPrompt }],
          max_tokens: 1000,
          temperature: 0.7,
        }),
        openai.chat.completions.create({
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: analysisPrompt }],
          max_tokens: 500,
          temperature: 0.7,
        }),
        openai.chat.completions.create({
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: recommendationsPrompt }],
          max_tokens: 1000,
          temperature: 0.7,
        }),
      ]);

    const response = {
      forecast: JSON.parse(forecastResponse.choices[0].message.content.trim()),
      analysis: analysisResponse.choices[0].message.content.trim(),
      recommendations: JSON.parse(recommendationsResponse.choices[0].message.content.trim()),
      isCached: false
    };

    console.log('AI insights generated successfully');
    return res.json(response);
  
  } catch (error) {
    console.error('Error in generateAIInsights:', error);
    if (error.message === 'Pro or Enterprise subscription required') {
      return res.status(403).json({ error: 'Pro or Enterprise subscription required for AI features' });
    }
    res.status(500).json({ error: 'An error occurred while generating AI insights' });
  }
};