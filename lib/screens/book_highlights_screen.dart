import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/components/book_cover_image.dart';
import 'package:kindle_clone_v2/components/book_details.dart';

import '../components/highlight_tile.dart';
import '../models/book.dart';
import '../models/highlight.dart';
import '../providers/highlight_provider.dart';
import 'pdf_viewer_screen.dart';
import 'package:provider/provider.dart';

class BookHighlightsScreen extends StatefulWidget {
  final Book book;
  const BookHighlightsScreen({super.key, required this.book});

  @override
  State<BookHighlightsScreen> createState() => _BookHighlightsScreenState();
}

class _BookHighlightsScreenState extends State<BookHighlightsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HighlightProvider>().loadHighlights(widget.book);
    });
  }

  Future<void> _openHighlight(Highlight h) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PDFViewerScreen(
              bookDetail: widget.book,
              initialPage: h.pageNumber,
            ),
      ),
    );
    if (context.mounted) {
      await context.read<HighlightProvider>().loadHighlights(widget.book);
    }
  }

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCoverImage(book: widget.book),
          const SizedBox(width: 16),
          Expanded(child: BookDetails(book: widget.book)),
        ],
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
      body: Column(
        children: [
          _buildBookInfo(),
          // const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: Consumer<HighlightProvider>(
              builder: (context, provider, _) {
                final highlights = provider.highlightsFor(widget.book);
                return ListView.builder(
                  itemCount: highlights.length,
                  itemBuilder: (context, index) {
                    final h = highlights[index];
                    return HighlightTile(
                      highlight: h,
                      onOpen: () => _openHighlight(h),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
