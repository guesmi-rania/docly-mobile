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
    debugPrint('🔍 Fetching doctor: ${widget.doctorId}');
    final d = await ApiService.getDoctorById(widget.doctorId);
    debugPrint('✅ Doctor OK: ${d['user']}');

    // Reviews séparées — si ça échoue, on affiche quand même le médecin
    List<Review> reviews = [];
    try {
      final r = await ApiService.getDoctorReviews(widget.doctorId);
      reviews = (r['reviews'] as List)
          .map((x) => Review.fromJson(x))
          .toList();
      debugPrint('✅ Reviews OK: ${reviews.length}');
    } catch (e) {
      debugPrint('⚠️ Reviews non disponibles: $e');
      // On continue sans reviews
    }

    if (!mounted) return;
    setState(() {
      _doctor = Doctor.fromJson(d);
      _reviews = reviews;
      _loading = false;
    });
  } catch (e, stack) {
    debugPrint('❌ ERREUR doctor: $e');
    debugPrint('❌ STACK: $stack');
    if (!mounted) return;
    setState(() => _loading = false);
  }
}

  // Filtrer uniquement les dates à partir d'aujourd'hui
  List<dynamic> get _futureSlots {
    final today = DateTime.now();
    return _doctor!.availableSlots.where((day) {
      try {
        final date = DateTime.parse(day['date']);
        return date.isAfter(
          DateTime(today.year, today.month, today.day)
              .subtract(const Duration(days: 1)),
        );
      } catch (e) {
        return true;
      }
    }).toList();
  }

  Future<void> _book() async {
    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sélectionne une date et un créneau'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _booking = true);
    try {
      await ApiService.createAppointment(
        widget.doctorId,
        _selectedDate!,
        _selectedSlot!,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFe8f5e9),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Center(
                  child: Text('✅', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rendez-vous réservé !',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Le $_selectedDate à $_selectedSlot\navec Dr. ${_doctor!.name}',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Voir mes RDV'),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Réservation échouée. Réessaie.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_doctor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Médecin'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              const Text(
                'Impossible de charger ce médecin',
                style: TextStyle(
                    fontSize: 16, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _loading = true);
                  _fetch();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final slots = _futureSlots;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Header médecin
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(gradient: AppTheme.gradient),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Bouton retour
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text('👩‍⚕️',
                            style: TextStyle(fontSize: 44)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dr. ${_doctor!.name}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_doctor!.specialty} • ${_doctor!.city}',
                      style: const TextStyle(
                          color: Color(0xFFb3d1ff), fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    // Stats
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          _stat(
                              _doctor!.rating.toStringAsFixed(1), 'Note'),
                          _divider(),
                          _stat(
                              '${_doctor!.reviewsCount}', 'Avis'),
                          _divider(),
                          _stat(
                              '${_doctor!.price.toInt()} TND', 'Tarif'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info adresse
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.place_outlined,
                              color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _doctor!.address,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary),
                              ),
                              Text(
                                _doctor!.city,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section créneaux
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Créneaux disponibles',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Pas de créneaux
                  if (slots.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Column(
                        children: [
                          Text('📅', style: TextStyle(fontSize: 36)),
                          SizedBox(height: 10),
                          Text(
                            'Aucun créneau disponible pour le moment',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    // Liste des dates
                    ...slots.map((day) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bouton date
                            GestureDetector(
                              onTap: () => setState(() {
                                _selectedDate = day['date'];
                                _selectedSlot = null;
                              }),
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedDate == day['date']
                                      ? AppTheme.primaryLight
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedDate == day['date']
                                        ? AppTheme.primary
                                        : AppTheme.border,
                                    width: _selectedDate == day['date']
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: _selectedDate == day['date']
                                          ? AppTheme.primary
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      day['date'],
                                      style: TextStyle(
                                        color:
                                            _selectedDate == day['date']
                                                ? AppTheme.primary
                                                : AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${(day['slots'] as List).length} créneaux',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            _selectedDate == day['date']
                                                ? AppTheme.primary
                                                : AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _selectedDate == day['date']
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 18,
                                      color:
                                          _selectedDate == day['date']
                                              ? AppTheme.primary
                                              : AppTheme.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Créneaux horaires
                            if (_selectedDate == day['date'])
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: (day['slots'] as List)
                                      .map<Widget>((slot) => GestureDetector(
                                            onTap: () => setState(
                                                () => _selectedSlot = slot),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: _selectedSlot == slot
                                                    ? AppTheme.primary
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color:
                                                      _selectedSlot == slot
                                                          ? AppTheme.primary
                                                          : AppTheme.border,
                                                  width:
                                                      _selectedSlot == slot
                                                          ? 2
                                                          : 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 13,
                                                    color:
                                                        _selectedSlot == slot
                                                            ? Colors.white
                                                            : AppTheme
                                                                .textSecondary,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    slot,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          _selectedSlot ==
                                                                  slot
                                                              ? Colors.white
                                                              : AppTheme
                                                                  .textPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                          ],
                        )),

                  const SizedBox(height: 16),

                  // Résumé sélection
                  if (_selectedDate != null && _selectedSlot != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppTheme.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            '$_selectedDate à $_selectedSlot',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                  // Bouton réserver
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: slots.isEmpty
                            ? null
                            : AppTheme.gradient,
                        color: slots.isEmpty
                            ? Colors.grey[300]
                            : null,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: (slots.isEmpty || _booking)
                            ? null
                            : _book,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _booking
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'Réserver ce créneau',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),

                  // Section avis
                  if (_reviews.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: AppTheme.gradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Avis patients',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ..._reviews.take(3).map((r) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryLight,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            r.patientName
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: AppTheme.primary,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        r.patientName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  StarRating(rating: r.rating, size: 16),
                                ],
                              ),
                              if (r.comment != null &&
                                  r.comment!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  r.comment!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.5),
                                ),
                              ],
                            ],
                          ),
                        )),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFFb3d1ff), fontSize: 11)),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1,
        height: 30,
        color: Colors.white.withValues(alpha: 0.3),
      );
}