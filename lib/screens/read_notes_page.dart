import 'package:flutter/material.dart';
import '../models/highlight.dart';

class ReadNotesPage extends StatelessWidget {
  final Highlight highlight;

  const ReadNotesPage({super.key, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Notes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: highlight.notes.length,
        itemBuilder: (context, index) {
          final note = highlight.notes[index];
          return Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.sticky_note_2_outlined, color: Colors.black),
                  SizedBox(width: 16),
                  Text(note, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              SizedBox(height: 22),
            ],
          );
        },
      ),
    );
  }
}
