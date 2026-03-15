import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final String appointmentId;
  final double amount;
  final String doctorName;

  const PaymentScreen({
    super.key,
    required this.appointmentId,
    required this.amount,
    required this.doctorName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController _webController;
  bool _loading = true;
  bool _initializingPayment = true;
  String? _paymentUrl;

  @override
  void initState() {
    super.initState();
    _initPayment();
  }

  Future<void> _initPayment() async {
    try {
      // Appel backend pour créer le paiement Konnect
      final result = await ApiService.initiateKonnectPayment(
        appointmentId: widget.appointmentId,
        amount: widget.amount,
      );

      final payUrl = result['payUrl'] as String;

      setState(() {
        _paymentUrl = payUrl;
        _initializingPayment = false;
      });

      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _loading = true),
            onPageFinished: (_) =>
                setState(() => _loading = false),
            onNavigationRequest: (req) {
              // Détecter la redirection de succès/échec
              if (req.url.contains('payment-success') ||
                  req.url.contains('docly://success')) {
                _onPaymentSuccess();
                return NavigationDecision.prevent;
              }
              if (req.url.contains('payment-failed') ||
                  req.url.contains('docly://failed')) {
                _onPaymentFailed();
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(payUrl));
    } catch (e) {
      setState(() => _initializingPayment = false);
      _showError('Impossible d\'initialiser le paiement');
    }
  }

  void _onPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFe8f5e9),
                borderRadius: BorderRadius.circular(35),
              ),
              child: const Center(
                  child: Text('✅',
                      style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: 16),
            const Text('Paiement réussi !',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              '${widget.amount.toInt()} TND payé\nRendez-vous confirmé',
              style: const TextStyle(
                  color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text('Voir mes RDV'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPaymentFailed() {
    _showError('Paiement échoué. Réessayez.');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paiement sécurisé',
                style: TextStyle(fontSize: 16)),
            Text('Dr. ${widget.doctorName} • ${widget.amount.toInt()} TND',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white70)),
          ],
        ),
        flexibleSpace: Container(
          decoration:
              BoxDecoration(gradient: AppTheme.gradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: _initializingPayment
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text('Initialisation du paiement...',
                      style:
                          TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _paymentUrl == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('❌',
                          style: TextStyle(fontSize: 50)),
                      const SizedBox(height: 16),
                      const Text('Erreur de paiement'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(
                              () => _initializingPayment = true);
                          _initPayment();
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    WebViewWidget(controller: _webController),
                    if (_loading)
                      const LinearProgressIndicator(
                          color: AppTheme.primary),
                  ],
                ),
    );
  }
}