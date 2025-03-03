// src/mongodb_server/controllers/sectionController.js
const { json } = require("express");
const { body } = require("express-validator");
const { log } = require("winston");
const Product = require("../models/product");
const Section = require("../models/section");


exports.addSection = async (req, res) => {
  console.log("addSection called with body:", req.body);
  try {
    const section = new Section({
      ...req.body,
      company_id: req.companyId
    });
    const savedSection = await section.save();
    console.log("Section saved:", savedSection);
    res.status(201).json(savedSection);
  } catch (error) {
    console.error("Error in addSection:", error);
    res.status(400).json({ message: error.message });
  }
};

exports.getSection = async (req, res) => {
  console.log("getSection called with params:", req.params);
  try {
    const section = await Section.findOne({
      section_id: req.params.sectionId,
      company_id: req.companyId,
    });
    console.log("Section found:", section);
    if (!section) return res.status(404).json({ message: "Section not found" });
    res.json(section);
  } catch (error) {
    console.error("Error in getSection:", error);
    res.status(500).json({ message: error.message });
  }
};

exports.updateSection = async (req, res) => {
  try {
    const { sectionId } = req.params;
    const { section_id: newSectionId, section_color } = req.body;
    const companyId = req.companyId;

    console.log(`Updating section: ${sectionId} for company: ${companyId}`);
    console.log('Request body:', req.body);

    let updatedSection;

    if (newSectionId && newSectionId !== sectionId) {
      // If section_id is changing, use updateSectionId
      const result = await exports.updateSectionId(req, res);
      if (result.section) {
        updatedSection = result.section;
      } else {
        return; // updateSectionId has already sent a response
      }
    } else {
      // If only color is changing, update directly
      updatedSection = await Section.findOneAndUpdate(
        { section_id: sectionId, company_id: companyId },
        { section_color },
        { new: true }
      );
    }

    if (!updatedSection) {
      console.log(`Section not found: ${sectionId}`);
      return res.status(404).json({ message: "Section not found" });
    }

    console.log('Updated section:', updatedSection);
    res.json(updatedSection);
  } catch (error) {
    console.error('Error in updateSection:', error);
    res.status(500).json({ message: error.message });
  }
};

exports.updateSectionId = async (req, res) => {
  const { sectionId: oldSectionId } = req.params;
  const { section_id: newSectionId, section_color } = req.body;
  const companyId = req.companyId;

  console.log(`Updating section ID from ${oldSectionId} to ${newSectionId} for company: ${companyId}`);

  try {
    const updatedSection = await Section.findOneAndUpdate(
      { section_id: oldSectionId, company_id: companyId },
      { section_id: newSectionId, section_color },
      { new: true }
    );

    if (!updatedSection) {
      console.log(`Section not found: ${oldSectionId}`);
      return res.status(404).json({ message: "Section not found" });
    }

    const updateResult = await Product.updateMany(
      { section_id: oldSectionId, company_id: companyId },
      { $set: { section_id: newSectionId } }
    );

    console.log("Updated products result:", updateResult);

    return {
      section: updatedSection,
      productsUpdated: updateResult.modifiedCount
    };
  } catch (error) {
    console.error("Error in updateSectionId:", error);
    res.status(500).json({ message: error.message });
    return {};
  }
};

exports.deleteSection = async (req, res) => {
  try {
    const { sectionId } = req.params;
    const companyId = req.companyId;

    console.log(`Attempting to delete section: ${sectionId} for company: ${companyId}`);

    const deletedSection = await Section.findOneAndDelete({
      section_id: sectionId,
      company_id: companyId
    });

    if (!deletedSection) {
      console.log(`Section not found: ${sectionId}`);
      return res.status(404).json({ message: "Section not found" });
    }

    // Delete all products in this section
    const deleteResult = await Product.deleteMany({ section_id: sectionId, company_id: companyId });
    console.log(`Deleted ${deleteResult.deletedCount} products associated with the section`);

    console.log(`Successfully deleted section: ${sectionId}`);
    res.json({ message: "Section and related products deleted successfully", deletedSection });
  } catch (error) {
    console.error('Error in deleteSection:', error);
    res.status(500).json({ message: error.message });
  }
};

exports.getSectionsByCompanyId = async (req, res) => {
  console.log(
    "getSectionsByCompanyId called with params:",
    req.params,
    "and query:",
    req.query,
  );
  try {
    const companyId = req.companyId;
    const { skip = 0, limit = 20 } = req.query;
    console.log(
      `Fetching sections for company: ${companyId}, skip: ${skip}, limit: ${limit}`,
    );

    const sections = await Section.find({ company_id: companyId })
      .skip(Number(skip))
      .limit(Number(limit));

    console.log(`Found ${sections.length} sections`);
    res.status(200).json(sections);
  } catch (error) {
    console.error("Error in getSectionsByCompanyId:", error);
    res.status(500).json({ message: error.message });
  }
};
