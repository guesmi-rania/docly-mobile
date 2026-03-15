import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
static const String baseUrl = 'https://docly-backend.onrender.com/api';

  static Dio get _dio {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));

    return dio;
  }

  // AUTH
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return res.data;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await _dio.post('/auth/register', data: data);
    return res.data;
  }

  // DOCTORS
  static Future<List<dynamic>> getDoctors({String? specialty, String? city}) async {
   final res = await _dio.get('/doctors', queryParameters: {
  'specialty': specialty,
  'city': city,
}..removeWhere((_, v) => v == null));
    return res.data;
  }

  static Future<Map<String, dynamic>> getDoctorById(String id) async {
    final res = await _dio.get('/doctors/$id');
    return res.data;
  }

static Future<Map<String, dynamic>> getMySlots() async {
  final res = await _dio.get('/doctors/my-slots');
  return res.data;
}

  static Future<void> updateSlots(List<Map<String, dynamic>> slots) async {
    await _dio.put('/doctors/slots', data: {'availableSlots': slots});
  }

  // APPOINTMENTS
  static Future<Map<String, dynamic>> createAppointment(
      String doctorId, String date, String time, {String? notes}) async {
 final res = await _dio.post('/appointments', data: {
  'doctorId': doctorId,
  'date': date,
  'time': time,
  'notes': notes,
}..removeWhere((_, v) => v == null));
    return res.data;
  }

  static Future<List<dynamic>> getMyAppointments() async {
    final res = await _dio.get('/appointments/my');
    return res.data;
  }

  static Future<List<dynamic>> getDoctorAppointments() async {
    final res = await _dio.get('/appointments/doctor');
    return res.data;
  }

  static Future<void> updateAppointmentStatus(String id, String status) async {
    await _dio.patch('/appointments/$id/status', data: {'status': status});
  }

  static Future<void> completeAppointment(String id) async {
    await _dio.patch('/appointments/$id/complete');
  }

  // REVIEWS
  static Future<void> createReview(
      String doctorId, String appointmentId, int rating, {String? comment}) async {
   await _dio.post('/reviews', data: {
  'doctorId': doctorId,
  'appointmentId': appointmentId,
  'rating': rating,
  'comment': comment,
}..removeWhere((_, v) => v == null));
  }

  static Future<Map<String, dynamic>> getDoctorReviews(String doctorId) async {
    final res = await _dio.get('/reviews/doctor/$doctorId');
    return res.data;
  }
}