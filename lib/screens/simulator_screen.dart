import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  late final SupabaseService _supa;

  List<Map<String, dynamic>> _sims = [];
  bool _loading = true;
  int _current = 0;
  Map<String, dynamic>? _selected;
  String? _error;

  @override
  void initState() {
    super.initState();
    _supa = SupabaseService();
    _loadSimulations();
  }

  Future<void> _loadSimulations() async {
    try {
      final data = await _supa.fetchSimulations();
      setState(() {
        _sims = data;
        _loading = false;
      });
    } catch (e) {
      AppLogger.e('Error al cargar simulaciones', error: e);
      setState(() {
        _error = 'Error al cargar simulaciones. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseOptions(dynamic optionsData) {
    try {
      if (optionsData is List) return List<Map<String, dynamic>>.from(optionsData);
      if (optionsData is String) {
        return List<Map<String, dynamic>>.from(json.decode(optionsData) as List);
      }
    } catch (e) {
      AppLogger.e('Error al parsear opciones', error: e);
    }
    return [];
  }

  Future<void> _submitAnswer() async {
    if (_sims.isEmpty || _selected == null) return;

    final sim = _sims[_current];
    final bool isCorrect = _selected!['id'] == sim['correct_id'];

    try {
      final user = _supa.supabase.auth.currentUser;
      if (user != null) {
        await _supa.insertSimulationAttempt({
          'user_id': user.id,
          'simulation_id': sim['id'],
          'selected_option_id': _selected!['id'],
          'is_correct': isCorrect,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCorrect ? '¡Correcto! 🎉' : 'Incorrecto 😔',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
              if (sim['explanation'] != null) ...[
                const SizedBox(height: 4),
                Text(sim['explanation'].toString()),
              ],
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      setState(() {
        _selected = null;
        _current = (_current < _sims.length - 1) ? _current + 1 : 0;
      });
    } catch (e) {
      AppLogger.e('Error al guardar intento', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar respuesta: $e')),
      );
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
              onPressed: _loadSimulations,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_sims.isEmpty) {
      return const Center(child: Text('No hay simulaciones disponibles.'));
    }

    final sim = _sims[_current];
    final options = _parseOptions(sim['options']);

    // No se usa Scaffold aquí porque SimulatorScreen vive dentro del
    // Scaffold de HomeScreen. Un Scaffold anidado causaría doble AppBar.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Simulador',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text('${_current + 1}/${_sims.length}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sim['question'] ?? 'Pregunta no disponible',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ...options.map((option) {
                      final String optionId = option['id']?.toString() ?? '';
                      final String optionText =
                          option['text'] ?? option['texto'] ?? 'Opción no disponible';
                      final bool isSelected =
                          _selected != null && _selected!['id'] == optionId;

                      return Card(
                        elevation: isSelected ? 2 : 0,
                        color: isSelected
                            ? Theme.of(context).primaryColor.withAlpha(25)
                            : null,
                        child: ListTile(
                          leading: Radio<String>(
                            value: optionId,
                            groupValue: _selected?['id'],
                            onChanged: (value) {
                              setState(() => _selected = {'id': value!, 'text': optionText});
                            },
                          ),
                          title: Text(optionText),
                          onTap: () {
                            setState(() => _selected = {'id': optionId, 'text': optionText});
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selected == null ? null : _submitAnswer,
                          child: const Text('Enviar respuesta'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selected = null;
                              _current = (_current + 1) % _sims.length;
                            });
                          },
                          child: const Text('Saltar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}