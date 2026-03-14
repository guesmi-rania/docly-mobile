class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? json['_id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    role: json['role'] ?? 'patient',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
  };

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';
}