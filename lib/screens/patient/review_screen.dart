import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/star_rating.dart';

class ReviewScreen extends StatefulWidget {
  final String doctorId, appointmentId, doctorName;
  const ReviewScreen({super.key, required this.doctorId, required this.appointmentId, required this.doctorName});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final _comment = TextEditingController();
  bool _loading = false;
  final _tags = ['Ponctuel', 'À l\'écoute', 'Professionnel', 'Explique bien', 'Attente longue'];

  final Map<int, String> _labels = {0: 'Sélectionnez une note', 1: 'Très insatisfait 😞', 2: 'Insatisfait 😕', 3: 'Correct 😐', 4: 'Satisfait 😊', 5: 'Excellent ! 🌟'};

Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une note')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.createReview(
        widget.doctorId,
        widget.appointmentId,
        _rating,
        comment: _comment.text.isNotEmpty ? _comment.text : null,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('✅ Merci !'),
          content: const Text('Votre avis a été envoyé.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Envoi échoué'), backgroundColor: AppTheme.danger),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 24),
            decoration: const BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
            child: Column(children: [
              Row(children: [IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))]),
              const Text('👨‍⚕️', style: TextStyle(fontSize: 50)),
              const Text('Votre avis sur', style: TextStyle(color: Color(0xFFb3d1ff))),
              Text('Dr. ${widget.doctorName}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _card(child: Column(children: [
                const Text('Note globale', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                StarRating(rating: _rating, size: 44, onRate: (r) => setState(() => _rating = r)),
                const SizedBox(height: 8),
                Text(_labels[_rating]!, style: const TextStyle(color: AppTheme.textSecondary)),
              ])),
              const SizedBox(height: 14),
              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Commentaire', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(controller: _comment, maxLines: 4, maxLength: 500, decoration: const InputDecoration(hintText: 'Décrivez votre expérience...')),
              ])),
              const SizedBox(height: 14),
              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Mots clés rapides', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: _tags.map((t) => GestureDetector(
                  onTap: () { final c = _comment.text; _comment.text = c.isEmpty ? t : '$c, $t'; },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(20)),
                    child: Text('+ $t', style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                  ),
                )).toList()),
              ])),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Envoyer mon avis'),
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: child);
}