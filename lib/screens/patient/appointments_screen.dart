import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/appointment_card.dart';
import 'doctor_detail_screen.dart';
import 'review_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> _all = [];
  bool _loading = true;
  String _filter = 'Tous';
  final _tabs = ['Tous', 'En attente', 'Confirmés', 'Terminés', 'Annulés'];
  final _filterMap = {'Tous': null, 'En attente': 'pending', 'Confirmés': 'confirmed', 'Terminés': 'completed', 'Annulés': 'cancelled'};

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getMyAppointments();
      setState(() { _all = data.map((a) => Appointment.fromJson(a)).toList(); _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  List<Appointment> get _filtered {
    final f = _filterMap[_filter];
    if (f == null) return _all;
    return _all.where((a) => a.status == f).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mes rendez-vous'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [Text('${_all.length} au total  ', style: const TextStyle(color: Color(0xFFb3d1ff), fontSize: 13))],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _tabs.map((t) => GestureDetector(
                  onTap: () => setState(() => _filter = t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _filter == t ? AppTheme.primary : AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 13, color: _filter == t ? Colors.white : AppTheme.textSecondary, fontWeight: _filter == t ? FontWeight.w600 : FontWeight.normal)),
                  ),
                )).toList(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('📭', style: TextStyle(fontSize: 50)),
                        const SizedBox(height: 12),
                        Text('Aucun rendez-vous', style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                      ]))
                    : RefreshIndicator(
                        onRefresh: _fetch,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final a = _filtered[i];
                            return AppointmentCard(
                              appointment: a,
                              onViewDoctor: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctorId: a.doctorId))),
                              onCancel: (a.status == 'pending' || a.status == 'confirmed')
                                  ? () async { await ApiService.updateAppointmentStatus(a.id, 'cancelled'); _fetch(); }
                                  : null,
                              onReview: a.status == 'completed'
                                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewScreen(doctorId: a.doctorId, appointmentId: a.id, doctorName: a.doctorName)))
                                  : null,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}