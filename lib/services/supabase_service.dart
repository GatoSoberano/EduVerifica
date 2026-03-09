import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // ─── Autenticación ────────────────────────────────────────────────────────

  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ─── Datos educativos ─────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchLessons() async {
    final response = await supabase.from('lessons').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchGlossary() async {
    final response = await supabase.from('glossary').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchSimulations() async {
    final response = await supabase.from('simulations').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // ─── Fuentes y noticias ───────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchVerifiedSources() async {
    final response = await supabase
        .from('verified_sources')
        .select()
        .eq('is_active', true)
        .order('category');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchVerifiedNews() async {
    final response = await supabase
        .from('verified_news')
        .select()
        .eq('is_active', true)
        .order('publication_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // ─── Perfil de usuario ────────────────────────────────────────────────────

  /// Crea o actualiza el perfil. Usa upsert con la clave primaria 'id'.
  Future<void> createOrUpdateProfile(Map<String, dynamic> profile) async {
    AppLogger.i('Gestionando perfil para id: ${profile['id']}');
    await supabase.from('profiles').upsert(profile, onConflict: 'id');
    AppLogger.i('Perfil gestionado exitosamente');
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> insertSimulationAttempt(Map<String, dynamic> attempt) async {
    await supabase.from('simulation_attempts').insert(attempt);
  }
}

