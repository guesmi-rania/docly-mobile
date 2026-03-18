import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../screens/auth/login_screen.dart';
import 'manage_slots.dart';
import 'prescription_screen.dart';

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
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await ApiService.getDoctorAppointments();
      if (!mounted) return;
      setState(() {
        _appointments = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur fetch: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ← Fix déconnexion avec navigation
  Future<void> _logout() async {
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  // ← Fix bouton terminer
  Future<void> _complete(String id, String patientName) async {
    try {
      await ApiService.updateAppointmentStatus(id, 'completed');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Consultation terminée ✅'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );

      // Proposer d'écrire une ordonnance
      final doctorName =
          context.read<AuthService>().user?.name ?? 'Médecin';
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Consultation terminée',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
              'Voulez-vous rédiger une ordonnance pour $patientName ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Non',
                  style:
                      TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrescriptionScreen(
                      patientName: patientName,
                      appointmentId: id,
                      doctorName: doctorName,
                      specialty: '',
                    ),
                  ),
                );
              },
              child: const Text('Oui, rédiger'),
            ),
          ],
        ),
      );

      _fetch();
    } catch (e) {
      debugPrint('❌ Erreur complete: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Future<void> _update(String id, String status) async {
    try {
      await ApiService.updateAppointmentStatus(id, status);
      if (!mounted) return;
      _fetch();
    } catch (e) {
      debugPrint('❌ Erreur update: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().user;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _buildDashboard(user?.name ?? ''),
          const ManageSlots(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Planning',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(String name) {
    final today = DateTime.now().toString().split(' ')[0];
    final total = _appointments.length;
    final pending =
        _appointments.where((a) => a['status'] == 'pending').length;
    final confirmed =
        _appointments.where((a) => a['status'] == 'confirmed').length;
    final completed =
        _appointments.where((a) => a['status'] == 'completed').length;

    return RefreshIndicator(
      onRefresh: _fetch,
      color: AppTheme.primary,
      child: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(gradient: AppTheme.gradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour Dr. $name 👋',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            today,
                            style: const TextStyle(
                                color: Color(0xFFb3d1ff),
                                fontSize: 12),
                          ),
                        ],
                      ),
                      // ← Fix déconnexion
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.logout,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Déco.',
                                  style: TextStyle(
                                      color: Color(0xFFffd0cc),
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    children: [
                      _statCard('$total', 'Total', AppTheme.primary,
                          AppTheme.primaryLight),
                      const SizedBox(width: 8),
                      _statCard('$pending', 'Attente',
                          AppTheme.warning, const Color(0xFFfffde7)),
                      const SizedBox(width: 8),
                      _statCard('$confirmed', 'Confirmés',
                          AppTheme.success, const Color(0xFFe8f5e9)),
                      const SizedBox(width: 8),
                      _statCard('$completed', 'Terminés',
                          const Color(0xFF7b1fa2),
                          const Color(0xFFf3e5f5)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Liste RDV ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rendez-vous',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary),
                      ),
                      GestureDetector(
                        onTap: _fetch,
                        child: const Icon(Icons.refresh,
                            color: AppTheme.primary, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: AppTheme.primary),
                      ),
                    )
                  else if (_appointments.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          const Text('📭',
                              style: TextStyle(fontSize: 50)),
                          const SizedBox(height: 16),
                          const Text('Aucun rendez-vous',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                          const SizedBox(height: 8),
                          const Text(
                              'Les réservations apparaîtront ici',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _fetch,
                            icon: const Icon(Icons.refresh,
                                size: 16),
                            label: const Text('Actualiser'),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._appointments
                        .map<Widget>((a) => _apptCard(a))
                        ,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
          String v, String l, Color c, Color bg) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(v,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: c)),
              Text(l,
                  style: TextStyle(fontSize: 10, color: c)),
            ],
          ),
        ),
      );

  Widget _apptCard(Map a) {
    final patient = a['patient'];
    final status = a['status'] ?? 'pending';
    final patientName = patient?['name'] ?? 'Patient';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Info RDV
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        a['date'] ?? '',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        a['time'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '📞 ${patient?['phone'] ?? 'Non renseigné'}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                _badge(status),
              ],
            ),
          ),

          // Actions
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // En attente → Confirmer + Annuler
                if (status == 'pending') ...[
                  Expanded(
                    child: _btn(
                      '✓ Confirmer',
                      AppTheme.success,
                      const Color(0xFFe8f5e9),
                      () => _update(a['_id'], 'confirmed'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _btn(
                      '✕ Annuler',
                      AppTheme.danger,
                      const Color(0xFFfdecea),
                      () => _update(a['_id'], 'cancelled'),
                    ),
                  ),
                ],

                // Confirmé → Terminer + Annuler
                if (status == 'confirmed') ...[
                  Expanded(
                    child: _btn(
                      '✔ Terminer',
                      AppTheme.primary,
                      AppTheme.primaryLight,
                      // ← Fix bouton terminer avec nom patient
                      () => _complete(a['_id'], patientName),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _btn(
                      '✕ Annuler',
                      AppTheme.danger,
                      const Color(0xFFfdecea),
                      () => _update(a['_id'], 'cancelled'),
                    ),
                  ),
                ],

                // Terminé ou Annulé → label
                if (status == 'completed' || status == 'cancelled')
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            status == 'completed'
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: status == 'completed'
                                ? AppTheme.success
                                : AppTheme.danger,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status == 'completed'
                                ? 'Terminé'
                                : 'Annulé',
                            style: TextStyle(
                              color: status == 'completed'
                                  ? AppTheme.success
                                  : AppTheme.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String status) {
    final map = {
      'pending': [
        'En attente',
        AppTheme.warning,
        const Color(0xFFfffde7)
      ],
      'confirmed': [
        'Confirmé',
        AppTheme.success,
        const Color(0xFFe8f5e9)
      ],
      'completed': ['Terminé', AppTheme.primary, AppTheme.primaryLight],
      'cancelled': [
        'Annulé',
        AppTheme.danger,
        const Color(0xFFfdecea)
      ],
    };
    final info = map[status] ?? map['pending']!;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: info[2] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        info[0] as String,
        style: TextStyle(
          fontSize: 11,
          color: info[1] as Color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _btn(
          String label, Color c, Color bg, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: c,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}