import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';
import '../screens/book_highlights_screen.dart';
import '../screens/edit_book_screen.dart';

class BookPopupMenu extends StatelessWidget {
  final Book book;

  const BookPopupMenu({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditBookScreen(book: book)),
            );
            break;
          case 'highlights':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookHighlightsScreen(book: book),
              ),
            );
            break;
          case 'delete':
            context.read<BookProvider>().deleteBook(book);
            break;
        }
      },
      itemBuilder:
          (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit details')),
            PopupMenuItem(value: 'highlights', child: Text('Show highlights')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
    );
  }
}
