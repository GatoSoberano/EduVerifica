import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gemini_service.dart';
import '../services/fact_check_service.dart';
import '../utils/app_logger.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  // ── Servicios (instanciados una sola vez) ──────────────────────────────────
  late final TextEditingController _controller;
  late final FactCheckService _factCheckService;
  late final GeminiService _geminiService;

  // ── Estado ────────────────────────────────────────────────────────────────
  String? _aiAnalysis;
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _factCheckService = FactCheckService();
    _geminiService = GeminiService();
  }

  @override
  void dispose() {
    _controller.dispose(); // Evitar memory leak
    super.dispose();
  }

  // ── Lógica de verificación ────────────────────────────────────────────────

  Future<void> _verifyText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa un texto para verificar');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = [];
      _aiAnalysis = null;
    });

    try {
      // Llamadas en PARALELO — reduce el tiempo de espera ~50%
      AppLogger.i('Iniciando verificación paralela para: "$text"');
      final responses = await Future.wait([
        _factCheckService.searchClaims(query: text, languageCode: 'es'),
        _geminiService.analizarAfirmacion(text),
      ]);

      if (!mounted) return;

      final results = responses[0] as List<Map<String, dynamic>>;
      final aiResult = responses[1] as String;

      setState(() {
        _results = results;
        _aiAnalysis = aiResult;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage =
              'No hay verificaciones de organizaciones humanas, pero aquí tienes un análisis con IA:';
        }
      });
    } catch (e) {
      AppLogger.e('Error en verificación', error: e);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
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
        SnackBar(content: Text('No se pudo abrir: $url')),
      );
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _results = [];
      _errorMessage = null;
      _aiAnalysis = null;
    });
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────────

  Color _getRatingColor(String rating) {
    final r = rating.toLowerCase();
    if (r.contains('verdadero') || r.contains('true') || r.contains('cierto') ||
        r.contains('exacto') || r.contains('correcto') || r.contains('mayormente cierto')) {
      return Colors.green;
    }
    if (r.contains('falso') || r.contains('false') || r.contains('mentira') ||
        r.contains('incorrecto') || r.contains('inexacto')) {
      return Colors.red;
    }
    if (r.contains('engañoso') || r.contains('misleading') ||
        r.contains('clickbait') || r.contains('no hay evidencia')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  String _getRatingEmoji(String rating) {
    final r = rating.toLowerCase();
    if (r.contains('verdadero') || r.contains('true') || r.contains('cierto') ||
        r.contains('exacto')) {
      return '✅';
    }
    if (r.contains('falso') || r.contains('false') || r.contains('mentira')) return '❌';
    if (r.contains('engañoso') || r.contains('misleading')) return '⚠️';
    return '❓';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  // NOTA: No se usa Scaffold aquí porque esta pantalla ya vive dentro
  // del Scaffold de HomeScreen (via IndexedStack). Agregar otro Scaffold
  // causaría AppBars y barras de estado duplicadas.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 20),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildVerifyButton(),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[_buildErrorBanner(), const SizedBox(height: 16)],
          if (_results.isNotEmpty) ...[
            _buildResultsHeader(),
            const SizedBox(height: 16),
            ..._results.map((r) => _buildResultCard(r)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],
          if (_isLoading) _buildLoadingAI(),
          if (!_isLoading && _aiAnalysis != null) _buildAIAnalysis(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
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
                  'Ingresa una afirmación para verificarla con organizaciones de fact-checking y análisis de IA.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Texto a verificar',
        hintText: 'Ej: "Las vacunas causan autismo"',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearSearch,
          tooltip: 'Limpiar',
        ),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _verifyText(),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _verifyText,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.verified),
        label: Text(_isLoading ? 'Verificando...' : 'Verificar Afirmación'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
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
            child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Se encontraron ${_results.length} verificaciones',
        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLoadingAI() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Analizando con IA...'),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysis() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Análisis con IA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Text(_aiAnalysis!, style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(178),
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
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final review = result['review'];
    final rating = review?['textualRating'] ?? 'Sin calificación';
    final ratingColor = _getRatingColor(rating);
    final ratingEmoji = _getRatingEmoji(rating);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result['text'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (result['claimant'] != 'Desconocido' &&
                (result['claimant'] as String).isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Dicho por: ${result['claimant']}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            if ((result['claimDate'] as String).isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Fecha: ${result['claimDate']}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            if (review != null) ...[
              const Divider(),
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ratingColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ratingColor.withAlpha(77)),
                ),
                child: Row(
                  children: [
                    Text(ratingEmoji, style: const TextStyle(fontSize: 20)),
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
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                    if ((review['reviewDate'] as String).isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.update, size: 14, color: Colors.blue.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'Revisado: ${review['reviewDate']}',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                          ),
                        ],
                      ),
                    ],
                    if ((review['title'] as String).isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        review['title'],
                        style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade800),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if ((review['url'] as String).isNotEmpty)
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
            ] else ...[
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
                        'No hay información detallada de verificación disponible.',
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