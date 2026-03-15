const router = require('express').Router();
const auth = require('../middleware/auth');
const { getAllDoctors, getDoctorById, updateSlots } = require('../controllers/doctorController');

router.get('/', getAllDoctors);
router.put('/slots', auth, updateSlots);

router.get('/my-slots', auth, async (req, res) => {
  try {
    const Doctor = require('../models/Doctor');
    const doctor = await Doctor.findOne({ user: req.user.id });
    if (!doctor) return res.status(404).json({ message: 'Médecin introuvable' });
    res.json({ availableSlots: doctor.availableSlots });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/:id', getDoctorById);

module.exports = router;