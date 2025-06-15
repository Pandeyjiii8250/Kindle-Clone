import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/book.dart';
import 'package:kindle_clone_v2/screens/pdf_viewer_screen.dart';

class BookRow extends StatelessWidget {
  final Book book;

  const BookRow({super.key, required this.book});

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
              child: Text(
                book.coverTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (book.filePath.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PDFViewerScreen(bookDetail: book),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No PDF available for this book')),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    if (!book.progress.isNaN) ...[
                      const SizedBox(height: 8),
                      Text(
                        book.progress.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: book.progress,
                          minHeight: 4,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (book.highlights.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        book.highlights.length.toString(),
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
