// src/mongodb_server/routes/productRoutes.js
const express = require("express");
const router = express.Router();
const productController = require("../controllers/productController");

router.post("/", productController.addProduct);
router.get("/search", productController.searchProducts);
router.get("/bonus/:companyId", productController.getBonusProducts);
router.get("/by-section/:sectionId", productController.getProductsBySection);
router.get("/:productId", productController.getProduct);
router.get("/company/:companyId", productController.getProductsByCompanyId);; 
// router.put("/:productId", productController.updateProduct);
router.put("/updateField/:productId", productController.updateProductField);
router.delete("/:productId", productController.deleteProduct);
router.post("/deleteMultiple", productController.deleteProducts);

module.exports = router;
