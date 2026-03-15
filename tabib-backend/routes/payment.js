const router = require('express').Router();
const auth = require('../middleware/auth');
const axios = require('axios');

router.post('/konnect/initiate', auth, async (req, res) => {
  try {
    const { appointmentId, amount } = req.body;

    const response = await axios.post(
      'https://api.preprod.konnect.network/api/v2/payments/init-payment',
      {
        receiverWalletId: process.env.KONNECT_WALLET_ID,
        token: 'TND',
        amount: amount * 1000, // Konnect utilise les millimes
        type: 'immediate',
        description: `Consultation Docly - RDV ${appointmentId}`,
        acceptedPaymentMethods: ['wallet', 'bank_card', 'e-DINAR'],
        lifespan: 10,
        addPaymentFeesToAmount: true,
        firstName: req.user.name?.split(' ')[0] || '',
        lastName: req.user.name?.split(' ')[1] || '',
        email: req.user.email,
        orderId: appointmentId,
        webhook: `${process.env.BACKEND_URL}/api/payments/konnect/webhook`,
        successUrl: `${process.env.FRONTEND_URL}/payment-success`,
        failUrl: `${process.env.FRONTEND_URL}/payment-failed`,
      },
      {
        headers: {
          'x-api-key': process.env.KONNECT_API_KEY,
          'Content-Type': 'application/json',
        },
      }
    );

    res.json({ payUrl: response.data.payUrl });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Webhook Konnect (confirmation serveur)
router.post('/konnect/webhook', async (req, res) => {
  const { payment_ref, order_id, status } = req.body;
  if (status === 'completed') {
    const Appointment = require('../models/Appointment');
    await Appointment.findByIdAndUpdate(order_id, {
      status: 'confirmed',
      paymentRef: payment_ref,
      paid: true,
    });
  }
  res.sendStatus(200);
});

module.exports = router;