import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final SupabaseService _supabaseService;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.\w{2,}$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _supabaseService = SupabaseService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Las contraseñas no coinciden.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _nameController.text.trim();

      AppLogger.i('Registrando usuario: $email');

      final authResponse = await _supabaseService.signUp(email, password);

      if (authResponse.user == null) throw Exception('No se pudo crear el usuario.');

      AppLogger.i('Usuario creado: ${authResponse.user!.id}');

      try {
        await _supabaseService.createOrUpdateProfile({
          'id': authResponse.user!.id,
          'username': username,
          'full_name': username,
          'level': 1,
          'experience': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (profileError) {
        // El perfil puede crearse después. No bloqueamos el flujo.
        AppLogger.w('No se pudo crear el perfil ahora: $profileError');
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      AppLogger.e('Error al registrar', error: e);
      _showError(_parseErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseErrorMessage(dynamic error) {
    final msg = error.toString();
    if (msg.contains('User already registered')) return 'Este email ya está registrado.';
    if (msg.contains('Password should be at least')) return 'La contraseña debe tener al menos 6 caracteres.';
    if (msg.contains('Invalid email')) return 'El formato del email no es válido.';
    if (msg.contains('network') || msg.contains('Socket')) return 'Error de conexión. Verifica tu internet.';
    return 'Error al registrarse. Intenta de nuevo.';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text(
                  'Crear Nueva Cuenta',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa tus datos para empezar a aprender',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),

                const SizedBox(height: 32),

                // Nombre de usuario
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.person),
                    hintText: 'ej: ana_garcia',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingresa tu nombre.';
                    if (value.trim().length < 3) return 'El nombre debe tener al menos 3 caracteres.';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'ej: usuario@ejemplo.com',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingresa tu email.';
                    if (!_emailRegex.hasMatch(value.trim())) return 'Ingresa un email válido.';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    hintText: 'Mínimo 6 caracteres',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingresa una contraseña.';
                    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirmar contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor confirma tu contraseña.';
                    if (value != _passwordController.text) return 'Las contraseñas no coinciden.';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Botón registrar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: Colors.blue[700], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Seguridad de tu cuenta',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Tu información personal está protegida\n'
                        '• Usamos encriptación de última generación\n'
                        '• Nunca compartimos tus datos con terceros',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}