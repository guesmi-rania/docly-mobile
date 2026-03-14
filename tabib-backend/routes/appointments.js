const router = require('express').Router();
const auth = require('../middleware/auth');
const {
  createAppointment,
  getMyAppointments,
  getDoctorAppointments,
  updateStatus
} = require('../controllers/appointmentController');
router.post('/', auth, createAppointment);
router.get('/my', auth, getMyAppointments);
router.get('/doctor', auth, getDoctorAppointments);
router.patch('/:id/status', auth, updateStatus);
module.exports = router;