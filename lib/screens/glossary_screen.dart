// CORREGIR en glossary_screen.dart
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'glossary_detail.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});
  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final SupabaseService supa = SupabaseService();
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadGlossary();
  }

  void _loadGlossary() async {
    try {
      final List<Map<String, dynamic>> glossaryData = await supa.fetchGlossary();
      setState(() {
        items = glossaryData;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar glosario: $e';
        loading = false;
      });
    }
  }

  String _truncateDefinition(String? definition) {
    if (definition == null) return '';
    return definition.length > 80 ? '${definition.substring(0, 80)}...' : definition;
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
            Text(error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGlossary,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('No hay términos en el glosario.'),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            title: Text(
              item['term'] ?? 'Sin término',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_truncateDefinition(item['definition'])),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GlossaryDetail(item: item),
              ),
            ),
          ),
        );
      },
    );
  }
}