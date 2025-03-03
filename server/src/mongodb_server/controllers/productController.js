// src/mongodb_server/controllers/productController.js
const Product = require("../models/product");

exports.addProduct = async (req, res) => {
  try {
    const productData = {
      ...req.body,
      company_id: req.companyId // This should be set by your authentication middleware
    };
    console.log('Received product data:', productData);
    const product = new Product(productData);
    const savedProduct = await product.save();
    console.log('Saved product:', savedProduct);
    res.status(201).json(savedProduct);
  } catch (error) {
    console.error('Error in addProduct:', error);
    res.status(400).json({ message: error.message });
  }
};

exports.getProduct = async (req, res) => {
  try {
    const productId = req.params.productId;
    const companyId = req.companyId; // This comes from the middleware

    console.log(`Fetching product. ProductId: ${productId}, CompanyId: ${companyId}`);

    let product = await Product.findOne({
      product_id: productId,
      company_id: companyId,
    });

    console.log("Product found:", product);

    if (!product) {
      console.log('Product not found');
      return res.status(404).json({ message: "Product not found" });
    }

    res.json(product);
  } catch (error) {
    console.error('Error in getProduct:', error);
    res.status(500).json({ message: error.message });
  }
};


exports.getBonusProducts = async (req, res) => {
  try {
    const products = await Product.find({
      company_id: req.companyId,
      is_in_bonus: true,
    });
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getProductsBySection = async (req, res) => {
  try {
    const { sectionId } = req.params;
    const { page = 1, limit = 15 } = req.query;
    const companyId = req.companyId;

    console.log(`Fetching products for section: ${sectionId}, company: ${companyId}, page: ${page}, limit: ${limit}`);

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const products = await Product.find({
      section_id: sectionId,
      company_id: companyId,
    })
      .skip(skip)
      .limit(parseInt(limit));

      console.log("checking products: $products")

    const totalCount = await Product.countDocuments({
      section_id: sectionId,
      company_id: companyId,
    });

    console.log(`Found ${products.length} products out of ${totalCount} total`);

    if (products.length === 0) {
      return res.status(200).json({
        products: [],
        currentPage: parseInt(page),
        totalPages: 0,
        totalCount: 0
      });
    }

    const totalPages = Math.ceil(totalCount / parseInt(limit));

    res.status(200).json({
      products,
      currentPage: parseInt(page),
      totalPages,
      totalCount,
    });
  } catch (error) {
    console.error('Error in getProductsBySection:', error);
    res.status(500).json({ message: "Internal server error" });
  }
};

exports.getProductsByCompanyId = async (req, res) => {
  try {
    const products = await Product.find({ company_id: req.companyId });
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.searchProducts = async (req, res) => {
  try {
    const { query } = req.query;
    const companyId = req.companyId;

    if (!query) {
      return res.status(400).json({ message: "Search query is required" });
    }

    console.log(`Searching products for company ${companyId} with query: ${query}`);

    const products = await Product.find({
      company_id: companyId,
      name: { $regex: query, $options: "i" }
    });

    console.log(`Found ${products.length} matching products`);
    res.json(products);
  } catch (error) {
    console.error('Error in searchProducts:', error);
    res.status(500).json({ message: error.message });
  }
};


exports.updateProductField = async (req, res) => {
  try {
    const { productId } = req.params;
    const { columnName, newValue } = req.body;
    const companyId = req.companyId;

    let updateObject = { date_modified: new Date() };

    switch (columnName) {
      case "Image":
        updateObject.image_url = newValue;
        break;
      case "Product Name":
        updateObject.name = newValue;
        break;
      case "Current Stock":
        updateObject.item_number = Number(newValue);
        break;
      case "Price":
        updateObject.price = Number(newValue);
        break;
      case "Bonus Price Percentage":
        updateObject.bonus_percentage = Number(newValue);
        break;
      case "Is Selling":
        updateObject.is_selling = newValue;
        break;
      case "Is In Bonus":
        updateObject.is_in_bonus = newValue;
        break;
      case "Info":
        updateObject.info = newValue;
        break;
      default:
        return res.status(400).json({ message: "Invalid column name" });
    }

    const product = await Product.findOneAndUpdate(
      { product_id: productId, company_id: companyId },
      { $set: updateObject },
      { new: true, runValidators: true },
    );

    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    res.json(product);
  } catch (error) {
    console.error(`Error updating product:`, error);
    res.status(400).json({ message: error.message });
  }
};

exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findOneAndDelete({
      product_id: req.params.productId,
      company_id: req.companyId,
    });
    if (!product) return res.status(404).json({ message: "Product not found" });
    res.json({ message: "Product deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteProducts = async (req, res) => {
  try {
    const { productIds } = req.body;
    const companyId = req.companyId;
    const result = await Product.deleteMany({
      product_id: { $in: productIds },
      company_id: companyId,
    });
    res.json({
      message: `${result.deletedCount} products deleted successfully`,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
