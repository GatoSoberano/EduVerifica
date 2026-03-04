import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class FactCheckService {
  static const String _baseUrl = 'https://factchecktools.googleapis.com/v1alpha1/claims:search';
  final String _apiKey = ApiKeys.googleFactCheckApiKey;

  Future<List<Map<String, dynamic>>> searchClaims({
    required String query,
    String? languageCode,
    int maxResults = 10,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'key': _apiKey,
        'query': query,
        if (languageCode != null) 'languageCode': languageCode,
        'pageSize': maxResults.toString(),
      });

      print('🔍 Consultando API...');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> claims = data['claims'] ?? [];
        
        print('✅ Encontradas ${claims.length} verificaciones');
        
        return claims.map((claim) => _parseClaim(claim)).toList();
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Error desconocido';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error al conectar: $e');
    }
  }

  Map<String, dynamic> _parseClaim(dynamic claim) {
    try {
      // Extraer el texto de la afirmación
      String text = claim['text'] ?? 'No disponible';
      
      // Extraer quién hizo la afirmación
      String claimant = claim['claimant'] ?? 'Desconocido';
      
      // Extraer las revisiones (verificaciones)
      final claimReviews = claim['claimReview'] as List? ?? [];
      
      Map<String, dynamic>? reviewData;
      
      if (claimReviews.isNotEmpty) {
        final firstReview = claimReviews.first;
        reviewData = {
          'publisherName': firstReview['publisher']?['name'] ?? 'Desconocido',
          'publisherSite': firstReview['publisher']?['site'] ?? '',
          'reviewDate': firstReview['reviewDate'] ?? '',
          'textualRating': firstReview['textualRating'] ?? 'Sin calificación',
          'title': firstReview['title'] ?? '',
          'url': firstReview['url'] ?? '',
        };
      }
      
      return {
        'text': text,
        'claimant': claimant,
        'claimDate': claim['claimDate'] ?? '',
        'review': reviewData,
      };
    } catch (e) {
      print('❌ Error parseando: $e');
      return {
        'text': 'Error al procesar',
        'claimant': 'Error',
        'claimDate': '',
        'review': null,
      };
    }
  }
}