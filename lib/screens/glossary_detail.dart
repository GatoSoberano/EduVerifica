import 'package:flutter/material.dart';

class GlossaryDetail extends StatelessWidget {
  final Map item;

  const GlossaryDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final example = item['example']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(item['term'] ?? 'Término')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['term'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              item['definition'] ?? '',
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
            if (example.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Ejemplo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(example, style: const TextStyle(fontSize: 14, height: 1.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}