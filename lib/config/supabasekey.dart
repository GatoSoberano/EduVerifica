import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Credenciales de Supabase desde variables de entorno.
/// NUNCA escribas las claves directamente aquí.
String get supabaseUrl {
  final url = dotenv.env['SUPABASE_URL'] ?? '';
  assert(url.isNotEmpty, 'SUPABASE_URL no está definida en .env');
  return url;
}

String get supabaseAnonKey {
  final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  assert(key.isNotEmpty, 'SUPABASE_ANON_KEY no está definida en .env');
  return key;
}