import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/book.dart';
import 'package:kindle_clone_v2/screens/pdf_viewer_screen.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import 'providers/book_provider.dart';
import 'screens/edit_book_screen.dart';
import 'screens/book_highlights_screen.dart';

class BookRow extends StatefulWidget {
  final Book book;

  const BookRow({super.key, required this.book});

  @override
  State<BookRow> createState() => _BookRowState();
}

class _BookRowState extends State<BookRow> {
  PdfPageView? _firstPage;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    final doc = await PdfDocument.openFile(widget.book.filePath);
    final firstPage = PdfPageView(document: doc, pageNumber: 1);
    setState(() {
      _firstPage = firstPage;
    });
    //TODO: Understand how and when to dispose?
    doc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder "cover" box; swap for an actual image if you prefer
            Container(
              width: 48,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade300,
              ),
              alignment: Alignment.center,
              child:
                  _firstPage ?? Text(
                        widget.book.coverTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.black54),
                      ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.book.filePath.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PDFViewerScreen(bookDetail: widget.book),
                      ),
                    );
                    // OpenFilex.open(book.filePath);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No PDF available for this book'),
                      ),
                    );
                  }
                },
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
                    if (!widget.book.lastPageRead.isNaN) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${((widget.book.lastPageRead / widget.book.ttlPage) * 100).toStringAsFixed(0)}% completed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditBookScreen(book: widget.book),
                      ),
                    );
                    break;
                  case 'highlights':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookHighlightsScreen(book: widget.book),
                      ),
                    );
                    break;
                  case 'delete':
                    context.read<BookProvider>().deleteBook(widget.book);
                    break;
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit details')),
                    PopupMenuItem(
                      value: 'highlights',
                      child: Text('Show highlights'),
                    ),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, thickness: 0.5),
        ),
      ],
    );
  }
}
