class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String city;
  final double price;
  final String date;
  final String time;
  final String status; 

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.city,
    required this.price,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] ?? {};
    return Appointment(
      id:         json['_id']?.toString() ?? '',
      doctorId:   doctor['_id']?.toString() ?? '',
      doctorName: doctor['name']?.toString() ?? 'Médecin',
      specialty:  doctor['specialty']?.toString() ?? '',
      city:       doctor['city']?.toString() ?? '',
      price:      (doctor['price'] ?? 0).toDouble(),
      date:       json['date']?.toString() ?? '',
      time:       json['time']?.toString() ?? '',
      status:     json['status']?.toString() ?? 'pending', 
    );
  }
}