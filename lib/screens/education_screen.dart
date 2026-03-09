import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';
import 'lesson_detail.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  late final SupabaseService _supa;
  List<Map<String, dynamic>> _lessons = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _supa = SupabaseService();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _supa.fetchLessons();
      setState(() {
        _lessons = data;
        _loading = false;
      });
    } catch (e) {
      AppLogger.e('Error al cargar lecciones', error: e);
      setState(() {
        _error = 'Error al cargar lecciones. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  Color _getLessonColor(int index) {
    const colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    return colors[index % colors.length];
  }

  IconData _getLessonIcon(int index) {
    const icons = [
      Icons.article,
      Icons.tips_and_updates,
      Icons.security,
      Icons.analytics,
      Icons.work_history,
    ];
    return icons[index % icons.length];
  }

  String _truncate(String? text, {int max = 80}) {
    if (text == null || text.isEmpty) return '';
    return text.length > max ? '${text.substring(0, max)}...' : text;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando lecciones...'),
          ],
        ),
      );
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
              onPressed: _fetchLessons,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No hay lecciones disponibles.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withAlpha(204),
                Theme.of(context).primaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.school, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Módulo Educativo',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${_lessons.length} lecciones disponibles',
                      style: TextStyle(color: Colors.white.withAlpha(230), fontSize: 12),
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
            itemCount: _lessons.length,
            itemBuilder: (context, index) {
              final lesson = _lessons[index];
              final color = _getLessonColor(index);
              final hasVideo = (lesson['video_url'] ?? '').toString().isNotEmpty;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getLessonIcon(index), color: color),
                  ),
                  title: Text(
                    lesson['title'] ?? 'Sin título',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        _truncate(lesson['content']),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (hasVideo) ...[
                            const Icon(Icons.videocam, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            const Text('Incluye video', style: TextStyle(fontSize: 10, color: Colors.green)),
                          ],
                          const Spacer(),
                          const Icon(Icons.schedule, size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          const Text('5 min', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LessonDetail(lesson: lesson)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}