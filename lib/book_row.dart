import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/book.dart';
import 'package:kindle_clone_v2/screens/pdf_viewer_screen.dart';
import 'components/book_cover_image.dart';
import 'components/book_details.dart';
import 'components/book_popup_menu.dart';

class BookRow extends StatelessWidget {
  final Book book;

  const BookRow({super.key, required this.book});

  void _navigateToPdf(BuildContext context) {
    if (book.filePath.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PDFViewerScreen(bookDetail: book)),
      );
      // OpenFilex.open(book.filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PDF available for this book')),
      );
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
            BookCoverImage(book: book),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _navigateToPdf(context),
                child: BookDetails(book: book),
              ),
            ),
            BookPopupMenu(book: book),
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
