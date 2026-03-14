import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/home_screen.dart';
import 'screens/doctor/doctor_dashboard.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const DoclyApp(),
    ),
  );
}

class DoclyApp extends StatelessWidget {
  const DoclyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!auth.isLoggedIn) {
          return LoginScreen();
        }
        if (auth.isDoctor) {
          return const DoctorDashboard();
        }
        return const HomeScreen();
      },
    );
  }
}