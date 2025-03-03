// src/mongodb_server/models/Section.js
const mongoose = require("mongoose");

const sectionSchema = new mongoose.Schema({
  section_id: { type: String, required: true},
  company_id: { type: String, required: true },
  section_color: { type: String, required: true },
  created_at: { type: Date, default: Date.now },
});

sectionSchema.index({ section_id: 1, company_id: 1 }, { unique: true });

module.exports = mongoose.model("Section", sectionSchema);
