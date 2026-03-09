import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_keys.dart';
import '../utils/app_logger.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      // gemini-1.5-flash: rápido, eficiente y disponible en la API pública.
      // Alternativa más potente: 'gemini-1.5-pro'
      model: 'gemini-2.5-flash',
      apiKey: ApiKeys.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 800,
      ),
    );
    AppLogger.i('GeminiService inicializado');
  }

  Future<String> analizarAfirmacion(String texto) async {
    AppLogger.i('Enviando a Gemini: "$texto"');

    final prompt = '''
Eres un experto en verificación de noticias. Analiza la siguiente afirmación y proporciona un análisis COMPLETO.

Afirmación: "$texto"

IMPORTANTE: Si la afirmación es sobre un evento RECIENTE (últimos días/semanas), utiliza la búsqueda en internet para obtener información actualizada.

Debes responder EXACTAMENTE con este formato:

VERACIDAD: [VERDADERO/FALSO/ENGAÑOSO/NO VERIFICABLE]
EXPLICACIÓN: [explicación detallada de por qué, incluyendo contexto]
EVIDENCIA: [qué tipo de evidencia o fuentes respaldan tu análisis]
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        return 'No se pudo generar un análisis. Intenta de nuevo.';
      }

      AppLogger.i('Respuesta de Gemini recibida (${response.text!.length} chars)');
      return response.text!;
    } on GenerativeAIException catch (e) {
      AppLogger.e('Error de Gemini API', error: e);
      final msg = e.message.toLowerCase();
      if (msg.contains('api key')) {
        return 'Error: API key de Gemini inválida. Verifica tu archivo .env.';
      } else if (msg.contains('quota')) {
        return 'Límite de uso de Gemini alcanzado. Intenta más tarde.';
      } else if (msg.contains('not found')) {
        return 'Error: Modelo de IA no disponible. Contacta al administrador.';
      }
      return 'Error al analizar con IA: ${e.message}';
    } catch (e) {
      AppLogger.e('Error inesperado en Gemini', error: e);
      return 'Error inesperado al contactar la IA. Intenta de nuevo.';
    }
  }
}