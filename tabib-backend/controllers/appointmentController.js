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
      .populate({
        path: 'doctor',
        populate: { path: 'user', select: 'name' },
        select: 'user specialty city price' 
      })
      .sort({ date: -1 }); 

    const formatted = appointments.map(a => ({
      _id: a._id,
      status: a.status,           
      date: a.date,
      time: a.time,
      notes: a.notes,
      doctor: {
        _id: a.doctor?._id,
        name: a.doctor?.user?.name,
        specialty: a.doctor?.specialty,
        city: a.doctor?.city,
        price: a.doctor?.price,
      }
    }));

    res.json(formatted);
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