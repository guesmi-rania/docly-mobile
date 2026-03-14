import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/doctor.dart';
import '../../widgets/doctor_card.dart';
import 'doctor_list_screen.dart';
import 'doctor_detail_screen.dart';

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
      setState(() {
        _doctors = data.map((d) => Doctor.fromJson(d)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
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
          const _AppointmentsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Médecins'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Mes RDV'),
        ],
      ),
    );
  }

  Widget _buildHome(String name) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour 👋', style: const TextStyle(color: Color(0xFFb3d1ff), fontSize: 13)),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _tabIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
                        SizedBox(width: 8),
                        Text('Rechercher un médecin...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
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
                const Text('Spécialités', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1),
                  itemCount: _specialties.length,
                  itemBuilder: (_, i) {
                    final s = _specialties[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _tabIndex = 1);
                      },
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s['icon']!, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 6),
                            Text(s['name']!, style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text('Médecins disponibles', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 14),
                if (_loading) const Center(child: CircularProgressIndicator()),
                if (!_loading && _doctors.isEmpty)
                  const Center(child: Text('Aucun médecin disponible', style: TextStyle(color: AppTheme.textSecondary))),
                ..._doctors.take(5).map((d) => DoctorCard(
                  doctor: d,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctorId: d.id))),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Mes rendez-vous'));
  }
}