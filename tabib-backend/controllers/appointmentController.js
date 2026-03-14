const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');

exports.createAppointment = async (req, res) => {
  try {
    const { doctorId, date, time, notes } = req.body;
    const appointment = await Appointment.create({
      patient: req.user.id,
      doctor: doctorId,
      date, time, notes
    });
    res.json(appointment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getMyAppointments = async (req, res) => {
  try {
    const appointments = await Appointment.find({ patient: req.user.id })
      .populate({ path: 'doctor', populate: { path: 'user', select: 'name' } });
    res.json(appointments);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getDoctorAppointments = async (req, res) => {
  try {
    const doctor = await Doctor.findOne({ user: req.user.id });
    const appointments = await Appointment.find({ doctor: doctor._id })
      .populate('patient', 'name phone');
    res.json(appointments);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateStatus = async (req, res) => {
  try {
    const appointment = await Appointment.findByIdAndUpdate(
      req.params.id,
      { status: req.body.status },
      { new: true }
    );
    res.json(appointment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};