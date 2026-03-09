import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

class VerifiedSourcesScreen extends StatefulWidget {
  const VerifiedSourcesScreen({super.key});

  @override
  State<VerifiedSourcesScreen> createState() => _VerifiedSourcesScreenState();
}

class _VerifiedSourcesScreenState extends State<VerifiedSourcesScreen> {
  late final SupabaseService _supa;
  List<Map<String, dynamic>> _sources = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _supa = SupabaseService();
    _loadSources();
  }

  Future<void> _loadSources() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _supa.fetchVerifiedSources();
      setState(() {
        _sources = data;
        _loading = false;
      });
    } catch (e) {
      AppLogger.e('Error al cargar fuentes verificadas', error: e);
      setState(() {
        _error = 'Error al cargar fuentes. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir: $url')),
      );
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Verificación': return Colors.green;
      case 'Científico': return Colors.blue;
      case 'Oficial': return Colors.orange;
      case 'Internacional': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Verificación': return Icons.fact_check;
      case 'Científico': return Icons.science;
      case 'Oficial': return Icons.verified_user;
      case 'Internacional': return Icons.public;
      default: return Icons.source;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSources,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Banner informativo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fuentes Verificadas',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    Text(
                      'Consulta estas fuentes confiables para verificar información.',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _sources.length,
            itemBuilder: (context, index) {
              final source = _sources[index];
              final color = _getCategoryColor(source['category']);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getCategoryIcon(source['category']), color: color),
                  ),
                  title: Text(
                    source['name'] ?? 'Sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        source['description'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Chip(
                            label: Text(source['category'] ?? 'General'),
                            backgroundColor: color.withAlpha(25),
                            labelStyle: TextStyle(color: color, fontSize: 11),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          ),
                          const Spacer(),
                          _buildCredibilityStars(source['credibility_score'] ?? 5),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
                  onTap: () => _openUrl(source['url'] ?? ''),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCredibilityStars(int score) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(Icons.star, size: 16, color: i < score ? Colors.amber : Colors.grey[300]),
      ),
    );
  }
}