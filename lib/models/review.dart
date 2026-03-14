class Review {
  final String id;
  final int rating;
  final String? comment;
  final Map<String, dynamic>? patient;
  final String createdAt;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    this.patient,
    required this.createdAt,
  });

  String get patientName => patient?['name'] ?? 'Patient';

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['_id'] ?? '',
    rating: json['rating'] ?? 0,
    comment: json['comment'],
    patient: json['patient'],
    createdAt: json['createdAt'] ?? '',
  );
}