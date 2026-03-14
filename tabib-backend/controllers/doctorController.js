const Doctor = require('../models/Doctor');

exports.getAllDoctors = async (req, res) => {
  try {
    const { specialty, city } = req.query;
    let filter = {};
    if (specialty) filter.specialty = new RegExp(specialty, 'i');
    if (city) filter.city = new RegExp(city, 'i');

    const doctors = await Doctor.find(filter).populate('user', 'name email phone');
    res.json(doctors);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getDoctorById = async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id).populate('user', 'name email phone');
    if (!doctor) return res.status(404).json({ message: 'Médecin introuvable' });
    res.json(doctor);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateSlots = async (req, res) => {
  try {
    const { availableSlots } = req.body;
    const doctor = await Doctor.findOneAndUpdate(
      { user: req.user.id },
      { availableSlots },
      { new: true }
    );
    res.json(doctor);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};