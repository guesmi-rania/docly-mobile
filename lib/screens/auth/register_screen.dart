import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _role = 'patient';
  bool _loading = false;
  String _selectedSpecialty = '';
  bool _showSpecialties = false;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _price = TextEditingController();

  final List<String> _specialties = [
    'Généraliste','Cardiologue','Dermatologue','Dentiste',
    'Gynécologue','Neurologue','Ophtalmologue','Orthopédiste',
    'Pédiatre','Psychiatre','Radiologue','Urologue',
  ];

  Future<void> _register() async {
    if (_name.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty || _phone.text.isEmpty) {
      _showError('Remplis tous les champs obligatoires');
      return;
    }
    if (_role == 'doctor' && (_selectedSpecialty.isEmpty || _city.text.isEmpty || _address.text.isEmpty || _price.text.isEmpty)) {
      _showError('Remplis toutes les informations médecin');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().register({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'password': _password.text,
        'role': _role,
        if (_role == 'doctor') ...{
          'specialty': _selectedSpecialty,
          'city': _city.text.trim(),
          'address': _address.text.trim(),
          'price': double.tryParse(_price.text) ?? 0,
        },
      });
    } catch (e) {
      _showError('Inscription échouée. Email déjà utilisé ?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.danger),
    );
  }

  Widget _input(String label, TextEditingController ctrl, {TextInputType? keyboard, bool secure = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          obscureText: secure,
          decoration: InputDecoration(hintText: hint ?? label),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 24),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Text('🏥', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 6),
                  const Text('Créer un compte', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Docly', style: TextStyle(color: Color(0xFFb3d1ff), fontSize: 13)),
                  const SizedBox(height: 16),
                  // Choix rôle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(child: _roleBtn('patient', '🧑', 'Patient')),
                        const SizedBox(width: 12),
                        Expanded(child: _roleBtn('doctor', '👨‍⚕️', 'Médecin')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informations personnelles', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 16),
                  _input('Nom complet *', _name, hint: 'Ex: Rania Guesmi'),
                  _input('Email *', _email, keyboard: TextInputType.emailAddress, hint: 'votre@email.com'),
                  _input('Téléphone *', _phone, keyboard: TextInputType.phone, hint: 'Ex: 55 123 456'),
                  _input('Mot de passe *', _password, secure: true, hint: 'Min. 6 caractères'),
                  if (_role == 'doctor') ...[
                    const Text('Informations médicales', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 16),
                    // Spécialité dropdown
                    const Text('Spécialité *', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() => _showSpecialties = !_showSpecialties),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFdddddd)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedSpecialty.isEmpty ? 'Choisir une spécialité' : _selectedSpecialty,
                                style: TextStyle(color: _selectedSpecialty.isEmpty ? Colors.grey : AppTheme.textPrimary)),
                            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    if (_showSpecialties)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFdddddd)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: _specialties.map((s) => GestureDetector(
                            onTap: () => setState(() { _selectedSpecialty = s; _showSpecialties = false; }),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFf0f0f0)))),
                              child: Text(s, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                            ),
                          )).toList(),
                        ),
                      ),
                    const SizedBox(height: 14),
                    _input('Ville *', _city, hint: 'Ex: Tunis, Sfax...'),
                    _input('Adresse du cabinet *', _address, hint: 'Ex: Rue de la liberté, Tunis'),
                    _input('Tarif consultation (TND) *', _price, keyboard: TextInputType.number, hint: 'Ex: 60'),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Créer mon compte'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Déjà un compte ? ',
                          style: TextStyle(color: AppTheme.textSecondary),
                          children: [TextSpan(text: 'Se connecter', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBtn(String role, String icon, String label) {
    final active = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? Colors.white : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 13, color: active ? AppTheme.primary : Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}