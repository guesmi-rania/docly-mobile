import 'package:flutter/material.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _user;
  bool _loading = true;

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isDoctor => _user?.isDoctor ?? false;

  AuthService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      _user = await StorageService.getUser();
    } catch (e) {
      debugPrint('❌ Erreur loadUser: $e');
      _user = null;
    } finally {
      _loading = false;
      notifyListeners(); // ← IMPORTANT
    }
  }

  Future<void> login(String email, String password) async {
    final data = await ApiService.login(email, password);
    await StorageService.saveToken(data['token']);
    final user = User.fromJson(data['user']);
    await StorageService.saveUser(user);
    _user = user;
    notifyListeners();
  }

  Future<void> register(Map<String, dynamic> formData) async {
    final data = await ApiService.register(formData);
    await StorageService.saveToken(data['token']);
    final user = User.fromJson(data['user']);
    await StorageService.saveUser(user);
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await StorageService.clear();
    _user = null;
    notifyListeners();
  }
}