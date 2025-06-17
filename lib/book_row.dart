import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/book.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf_render/pdf_render.dart';

class BookRow extends StatefulWidget {
  final Book book;

  const BookRow({super.key, required this.book});

  @override
  State<BookRow> createState() => _BookRowState();
}

class _BookRowState extends State<BookRow> {
  Uint8List? _coverBytes;

  @override
  void initState() {
    super.initState();
    _loadCover();
  }

  Future<void> _loadCover() async {
    if (widget.book.filePath.isEmpty) return;
    try {
      final doc = await PdfDocument.openFile(widget.book.filePath);
      final page = await doc.getPage(1);
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
        format: PdfPageImageFormat.png,
      );
      await page.close();
      await doc.close();
      if (mounted) {
        setState(() {
          _coverBytes = pageImage.bytes;
        });
      }
    } catch (_) {
      // Ignore errors and keep default placeholder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              clipBehavior: Clip.hardEdge,
              child: _coverBytes != null
                  ? Image.memory(
                      _coverBytes!,
                      fit: BoxFit.cover,
                    )
                  : Text(
                      widget.book.coverTitle,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.book.filePath.isNotEmpty) {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => PDFViewerScreen(bookDetail: book),
                    //   ),
                    // );
                    OpenFilex.open(widget.book.filePath);
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.book.author,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    if (!widget.book.progress.isNaN) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.book.progress.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.book.progress,
                          minHeight: 4,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (widget.book.highlights.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.book.highlights.length.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
