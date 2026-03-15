import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;
  Position? _position;
  List<Doctor> _doctors = [];
  Set<Marker> _markers = {};
  Doctor? _selectedDoctor;
  bool _loading = true;

  // Coordonnées Tunisie par défaut
  static const LatLng _defaultPosition = LatLng(36.8065, 10.1815);

  // Coordonnées approximatives des villes tunisiennes
  static const Map<String, LatLng> _cityCoords = {
    'Tunis': LatLng(36.8065, 10.1815),
    'Sfax': LatLng(34.7406, 10.7603),
    'Sousse': LatLng(35.8256, 10.6369),
    'Nabeul': LatLng(36.4561, 10.7376),
    'Bizerte': LatLng(37.2744, 9.8739),
    'Monastir': LatLng(35.7643, 10.8113),
    'Gabès': LatLng(33.8881, 10.0975),
    'Ariana': LatLng(36.8625, 10.1956),
    'Gafsa': LatLng(34.4311, 8.7757),
  };

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _loadDoctors();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _position = await Geolocator.getCurrentPosition();
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final data = await ApiService.getDoctors();
      final doctors = data.map((d) => Doctor.fromJson(d)).toList();
      _buildMarkers(doctors);
      if (!mounted) return;
      setState(() {
        _doctors = doctors;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _buildMarkers(List<Doctor> doctors) {
    final markers = <Marker>{};
    for (final doc in doctors) {
      final coords = _cityCoords[doc.city] ??
          _defaultPosition.offset(
            (doctors.indexOf(doc) * 0.01),
          );

      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: coords,
          infoWindow: InfoWindow(
            title: 'Dr. ${doc.name}',
            snippet: '${doc.specialty} • ${doc.price.toInt()} TND',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          onTap: () => setState(() => _selectedDoctor = doc),
        ),
      );
    }
    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _position != null
                  ? LatLng(_position!.latitude, _position!.longitude)
                  : _defaultPosition,
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (c) => _mapController = c,
            onTap: (_) => setState(() => _selectedDoctor = null),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.gradient,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Médecins proches',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_doctors.length} médecins',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading
          if (_loading)
            const Center(child: CircularProgressIndicator()),

          // Bouton ma position
          Positioned(
            right: 16,
            bottom: _selectedDoctor != null ? 200 : 30,
            child: FloatingActionButton.small(
              onPressed: () {
                if (_position != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_position!.latitude, _position!.longitude),
                      14,
                    ),
                  );
                }
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location,
                  color: AppTheme.primary),
            ),
          ),

          // Carte médecin sélectionné
          if (_selectedDoctor != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildDoctorCard(_selectedDoctor!),
            ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doc) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                    child: Text('👨‍⚕️',
                        style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. ${doc.name}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    Text(doc.specialty,
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13)),
                    Text('📍 ${doc.city}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.star,
                      color: Color(0xFFf9a825), size: 16),
                  Text(doc.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12)),
                  Text('${doc.price.toInt()} TND',
                      style: const TextStyle(
                          color: AppTheme.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DoctorDetailScreen(doctorId: doc.id),
                ),
              ),
              child: const Text('Voir & Réserver'),
            ),
          ),
        ],
      ),
    );
  }
}

extension on LatLng {
  LatLng offset(double delta) =>
      LatLng(latitude + delta, longitude + delta);
}