import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/doctor.dart';
import '../../widgets/doctor_card.dart';
import '../../screens/auth/login_screen.dart';
import 'doctor_list_screen.dart';
import 'doctor_detail_screen.dart';
import 'appointments_screen.dart';
import 'map_screen.dart';
import 'symptom_checker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Doctor> _doctors = [];
  bool _loading = true;
  int _tabIndex = 0;

  final List<Map<String, String>> _specialties = [
    {'icon': '🦷', 'name': 'Dentiste'},
    {'icon': '👁', 'name': 'Ophtalmologue'},
    {'icon': '🫀', 'name': 'Cardiologue'},
    {'icon': '🧠', 'name': 'Neurologue'},
    {'icon': '🦴', 'name': 'Orthopédiste'},
    {'icon': '👶', 'name': 'Pédiatre'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final data = await ApiService.getDoctors();
      if (!mounted) return;
      setState(() {
        _doctors = data.map((d) => Doctor.fromJson(d)).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Erreur doctors: $e');
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

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().user;
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _buildHome(user?.name ?? ''),
          const DoctorListScreen(),
          const AppointmentsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Médecins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Mes RDV',
          ),
        ],
      ),
    );
  }

  Widget _buildHome(String name) {
    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(
                top: 60, left: 20, right: 20, bottom: 24),
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
                        const Text('Bonjour 👋',
                            style: TextStyle(
                                color: Color(0xFFb3d1ff), fontSize: 13)),
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    // ← Fix bouton déconnexion
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
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Barre de recherche
                GestureDetector(
                  onTap: () => setState(() => _tabIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search,
                            color: Colors.white70, size: 18),
                        SizedBox(width: 10),
                        Text('Rechercher un médecin...',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Contenu ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Fonctionnalités rapides ──────────────────────────
                const Text('Services',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // IA Symptômes
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SymptomCheckerScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF7b1fa2),
                                Color(0xFF9c27b0)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🤖',
                                  style: TextStyle(fontSize: 28)),
                              SizedBox(height: 8),
                              Text('IA Symptômes',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13)),
                              Text('Trouvez le bon\nspécialiste',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Carte médecins
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoctorsMapScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1565c0),
                                Color(0xFF1a73e8)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🗺️',
                                  style: TextStyle(fontSize: 28)),
                              SizedBox(height: 8),
                              Text('Carte',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13)),
                              Text('Médecins\nproches de vous',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Spécialités ──────────────────────────────────────
                const Text('Spécialités',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: _specialties.length,
                  itemBuilder: (_, i) {
                    final s = _specialties[i];
                    return GestureDetector(
                      onTap: () => setState(() => _tabIndex = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s['icon']!,
                                style:
                                    const TextStyle(fontSize: 28)),
                            const SizedBox(height: 6),
                            Text(s['name']!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── Médecins disponibles ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Médecins disponibles',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                    GestureDetector(
                      onTap: () => setState(() => _tabIndex = 1),
                      child: const Text('Voir tout',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
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
                  ),
                if (!_loading && _doctors.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        const Text('🏥',
                            style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        const Text('Aucun médecin disponible',
                            style: TextStyle(
                                color: AppTheme.textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetchDoctors,
                          child: const Text('Actualiser'),
                        ),
                      ],
                    ),
                  ),
                ..._doctors.take(5).map((d) => DoctorCard(
                      doctor: d,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DoctorDetailScreen(doctorId: d.id),
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}