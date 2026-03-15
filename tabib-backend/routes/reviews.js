const router = require('express').Router();
const auth = require('../middleware/auth');
const Review = require('../models/Review');
const Doctor = require('../models/Doctor');

router.post('/', auth, async (req, res) => {
  try {
    const { doctorId, appointmentId, rating, comment } = req.body;
    const existing = await Review.findOne({
      patient: req.user.id,
      appointment: appointmentId
    });
    if (existing) {
      return res.status(400).json({ message: 'Avis déjà soumis' });
    }
    const review = await Review.create({
      patient: req.user.id,
      doctor: doctorId,
      appointment: appointmentId,
      rating,
      comment
    });
    const allReviews = await Review.find({ doctor: doctorId });
    const avg = allReviews.reduce((s, r) => s + r.rating, 0) / allReviews.length;
    await Doctor.findByIdAndUpdate(doctorId, {
      rating: Math.round(avg * 10) / 10,
      reviewsCount: allReviews.length
    });
    res.json(review);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/doctor/:doctorId', async (req, res) => {
  try {
    const reviews = await Review.find({ doctor: req.params.doctorId })
      .populate('patient', 'name')
      .sort({ createdAt: -1 });
    const stats = {
      average: 0,
      total: reviews.length,
      breakdown: { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 }
    };
    if (reviews.length > 0) {
      reviews.forEach(r => { stats.breakdown[r.rating]++; });
      stats.average = Math.round(
        (reviews.reduce((s, r) => s + r.rating, 0) / reviews.length) * 10
      ) / 10;
    }
    res.json({ reviews, stats });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/can-review/:appointmentId', auth, async (req, res) => {
  try {
    const existing = await Review.findOne({
      patient: req.user.id,
      appointment: req.params.appointmentId
    });
    res.json({ canReview: !existing });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;