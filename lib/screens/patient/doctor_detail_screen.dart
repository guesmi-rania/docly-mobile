import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../models/review.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/star_rating.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  Doctor? _doctor;
  List<Review> _reviews = [];
  bool _loading = true;
  String? _selectedDate;
  String? _selectedSlot;
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final d = await ApiService.getDoctorById(widget.doctorId);
      final r = await ApiService.getDoctorReviews(widget.doctorId);
      setState(() {
        _doctor = Doctor.fromJson(d);
        _reviews = (r['reviews'] as List).map((x) => Review.fromJson(x)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _book() async {
    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sélectionne une date et un créneau'), backgroundColor: AppTheme.warning));
      return;
    }
    setState(() => _booking = true);
  try {
      await ApiService.createAppointment(
        widget.doctorId, _selectedDate!, _selectedSlot!
      );
      if (!mounted) return;   // ← ajoute cette ligne
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('✅ Réservé !'),
          content: const Text('Votre rendez-vous a été réservé avec succès.'),
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
        const SnackBar(content: Text('Réservation échouée'), backgroundColor: AppTheme.danger),
      );
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_doctor == null) return const Scaffold(body: Center(child: Text('Médecin introuvable')));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 60, bottom: 24),
              decoration: const BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
              child: Column(
                children: [
                  Row(children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ]),
                  const Text('👩‍⚕️', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 8),
                  Text('Dr. ${_doctor!.name}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(_doctor!.specialty, style: const TextStyle(color: Color(0xFFb3d1ff), fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _stat(_doctor!.rating.toStringAsFixed(1), 'Note'),
                    _stat('${_doctor!.reviewsCount}', 'Avis'),
                    _stat('${_doctor!.price.toInt()} TND', 'Tarif'),
                  ]),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Créneaux disponibles', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 14),
                  if (_doctor!.availableSlots.isEmpty)
                    const Text('Aucun créneau disponible', style: TextStyle(color: AppTheme.textSecondary))
                  else
                    ..._doctor!.availableSlots.map((day) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _selectedDate = day['date']),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedDate == day['date'] ? AppTheme.primaryLight : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _selectedDate == day['date'] ? AppTheme.primary : const Color(0xFFdddddd)),
                            ),
                            child: Text('📅 ${day['date']}', style: TextStyle(color: _selectedDate == day['date'] ? AppTheme.primary : AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        if (_selectedDate == day['date'])
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (day['slots'] as List).map<Widget>((slot) => GestureDetector(
                              onTap: () => setState(() => _selectedSlot = slot),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedSlot == slot ? AppTheme.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _selectedSlot == slot ? AppTheme.primary : const Color(0xFFdddddd)),
                                ),
                                child: Text(slot, style: TextStyle(fontSize: 13, color: _selectedSlot == slot ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                              ),
                            )).toList(),
                          ),
                        const SizedBox(height: 8),
                      ],
                    )),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _booking ? null : _book,
                      child: _booking ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Réserver ce créneau'),
                    ),
                  ),
                  if (_reviews.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Avis patients', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    ..._reviews.take(3).map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(r.patientName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          StarRating(rating: r.rating, size: 16),
                        ]),
                        if (r.comment != null) ...[const SizedBox(height: 6), Text(r.comment!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))],
                      ]),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Color(0xFFb3d1ff), fontSize: 12)),
  ]);
}