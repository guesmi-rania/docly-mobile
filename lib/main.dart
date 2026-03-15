import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/home_screen.dart';
import 'screens/doctor/doctor_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const DoclyApp(),
    ),
  );
}

class DoclyApp extends StatelessWidget {
  const DoclyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp(
      title: 'Docly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.mode,
      home: const _Splash(),
      routes: {
        '/login': (_) => LoginScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
      },
    );
  }
}

// Splash : vérifie onboarding + auth
class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;

    // Onboarding pas encore vu
    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    // Onboarding vu → vérifier auth
    final auth = context.read<AuthService>();

    // Attendre que AuthService finisse de charger
    if (auth.loading) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return auth.loading;
      });
    }

    if (!mounted) return;

    if (!auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => auth.isDoctor
              ? const DoctorDashboard()
              : const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Docly
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.gradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('🏥', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Docly',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}