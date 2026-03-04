// CORREGIDO en supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Métodos de autenticación
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email, 
      password: password
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await supabase.auth.signUp(
      email: email, 
      password: password
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Métodos para datos
  Future<List<Map<String, dynamic>>> fetchLessons() async {
    final response = await supabase.from('lessons').select();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchGlossary() async {
    final response = await supabase.from('glossary').select();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchSimulations() async {
    final response = await supabase.from('simulations').select();
    return response;
  }

  // Método para fuentes verificadas
  Future<List<Map<String, dynamic>>> fetchVerifiedSources() async {
    final response = await supabase
        .from('verified_sources')
        .select()
        .eq('is_active', true)
        .order('category');
    return response;
  }

  // MÉTODO CORREGIDO: Para evitar error de perfil duplicado
  Future<void> createOrUpdateProfile(Map<String, dynamic> profile) async {
    try {
      // Primero intentamos hacer upsert (insert o update)
      await supabase.from('profiles').upsert(profile);
      print('✅ Perfil gestionado exitosamente');
    } catch (e) {
      print('❌ Error en upsert, intentando insert: $e');
      // Si falla el upsert, intentamos insert
      try {
        await supabase.from('profiles').insert(profile);
        print('✅ Perfil insertado exitosamente');
      } catch (insertError) {
        print('❌ Error en insert, intentando update: $insertError');
        // Si el insert falla (porque ya existe), hacemos update
        await supabase
            .from('profiles')
            .update(profile)
            .eq('id', profile['id']);
        print('✅ Perfil actualizado exitosamente');
      }
    }
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

  // Método para noticias verificadas
  Future<List<Map<String, dynamic>>> fetchVerifiedNews() async {
    final response = await supabase
        .from('verified_news')
        .select()
        .eq('is_active', true)
        .order('publication_date', ascending: false);
    return response;
  }
}


