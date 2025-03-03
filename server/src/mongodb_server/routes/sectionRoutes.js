// src/mongodb_server/routes/sectionRoutes.js
const express = require("express");
const router = express.Router();
const sectionController = require("../controllers/sectionController");

console.log("Setting up section routes");

// Place this route first to ensure it's not overshadowed by other routes
router.get("/company", (req, res, next) => {
  console.log(
    `GET /company route hit. Params:`,
    req.params,
    "Query:",
    req.query,
  );
  sectionController.getSectionsByCompanyId(req, res, next);
});

router.post("/", sectionController.addSection);
router.get("/:sectionId", sectionController.getSection);
router.put("/updateId", (req, res, next) => {
  console.log(
    "PUT /updateId route hit. Params:",
    req.params,
    "Body:",
    req.body,
  );
  sectionController.updateSectionId(req, res, next);
});
router.put("/:sectionId", sectionController.updateSection);

router.delete("/:sectionId", (req, res, next) => {
  console.log(`Delete route hit for section: ${req.params.sectionId}`);
  sectionController.deleteSection(req, res, next);
});

module.exports = router;
