// CORREGIDO en education_screen.dart - VERSIÓN MEJORADA
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'lesson_detail.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});
  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final SupabaseService supa = SupabaseService();
  List<Map<String, dynamic>> lessons = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  void _fetchLessons() async {
    try {
      final List<Map<String, dynamic>> lessonsData = await supa.fetchLessons();
      setState(() {
        lessons = lessonsData;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar lecciones: $e';
        loading = false;
      });
    }
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, int index) {
    final hasVideo = (lesson['video_url'] ?? '').toString().isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getLessonColor(index).withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getLessonIcon(index),
            color: _getLessonColor(index),
          ),
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
              _truncateContent(lesson['content']),
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
          MaterialPageRoute(builder: (_) => LessonDetail(lesson: lesson))
        ),
      ),
    );
  }

  Color _getLessonColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  IconData _getLessonIcon(int index) {
    final icons = [
      Icons.article,
      Icons.tips_and_updates,
      Icons.security,
      Icons.analytics,
      Icons.work_history, // Corregido: reemplazado case_study por work_history
    ];
    return icons[index % icons.length];
  }

  String _truncateContent(String? content) {
    if (content == null) return '';
    return content.length > 80 ? '${content.substring(0, 80)}...' : content;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
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
              onPressed: _fetchLessons,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No hay lecciones disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
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
                Theme.of(context).primaryColor.withAlpha((255 * 0.8).round()),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${lessons.length} lecciones disponibles',
                      style: TextStyle(
                        color: Colors.white.withAlpha((255 * 0.9).round()),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de lecciones
        Expanded(
          child: ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              return _buildLessonCard(lessons[index], index);
            },
          ),
        ),
      ],
    );
  }
}