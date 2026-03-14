class Appointment {
  final String id;
  final String date;
  final String time;
  final String status;
  final String? notes;
  final Map<String, dynamic>? doctor;
  final Map<String, dynamic>? patient;

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
    this.doctor,
    this.patient,
  });

  String get doctorName {
    final user = doctor?['user'];
    if (user is Map) return user['name'] ?? 'Médecin';
    return 'Médecin';
  }

  String get specialty => doctor?['specialty'] ?? '';
  String get city => doctor?['city'] ?? '';
  double get price => (doctor?['price'] ?? 0).toDouble();
  String get doctorId => doctor?['_id'] ?? '';

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['_id'] ?? '',
    date: json['date'] ?? '',
    time: json['time'] ?? '',
    status: json['status'] ?? 'pending',
    notes: json['notes'],
    doctor: json['doctor'],
    patient: json['patient'],
  );
}