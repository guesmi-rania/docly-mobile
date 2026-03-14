const mongoose = require('mongoose');

const PatientSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  age: { type: Number },
  bloodType: { type: String },
  medicalHistory: { type: String }
});

module.exports = mongoose.model('Patient', PatientSchema);