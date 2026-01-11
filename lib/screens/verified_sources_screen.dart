// CORREGIDO en verified_sources_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';

class VerifiedSourcesScreen extends StatefulWidget {
  const VerifiedSourcesScreen({super.key});

  @override
  State<VerifiedSourcesScreen> createState() => _VerifiedSourcesScreenState();
}

class _VerifiedSourcesScreenState extends State<VerifiedSourcesScreen> {
  final SupabaseService supa = SupabaseService();
  List<Map<String, dynamic>> sources = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  void _loadSources() async {
    try {
      final List<Map<String, dynamic>> sourcesData = await supa.fetchVerifiedSources();
      setState(() {
        sources = sourcesData;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar fuentes: $e';
        loading = false;
      });
    }
  }

  Widget _buildCredibilityStars(int score) {
    return Row(
      children: List.generate(5, (index) => Icon(
        Icons.star,
        size: 16,
        color: index < score ? Colors.amber : Colors.grey[300],
      )),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color chipColor;
    switch (category) {
      case 'Verificación':
        chipColor = Colors.green;
      case 'Científico':
        chipColor = Colors.blue;
      case 'Oficial':
        chipColor = Colors.orange;
      case 'Internacional':
        chipColor = Colors.purple;
      default:
        chipColor = Colors.grey;
    }
    
    return Chip(
      label: Text(category),
      backgroundColor: chipColor.withAlpha((255 * 0.1).round()),
      labelStyle: TextStyle(color: chipColor, fontSize: 12),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Future<void> _openSourceUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error!, textAlign: TextAlign.center),
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
        // Header informativo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Consulta estas fuentes confiables para verificar información',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de fuentes
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: sources.length,
            itemBuilder: (context, index) {
              final source = sources[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getSourceIcon(source['category']),
                      color: Theme.of(context).primaryColor,
                    ),
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
                          _buildCategoryChip(source['category'] ?? 'General'),
                          const Spacer(),
                          _buildCredibilityStars(source['credibility_score'] ?? 5),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
                  onTap: () => _openSourceUrl(source['url']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getSourceIcon(String category) {
    switch (category) {
      case 'Verificación':
        return Icons.fact_check;
      case 'Científico':
        return Icons.science;
      case 'Oficial':
        return Icons.verified_user;
      case 'Internacional':
        return Icons.public;
      default:
        return Icons.source;
    }
  }
}