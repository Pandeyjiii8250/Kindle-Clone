import 'package:flutter/material.dart';
import '../models/highlight.dart';

class ReadNotesPage extends StatelessWidget {
  final Highlight highlight;

  const ReadNotesPage({super.key, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: highlight.notes.length,
        itemBuilder: (context, index) {
          final note = highlight.notes[index];
          return ListTile(
            leading: const Icon(Icons.note),
            title: Text(note, style: Theme.of(context).textTheme.bodyMedium),
          );
        },
      ),
    );
  }
}
