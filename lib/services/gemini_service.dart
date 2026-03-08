import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_keys.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService() {
    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiKeys.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 800,
        ),
    
        
      );
      print('✅ GeminiService inicializado con búsqueda en internet');
    } catch (e) {
      print('❌ Error inicializando Gemini: $e');
      rethrow;
    }
  }

  Future<String> analizarAfirmacion(String texto) async {
    try {
      print('🤖 Enviando a Gemini: "$texto"');
      
      final prompt = '''
Eres un experto en verificación de noticias. Analiza la siguiente afirmación y proporciona un análisis COMPLETO.

Afirmación: "$texto"

IMPORTANTE: Si la afirmación es sobre un evento RECIENTE (últimos días/semanas), utiliza la búsqueda en internet para obtener información actualizada.

Debes responder EXACTAMENTE con este formato:

VERACIDAD: [VERDADERO/FALSO/ENGAÑOSO/NO VERIFICABLE]
EXPLICACIÓN: [explicación detallada de por qué, incluyendo contexto y SI USASTE BÚSQUEDA, menciónalo]
EVIDENCIA: [qué tipo de evidencia o fuentes respaldan tu análisis]

Ejemplo de respuesta para evento reciente:
VERACIDAD: VERDADERO
EXPLICACIÓN: Según los resultados de búsqueda de BBC y CNN, el accidente del avión Hércules C-130 en El Alto, Bolivia, ocurrió el 27 de febrero de 2026, confirmado por las autoridades.
EVIDENCIA: Búsqueda en Google News, informes de BBC y CNN.

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