import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'doctor_detail_screen.dart';
import 'review_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with AutomaticKeepAliveClientMixin {

  List<Appointment> _all = [];
  bool _loading = true;
  String _filter = 'Tous';

  final _tabs = ['Tous', 'En attente', 'Confirmés', 'Terminés', 'Annulés'];
  final _filterMap = {
    'Tous': null,
    'En attente': 'pending',
    'Confirmés': 'confirmed',
    'Terminés': 'completed',
    'Annulés': 'cancelled'
  };

  @override
  bool get wantKeepAlive => false; // ← recharge à chaque fois

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await ApiService.getMyAppointments();
      if (!mounted) return;
      setState(() {
        _all = data.map((a) => Appointment.fromJson(a)).toList();
        // Trier par date la plus récente
        _all.sort((a, b) => b.date.compareTo(a.date));
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur appointments: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Appointment> get _filtered {
    final f = _filterMap[_filter];
    if (f == null) return _all;
    return _all.where((a) => a.status == f).toList();
  }

  Future<void> _cancel(String id) async {
    try {
      await ApiService.updateAppointmentStatus(id, 'cancelled');
      _fetch();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Rendez-vous annulé'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur annulation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: BoxDecoration(gradient: AppTheme.gradient),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes rendez-vous',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_all.length} RDV',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Tabs filtre
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _tabs.map((t) => GestureDetector(
                  onTap: () => setState(() => _filter = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _filter == t
                          ? AppTheme.primary
                          : AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _filter == t
                            ? AppTheme.primary
                            : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                          fontSize: 13,
                          color: _filter == t
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight: _filter == t
                              ? FontWeight.w600
                              : FontWeight.normal),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          // Liste
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary))
                : _filtered.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        onRefresh: _fetch,
                        color: AppTheme.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final a = _filtered[i];
                            return _buildCard(a);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Appointment a) {
    final statusInfo = _getStatus(a.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a73e8).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Header carte
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('👨‍⚕️',
                        style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${a.doctorName}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary),
                      ),
                      Text(
                        a.specialty,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusInfo['bg'] as Color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusInfo['label'] as String,
                    style: TextStyle(
                        fontSize: 11,
                        color: statusInfo['color'] as Color,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Infos RDV
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _info(Icons.calendar_today_outlined, a.date),
                Container(
                    width: 1, height: 24, color: AppTheme.border),
                _info(Icons.access_time_outlined, a.time),
                Container(
                    width: 1, height: 24, color: AppTheme.border),
                _info(Icons.place_outlined, a.city),
                Container(
                    width: 1, height: 24, color: AppTheme.border),
                _info(Icons.payments_outlined,
                    '${a.price.toInt()} TND'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                // Voir médecin
                Expanded(
                  child: _actionBtn(
                    'Voir médecin',
                    AppTheme.primary,
                    AppTheme.primaryLight,
                    Icons.person_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailScreen(
                            doctorId: a.doctorId),
                      ),
                    ),
                  ),
                ),
                // Annuler
                if (a.status == 'pending' || a.status == 'confirmed') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionBtn(
                      'Annuler',
                      AppTheme.danger,
                      const Color(0xFFfdecea),
                      Icons.cancel_outlined,
                      () => _showCancelDialog(a.id),
                    ),
                  ),
                ],
                // Laisser un avis
                if (a.status == 'completed') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionBtn(
                      'Avis ⭐',
                      const Color(0xFFf57f17),
                      const Color(0xFFfffde7),
                      Icons.star_outline,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewScreen(
                            doctorId: a.doctorId,
                            appointmentId: a.id,
                            doctorName: a.doctorName,
                          ),
                        ),
                      ).then((_) => _fetch()),
                    ),
                  ),
                ],
                // Reprendre RDV si annulé
                if (a.status == 'cancelled') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionBtn(
                      'Reprendre',
                      AppTheme.primary,
                      AppTheme.primaryLight,
                      Icons.refresh,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorDetailScreen(
                              doctorId: a.doctorId),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Annuler le rendez-vous ?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancel(id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('Aucun rendez-vous',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(
              _filter == 'Tous'
                  ? 'Réservez votre premier rendez-vous'
                  : 'Aucun rendez-vous $_filter',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (_filter == 'Tous')
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search),
                label: const Text('Trouver un médecin'),
              ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _fetch,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Actualiser'),
            ),
          ],
        ),
      );

  Widget _info(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500)),
        ],
      );

  Widget _actionBtn(String label, Color color, Color bg,
      IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );

  Map<String, dynamic> _getStatus(String status) {
    switch (status) {
      case 'confirmed':
        return {
          'label': 'Confirmé',
          'color': AppTheme.success,
          'bg': const Color(0xFFe8f5e9)
        };
      case 'completed':
        return {
          'label': 'Terminé',
          'color': AppTheme.primary,
          'bg': AppTheme.primaryLight
        };
      case 'cancelled':
        return {
          'label': 'Annulé',
          'color': AppTheme.danger,
          'bg': const Color(0xFFfdecea)
        };
      default:
        return {
          'label': 'En attente',
          'color': AppTheme.warning,
          'bg': const Color(0xFFfffde7)
        };
    }
  }
}