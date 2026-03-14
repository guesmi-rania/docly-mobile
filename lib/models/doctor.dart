class Doctor {
  final String id;
  final String specialty;
  final String city;
  final String address;
  final double price;
  final double rating;
  final int reviewsCount;
  final String? photo;
  final String? bio;
  final Map<String, dynamic>? user;
  final List<dynamic> availableSlots;

  Doctor({
    required this.id,
    required this.specialty,
    required this.city,
    required this.address,
    required this.price,
    this.rating = 0,
    this.reviewsCount = 0,
    this.photo,
    this.bio,
    this.user,
    this.availableSlots = const [],
  });

  String get name => user?['name'] ?? 'Médecin';
  String get email => user?['email'] ?? '';
  String get phone => user?['phone'] ?? '';

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['_id'] ?? '',
    specialty: json['specialty'] ?? '',
    city: json['city'] ?? '',
    address: json['address'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    rating: (json['rating'] ?? 0).toDouble(),
    reviewsCount: json['reviewsCount'] ?? 0,
    photo: json['photo'],
    bio: json['bio'],
    user: json['user'],
    availableSlots: json['availableSlots'] ?? [],
  );
}