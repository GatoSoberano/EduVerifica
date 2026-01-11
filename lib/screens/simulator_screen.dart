// CORREGIDO en simulator_screen.dart - CON SCROLL
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});
  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final SupabaseService supa = SupabaseService();
  List<Map<String, dynamic>> sims = [];
  bool loading = true;
  int current = 0;
  Map<String, dynamic>? selected;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSimulations();
  }

  void _loadSimulations() async {
    try {
      final List<Map<String, dynamic>> simulationsData = await supa.fetchSimulations();
      setState(() {
        sims = simulationsData;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar simulaciones: $e';
        loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseOptions(dynamic optionsData) {
    try {
      if (optionsData is List) {
        return List<Map<String, dynamic>>.from(optionsData);
      } else if (optionsData is String) {
        final parsed = json.decode(optionsData) as List;
        return List<Map<String, dynamic>>.from(parsed);
      }
    } catch (e) {
      print('Error parsing options: $e');
    }
    return [];
  }

  void _submitAnswer() async {
    if (sims.isEmpty || selected == null) return;
    
    final sim = sims[current];
    final bool isCorrect = selected!['id'] == sim['correct_id'];
    
    try {
      final user = supa.supabase.auth.currentUser;
      if (user != null) {
        await supa.insertSimulationAttempt({
          'user_id': user.id,
          'simulation_id': sim['id'],
          'selected_option_id': selected!['id'],
          'is_correct': isCorrect,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      final snackBar = SnackBar(
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
              Text(sim['explanation']!),
            ],
          ],
        ),
        duration: const Duration(seconds: 4),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        selected = null;
        if (current < sims.length - 1) {
          current++;
        } else {
          current = 0;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
            Text(error!),
            ElevatedButton(
              onPressed: _loadSimulations,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (sims.isEmpty) {
      return const Center(
        child: Text('No hay simulaciones disponibles.'),
      );
    }

    final sim = sims[current];
    final options = _parseOptions(sim['options']);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // ✅ ENVOLVER EN SCROLL
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
                  Text(
                    '${current + 1}/${sims.length}',
                    style: const TextStyle(color: Colors.grey),
                  ),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...options.map((option) {
                        final String optionId = option['id']?.toString() ?? '';
                        final String optionText = option['text'] ?? option['texto'] ?? 'Opción no disponible';
                        final bool isSelected = selected != null && selected!['id'] == optionId;

                        return Card(
                          elevation: isSelected ? 2 : 0,
                          color: isSelected 
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : null,
                          child: ListTile(
                            leading: Radio<String>(
                              value: optionId,
                              groupValue: selected?['id'],
                              onChanged: (value) {
                                setState(() {
                                  selected = {'id': value!, 'text': optionText};
                                });
                              },
                            ),
                            title: Text(optionText),
                            onTap: () {
                              setState(() {
                                selected = {'id': optionId, 'text': optionText};
                              });
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: selected == null ? null : _submitAnswer,
                            child: const Text('Enviar respuesta'),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selected = null;
                                current = (current + 1) % sims.length;
                              });
                            },
                            child: const Text('Saltar pregunta'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Espacio adicional al final para mejor scroll
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}