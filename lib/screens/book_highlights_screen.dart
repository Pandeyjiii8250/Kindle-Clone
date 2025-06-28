import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/highlight.dart';
import '../repositories/book_repository.dart';
import 'pdf_viewer_screen.dart';

class BookHighlightsScreen extends StatefulWidget {
  final Book book;
  const BookHighlightsScreen({super.key, required this.book});

  @override
  State<BookHighlightsScreen> createState() => _BookHighlightsScreenState();
}

class _BookHighlightsScreenState extends State<BookHighlightsScreen> {
  final BookRepository _repository = BookRepository.instance;
  List<Highlight> _highlights = [];
  final Map<int?, bool> _showComments = {};

  @override
  void initState() {
    super.initState();
    _loadHighlights();
  }

  Future<void> _loadHighlights() async {
    final items = await _repository.getHighlightsForBook(widget.book);
    setState(() {
      _highlights = items;
      _showComments.clear();
    });
  }

  void _openHighlight(Highlight h) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PDFViewerScreen(
              bookDetail: widget.book,
              initialPage: h.pageNumber,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Highlights')),
      body: ListView.builder(
        itemCount: _highlights.length,
        itemBuilder: (context, index) {
          final h = _highlights[index];
          final show = _showComments[h.id] ?? false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(h.highlightText),
                subtitle: Text('Page ${h.pageNumber}'),
                onTap: () => _openHighlight(h),
                trailing: IconButton(
                  icon: Icon(show ? Icons.comment : Icons.comment_outlined),
                  onPressed: () {
                    setState(() {
                      _showComments[h.id] = !show;
                    });
                  },
                ),
              ),
              if (show)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: h.notes
                        .map((note) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text('- $note'),
                            ))
                        .toList(),
                  ),
                ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }
}
