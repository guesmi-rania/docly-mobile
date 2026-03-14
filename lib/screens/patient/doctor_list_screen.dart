import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/doctor_card.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final String? initialSpecialty;
  const DoctorListScreen({super.key, this.initialSpecialty});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  List<Doctor> _doctors = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSpecialty != null) {
      _searchController.text = widget.initialSpecialty!;
    }
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getDoctors(specialty: _searchController.text.trim());
      setState(() { _doctors = data.map((d) => Doctor.fromJson(d)).toList(); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Médecins'), backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Spécialité ou ville...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                suffixIcon: IconButton(icon: const Icon(Icons.tune), onPressed: _fetch),
              ),
              onSubmitted: (_) => _fetch(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _doctors.isEmpty
                    ? const Center(child: Text('Aucun médecin trouvé', style: TextStyle(color: AppTheme.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _fetch,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _doctors.length,
                          itemBuilder: (_, i) => DoctorCard(
                            doctor: _doctors[i],
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctorId: _doctors[i].id))),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}