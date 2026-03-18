import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/doctor.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'doctor_detail_screen.dart';

class DoctorsMapScreen extends StatefulWidget {
  const DoctorsMapScreen({super.key});

  @override
  State<DoctorsMapScreen> createState() => _DoctorsMapScreenState();
}

class _DoctorsMapScreenState extends State<DoctorsMapScreen> {
  List<Doctor> _doctors = [];
  bool _loading = true;
  Doctor? _selectedDoctor;
  Position? _position;

  static const Map<String, List<double>> _cityCoords = {
    'Tunis':    [36.8065, 10.1815],
    'Sfax':     [34.7406, 10.7603],
    'Sousse':   [35.8256, 10.6369],
    'Nabeul':   [36.4561, 10.7376],
    'Bizerte':  [37.2744,  9.8739],
    'Monastir': [35.7643, 10.8113],
    'Ariana':   [36.8625, 10.1956],
    'Gabès':    [33.8881, 10.0975],
    'Gafsa':    [34.4311,  8.7757],
  };

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) setState(() => _position = pos);
      }
    } catch (_) {}
  }

  Future<void> _loadDoctors() async {
    try {
      final data = await ApiService.getDoctors();
      if (!mounted) return;
      setState(() {
        _doctors = data.map((d) => Doctor.fromJson(d)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<double> _coordsFor(Doctor doc, int index) {
    final c = _cityCoords[doc.city];
    if (c != null) {
      return [c[0] + (index % 5) * 0.005, c[1] + (index ~/ 5) * 0.005];
    }
    return [36.8065 + index * 0.01, 10.1815 + index * 0.01];
  }

  String _shortSpecialty(String s) =>
      s.replaceAll('Médecin ', '').replaceAll('médecin ', '').trim();

  String _displayName(String name) =>
      name.toLowerCase().startsWith('dr') ? name : 'Dr. $name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Médecins proches (${_doctors.length})',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.gradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                // ── Carte visuelle ───────────────────────────────
                Container(
                  height: 220,
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    color: Color(0xFFdceefb),
                  ),
                  child: Stack(
                    children: [
                      // Fond carte
                      CustomPaint(
                        size: Size.infinite,
                        painter: _MapBgPainter(),
                      ),

                      // Pins médecins
                      ..._doctors.take(12).toList().asMap().entries.map((e) {
                        final coords = _coordsFor(e.value, e.key);
                        const baseY = 36.8065;
                        const baseX = 10.1815;
                        const scale = 2800.0;
                        final sx = 160 + (coords[1] - baseX) * scale;
                        final sy = 110 - (coords[0] - baseY) * scale;
                        final isSelected = _selectedDoctor?.id == e.value.id;

                        return Positioned(
                          left: sx.clamp(8.0, 340.0),
                          top: sy.clamp(8.0, 180.0),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDoctor = e.value),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.2),
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('👨‍⚕️',
                                          style: TextStyle(fontSize: 14)),
                                      if (isSelected) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          e.value.name.split(' ').first,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 6,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Point position utilisateur
                      if (_position != null)
                        Positioned(
                          left: 160,
                          top: 110,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a73e8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                        ),

                      // Badge villes
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🇹🇳 Tunisie',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      // Légende
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1a73e8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('Vous',
                                  style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Liste médecins ───────────────────────────────
                Expanded(
                  child: _doctors.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🏥',
                                  style: TextStyle(fontSize: 50)),
                              SizedBox(height: 16),
                              Text('Aucun médecin trouvé',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _doctors.length,
                          itemBuilder: (_, i) {
                            final doc = _doctors[i];
                            final isSelected =
                                _selectedDoctor?.id == doc.id;

                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDoctor = doc),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryLight
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: const Center(
                                          child: Text('👨‍⚕️',
                                              style: TextStyle(
                                                  fontSize: 24))),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _displayName(doc.name),
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w700,
                                                fontSize: 14),
                                          ),
                                          Text(
                                            _shortSpecialty(
                                                doc.specialty),
                                            style: const TextStyle(
                                                color: AppTheme.primary,
                                                fontSize: 12),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.place_outlined,
                                                  size: 12,
                                                  color: AppTheme
                                                      .textSecondary),
                                              const SizedBox(width: 2),
                                              Text(doc.city,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppTheme
                                                          .textSecondary)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color:
                                                    Color(0xFFf9a825),
                                                size: 14),
                                            Text(
                                              doc.rating
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${doc.price.toInt()} TND',
                                          style: const TextStyle(
                                              color: AppTheme.success,
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // ── Bouton réserver médecin sélectionné ─────────
                if (_selectedDoctor != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(top: BorderSide(color: AppTheme.border)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        )
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailScreen(
                                doctorId: _selectedDoctor!.id),
                          ),
                        ),
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          'Réserver — ${_displayName(_selectedDoctor!.name)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _MapBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = const Color(0xFFdceefb);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.color = Colors.white;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.45), paint);
    canvas.drawLine(Offset(size.width * 0.35, 0),
        Offset(size.width * 0.38, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.65, 0),
        Offset(size.width * 0.68, size.height), paint);

    paint.strokeWidth = 1.5;
paint.color = Colors.white.withValues(alpha: 0.6);
    canvas.drawLine(Offset(0, size.height * 0.25),
        Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.75),
        Offset(size.width, size.height * 0.7), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}