import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gemini_service.dart';
import '../services/fact_check_service.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _controller = TextEditingController();
  final FactCheckService _service = FactCheckService();
  final GeminiService _geminiService = GeminiService();
  
  String? _aiAnalysis;
  bool _isAiLoading = false;
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyText() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa un texto para verificar';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isAiLoading = true;
      _errorMessage = null;
      _results = [];
      _aiAnalysis = null;
    });

    try {
      // 1. BUSCAR EN FACT CHECK API (verificaciones reales)
      final results = await _service.searchClaims(
        query: text,
        languageCode: 'es',
      );

      // 2. ANALIZAR CON GEMINI (IA)
      String aiResult = await _geminiService.analizarAfirmacion(text);

      if (!mounted) return;

      setState(() {
        _results = results;
        _aiAnalysis = aiResult;
        _isLoading = false;
        _isAiLoading = false;

        if (results.isEmpty) {
          _errorMessage = 'No hay verificaciones de organizaciones humanas, pero aquí tienes un análisis con IA:';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isAiLoading = false;
        _errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace: $url')),
      );
    }
  }

  Color _getRatingColor(String rating) {
    final ratingLower = rating.toLowerCase();

    if (ratingLower.contains('verdadero') ||
        ratingLower.contains('true') ||
        ratingLower.contains('cierto') ||
        ratingLower.contains('exacto') ||
        ratingLower.contains('correcto') ||
        ratingLower.contains('mayormente cierto')) {
      return Colors.green;
    }

    if (ratingLower.contains('falso') ||
        ratingLower.contains('false') ||
        ratingLower.contains('mentira') ||
        ratingLower.contains('incorrecto') ||
        ratingLower.contains('inexacto')) {
      return Colors.red;
    }

    if (ratingLower.contains('engañoso') ||
        ratingLower.contains('misleading') ||
        ratingLower.contains('clickbait') ||
        ratingLower.contains('no hay evidencia')) {
      return Colors.orange;
    }

    return Colors.grey;
  }

  String _getRatingEmoji(String rating) {
    final ratingLower = rating.toLowerCase();

    if (ratingLower.contains('verdadero') ||
        ratingLower.contains('true') ||
        ratingLower.contains('cierto') ||
        ratingLower.contains('exacto')) {
      return '✅';
    } else if (ratingLower.contains('falso') ||
        ratingLower.contains('false') ||
        ratingLower.contains('mentira')) {
      return '❌';
    } else if (ratingLower.contains('engañoso') ||
        ratingLower.contains('misleading')) {
      return '⚠️';
    } else {
      return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificador Automático'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado explicativo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verificador Automático',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ingresa una frase o afirmación para ver si ya ha sido verificada por organizaciones de fact-checking.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Campo de texto
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Texto a verificar',
                hintText: 'Ej: "Las vacunas causan autismo"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _results = [];
                      _errorMessage = null;
                      _aiAnalysis = null;
                    });
                  },
                ),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _verifyText(),
            ),

            const SizedBox(height: 16),

            // Botón de verificar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _verifyText,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.verified),
                label: Text(_isLoading ? 'Verificando...' : 'Verificar Afirmación'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Mensaje de error si existe
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Resultados de Fact Check
            if (_results.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Se encontraron ${_results.length} verificaciones',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._results.map((result) => _buildResultCard(result)),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // ANÁLISIS DE IA (con scroll independiente)
            if (_isAiLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Analizando con IA...'),
                    ],
                  ),
                ),
              ),
            ] else if (_aiAnalysis != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.blue.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.purple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Análisis con IA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Contenido del análisis - CON SCROLL INDEPENDIENTE
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Text(
                          _aiAnalysis!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Disclaimer
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(178), // 0.7 * 255 = 178
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Este análisis es generado por IA y debe usarse como referencia, no como verificación definitiva.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final review = result['review'];
    final rating = review != null ? review['textualRating'] : 'Sin calificación';
    final ratingColor = _getRatingColor(rating);
    final ratingEmoji = _getRatingEmoji(rating);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Afirmación
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Afirmación:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result['text'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Quién lo dijo (si existe)
            if (result['claimant'].isNotEmpty && result['claimant'] != 'Desconocido') ...[
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Dicho por: ${result['claimant']}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            // Fecha (si existe)
            if (result['claimDate'].isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Fecha: ${result['claimDate']}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Verificación (si existe)
            if (review != null) ...[
              const Divider(),

              // Rating con color y emoji
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ratingColor.withAlpha(26), // 0.1 * 255 ≈ 26
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ratingColor.withAlpha(77)), // 0.3 * 255 ≈ 77
                ),
                child: Row(
                  children: [
                    Text(
                      ratingEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review['textualRating'],
                        style: TextStyle(
                          color: ratingColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Fuente verificadora
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.source, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Verificado por: ${review['publisherName']}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (review['reviewDate'].isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.update, size: 14, color: Colors.blue.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'Revisado: ${review['reviewDate']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (review['title'].isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        review['title'],
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Botón para leer más
              if (review['url'].isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openUrl(review['url']),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Leer verificación completa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],

            // Mensaje si no hay revisión
            if (review == null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No hay información detallada de verificación disponible',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}