import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/highlight.dart';
import '../repositories/book_repository.dart';
import 'pdf_viewer_screen.dart';
import 'package:pdfrx/pdfrx.dart';

class BookHighlightsScreen extends StatefulWidget {
  final Book book;
  const BookHighlightsScreen({super.key, required this.book});

  @override
  State<BookHighlightsScreen> createState() => _BookHighlightsScreenState();
}

class _BookHighlightsScreenState extends State<BookHighlightsScreen> {
  final BookRepository _repository = BookRepository.instance;
  List<Highlight> _highlights = [];
  PdfPageView? _firstPage;

  @override
  void initState() {
    super.initState();
    _loadHighlights();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    if (widget.book.filePath.isEmpty) return;
    final doc = await PdfDocument.openFile(widget.book.filePath);
    final first = PdfPageView(document: doc, pageNumber: 1);
    setState(() {
      _firstPage = first;
    });
    // doc.dispose();
  }

  Future<void> _loadHighlights() async {
    final items = await _repository.getHighlightsForBook(widget.book);
    setState(() {
      _highlights = items;
    });
    // print(items.);
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

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade300,
            ),
            alignment: Alignment.center,
            child:
                _firstPage ??
                Text(
                  widget.book.coverTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.black54),
                ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.book.author,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
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
            child: ListView.builder(
              itemCount: _highlights.length,
              itemBuilder: (context, index) {
                final h = _highlights[index];
                return _HighlightTile(
                  highlight: h,
                  onOpen: () => _openHighlight(h),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightTile extends StatefulWidget {
  final Highlight highlight;
  final VoidCallback onOpen;

  const _HighlightTile({required this.highlight, required this.onOpen});

  @override
  State<_HighlightTile> createState() => _HighlightTileState();
}

class _HighlightTileState extends State<_HighlightTile> {
  bool _expanded = false;

  String _transformHighlight(String text) {
    return text.replaceAll('\r', '').replaceAll('\n', ' ');
  }



  @override
  Widget build(BuildContext context) {
    final h = widget.highlight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: _expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onOpen,
                  child: Text(
                    _transformHighlight(h.highlightText),
                    textAlign: TextAlign.justify,
                    maxLines: _expanded ? null : 1,
                    overflow:
                        _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(
                  size: 30,
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Page ${h.pageNumber}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        if (_expanded && h.notes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  h.notes
                      .map(
                        (n) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Text('\u2022 '),
                            Expanded(
                              child: Text(
                                n,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, thickness: 0.5),
        ),
      ],
    );
  }
}
