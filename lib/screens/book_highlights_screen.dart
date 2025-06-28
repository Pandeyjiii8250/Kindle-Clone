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

  @override
  void initState() {
    super.initState();
    _loadHighlights();
  }

  Future<void> _loadHighlights() async {
    final items = await _repository.getHighlightsForBook(widget.book);
    setState(() {
      _highlights = items;
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
      appBar: AppBar(
        title: Text(
          'Highlights',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ListView.builder(
        itemCount: _highlights.length,
        itemBuilder: (context, index) {
          final h = _highlights[index];
          return ListTile(
            title: Text(
              h.highlightText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              'Page ${h.pageNumber}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            onTap: () => _openHighlight(h),
          );
        },
      ),
    );
  }
}
