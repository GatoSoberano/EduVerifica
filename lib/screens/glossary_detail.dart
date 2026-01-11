import 'package:flutter/material.dart';

class GlossaryDetail extends StatelessWidget {
  final Map item;
  const GlossaryDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item['term'] ?? 'Término')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['term'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(item['definition'] ?? ''),
          if ((item['example'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('Ejemplo', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            const SizedBox(height: 8),
            Text(item['example'] ?? '')
          ]
        ]),
      ),
    );
  }
}
