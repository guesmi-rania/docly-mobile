// doctor_dashboard.dart — structure de base
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'manage_slots.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});
  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  List _appointments = [];
  bool _loading = true;
  int _tabIndex = 0;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getDoctorAppointments();
      setState(() { _appointments = data; _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().user;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _tabIndex, children: [
        _buildDashboard(user?.name ?? ''),
        const ManageSlots(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Planning'),
        ],
      ),
    );
  }

  Widget _buildDashboard(String name) {
    final total = _appointments.length;
    final pending = _appointments.where((a) => a['status'] == 'pending').length;
    final confirmed = _appointments.where((a) => a['status'] == 'confirmed').length;
    final completed = _appointments.where((a) => a['status'] == 'completed').length;

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Container(
        padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
        decoration: const BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bonjour Dr. $name 👋', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(DateTime.now().toString().split(' ')[0], style: const TextStyle(color: Color(0xFFb3d1ff), fontSize: 12)),
            ]),
            TextButton(onPressed: () => context.read<AuthService>().logout(), child: const Text('Déco.', style: TextStyle(color: Color(0xFFffd0cc)))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _statCard('$total', 'Total', AppTheme.primary, AppTheme.primaryLight),
            const SizedBox(width: 8),
            _statCard('$pending', 'Attente', AppTheme.warning, const Color(0xFFfffde7)),
            const SizedBox(width: 8),
            _statCard('$confirmed', 'Confirmés', AppTheme.success, const Color(0xFFe8f5e9)),
            const SizedBox(width: 8),
            _statCard('$completed', 'Terminés', const Color(0xFF7b1fa2), const Color(0xFFf3e5f5)),
          ]),
        ]),
      )),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _appointments.isEmpty
                ? const Center(child: Text('Aucun rendez-vous', style: TextStyle(color: AppTheme.textSecondary)))
                : Column(children: _appointments.map<Widget>((a) => _apptCard(a)).toList()),
      )),
    ]);
  }

  Widget _statCard(String v, String l, Color c, Color bg) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c)),
      Text(l, style: TextStyle(fontSize: 10, color: c)),
    ]),
  ));

  Widget _apptCard(Map a) {
    final patient = a['patient'];
    final status = a['status'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Text(a['time'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient?['name'] ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('📞 ${patient?['phone'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
          _badge(status),
        ])),
        const Divider(height: 1),
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [
          if (status == 'pending') ...[
            Expanded(child: _btn('✓ Confirmer', AppTheme.success, const Color(0xFFe8f5e9), () => _update(a['_id'], 'confirmed'))),
            const SizedBox(width: 8),
            Expanded(child: _btn('✕ Annuler', AppTheme.danger, const Color(0xFFfdecea), () => _update(a['_id'], 'cancelled'))),
          ],
          if (status == 'confirmed') ...[
            Expanded(child: _btn('✔ Terminer', AppTheme.primary, AppTheme.primaryLight, () => _complete(a['_id']))),
            const SizedBox(width: 8),
            Expanded(child: _btn('✕ Annuler', AppTheme.danger, const Color(0xFFfdecea), () => _update(a['_id'], 'cancelled'))),
          ],
          if (status == 'completed' || status == 'cancelled')
            Expanded(child: Center(child: Text(status == 'completed' ? '✔ Terminé' : '✕ Annulé', style: const TextStyle(color: AppTheme.textSecondary)))),
        ])),
      ]),
    );
  }

  Widget _badge(String status) {
    final map = {'pending': ['En attente', AppTheme.warning, const Color(0xFFfffde7)], 'confirmed': ['Confirmé', AppTheme.success, const Color(0xFFe8f5e9)], 'completed': ['Terminé', AppTheme.primary, AppTheme.primaryLight], 'cancelled': ['Annulé', AppTheme.danger, const Color(0xFFfdecea)]};
    final info = map[status] ?? map['pending']!;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: info[2] as Color, borderRadius: BorderRadius.circular(20)), child: Text(info[0] as String, style: TextStyle(fontSize: 11, color: info[1] as Color, fontWeight: FontWeight.w600)));
  }

  Widget _btn(String label, Color c, Color bg, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w600))));

  Future<void> _update(String id, String status) async { await ApiService.updateAppointmentStatus(id, status); _fetch(); }
  Future<void> _complete(String id) async { await ApiService.completeAppointment(id); _fetch(); }
}