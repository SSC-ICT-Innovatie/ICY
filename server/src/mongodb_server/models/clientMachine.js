// src/mongodb_server/models/ClientMachine.js
const mongoose = require("mongoose");

const clientMachineSchema = new mongoose.Schema({
  device_id: { type: String, required: false},
  machine_key: { type: String, required: true },
  company_id: { type: String, required: true },
  // company_accent_color: { type: String, required: false },
  is_active: { type: Boolean, default: true },
});


clientMachineSchema.index({ device_id: 1, company_id: 1 }, { unique: true });



module.exports = mongoose.model(
  "ClientMachine",
  clientMachineSchema,
  "client_machines",
);
