const router = require('express').Router();
const auth = require('../middleware/auth');
const { getAllDoctors, getDoctorById, updateSlots } = require('../controllers/doctorController');
router.get('/', getAllDoctors);
router.get('/:id', getDoctorById);
router.put('/slots', auth, updateSlots);
module.exports = router;