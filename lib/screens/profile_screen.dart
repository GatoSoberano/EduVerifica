import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import '../utils/app_logger.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final SupabaseService _supa;
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _supa = SupabaseService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _supa.supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Usuario no autenticado';
          _loading = false;
        });
        return;
      }

      final profileData = await _supa.getProfile(user.id);
      setState(() {
        _profile = profileData;
        _loading = false;
      });
    } catch (e) {
      AppLogger.e('Error al cargar perfil', error: e);
      setState(() {
        _error = 'Error al cargar el perfil. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _supa.signOut();
      if (!mounted) return;
      // Navegar al login y limpiar toda la pila de navegación
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      AppLogger.e('Error al cerrar sesión', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final username = (_profile?['username'] ?? 'U').toString();
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _profile?['full_name'] ?? 'Usuario',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _profile?['email'] ?? '',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text('Nivel ${_profile?['level'] ?? 1}'),
            backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
            labelStyle: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}