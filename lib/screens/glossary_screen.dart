import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';
import 'glossary_detail.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  late final SupabaseService _supa;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _supa = SupabaseService();
    _loadGlossary();
  }

  Future<void> _loadGlossary() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _supa.fetchGlossary();
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      AppLogger.e('Error al cargar glosario', error: e);
      setState(() {
        _error = 'Error al cargar el glosario. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  String _truncate(String? text, {int max = 80}) {
    if (text == null || text.isEmpty) return '';
    return text.length > max ? '${text.substring(0, max)}...' : text;
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
              onPressed: _loadGlossary,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(child: Text('No hay términos en el glosario.'));
    }

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            title: Text(
              item['term'] ?? 'Sin término',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_truncate(item['definition'])),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GlossaryDetail(item: item)),
            ),
          ),
        );
      },
    );
  }
}