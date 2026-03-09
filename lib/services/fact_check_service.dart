import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../utils/app_logger.dart';

class FactCheckService {
  static const String _baseUrl =
      'https://factchecktools.googleapis.com/v1alpha1/claims:search';
  static const Duration _timeout = Duration(seconds: 15);

  Future<List<Map<String, dynamic>>> searchClaims({
    required String query,
    String? languageCode,
    int maxResults = 10,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'key': ApiKeys.googleFactCheckApiKey,
      'query': query,
      if (languageCode != null) 'languageCode': languageCode,
      'pageSize': maxResults.toString(),
    });

    AppLogger.i('Consultando Fact Check API para: "$query"');

    final response = await http.get(uri).timeout(
      _timeout,
      onTimeout: () => throw TimeoutException(
        'La consulta tardó demasiado. Verifica tu conexión.',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> claims = data['claims'] ?? [];
      AppLogger.i('Encontradas ${claims.length} verificaciones');
      return claims.map((claim) => _parseClaim(claim)).toList();
    }

    final errorData = json.decode(response.body);
    final errorMessage =
        errorData['error']?['message'] ?? 'Error desconocido (${response.statusCode})';
    throw Exception(errorMessage);
  }

  Map<String, dynamic> _parseClaim(dynamic claim) {
    try {
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
        'text': claim['text'] ?? 'No disponible',
        'claimant': claim['claimant'] ?? 'Desconocido',
        'claimDate': claim['claimDate'] ?? '',
        'review': reviewData,
      };
    } catch (e) {
      AppLogger.e('Error parseando claim', error: e);
      return {
        'text': 'Error al procesar afirmación',
        'claimant': 'Desconocido',
        'claimDate': '',
        'review': null,
      };
    }
  }
}