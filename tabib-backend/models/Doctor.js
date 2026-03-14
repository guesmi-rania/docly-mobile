const mongoose = require('mongoose');

const DoctorSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  specialty: { type: String, required: true },
  city: { type: String, required: true },
  address: { type: String, required: true },
  price: { type: Number, required: true },
  bio: { type: String },
  photo: { type: String },
  rating: { type: Number, default: 0 },
  reviewsCount: { type: Number, default: 0 },
  availableSlots: [{
    date: String,
    slots: [String]
  }]
});

module.exports = mongoose.model('Doctor', DoctorSchema);