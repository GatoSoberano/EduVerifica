import 'dart:math';

import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_keys.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService() {
    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash', // Modelo actualizado
        apiKey: ApiKeys.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 800, // Aumentado para respuestas más largas
        ),
      );
      print('✅ GeminiService inicializado con gemini-2.5-flash');
    } catch (e) {
      print('❌ Error inicializando Gemini: $e');
      rethrow;
    }
  }

  Future<String> analizarAfirmacion(String texto) async {
    try {
      print('🤖 Enviando a Gemini: "$texto"');
      
      // PROMPT CORREGIDO - MÁS ESPECÍFICO
      final prompt = '''
Eres un experto en verificación de noticias. Analiza la siguiente afirmación y proporciona un análisis COMPLETO.

Afirmación: "$texto"

Debes responder EXACTAMENTE con este formato:

VERACIDAD: [VERDADERO/FALSO/ENGAÑOSO/NO VERIFICABLE]
EXPLICACIÓN: [explicación detallada de por qué, incluyendo contexto]
EVIDENCIA: [qué tipo de evidencia apoyaría o refutaría esta afirmación]

Ejemplo de respuesta:
VERACIDAD: FALSO
EXPLICACIÓN: Esta afirmación ha sido desmentida por la Organización Mundial de la Salud y múltiples estudios científicos revisados por pares. No existe evidencia científica que respalde esta relación causal.
EVIDENCIA: Estudios epidemiológicos, revisiones sistemáticas, declaraciones de autoridades sanitarias.

Ahora analiza la afirmación proporcionada.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      
      if (response.text == null || response.text!.isEmpty) {
        return 'No se pudo generar un análisis. Intenta de nuevo.';
      }
      
      String respuesta = response.text!;
      print('✅ Respuesta de Gemini recibida (${respuesta.length} caracteres)');
      print('📝 Primeros 100 caracteres: ${respuesta.substring(0, min(100, respuesta.length))}');
      
      return respuesta;
      
    } catch (e) {
      print('❌ Error en Gemini: $e');
      
      if (e.toString().contains('API key')) {
        return 'Error: API key de Gemini inválida. Verifica en Google AI Studio.';
      } else if (e.toString().contains('quota')) {
        return 'Límite de uso de Gemini alcanzado. Intenta más tarde.';
      } else if (e.toString().contains('not found')) {
        return 'Error: Modelo no disponible. Contacta al administrador.';
      } else {
        return 'Error al analizar con IA: ${e.toString()}';
      }
    }
  }
}