import 'package:flutter/material.dart';

class LessonDetail extends StatelessWidget {
  final Map lesson;
  const LessonDetail({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson['title'] ?? 'Lección')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lesson['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(lesson['content'] ?? ''),
            if ((lesson['video_url'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('Video de apoyo', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              const SizedBox(height: 10),
              Text(lesson['video_url'])
            ]
          ]),
        ),
      ),
    );
  }
}
