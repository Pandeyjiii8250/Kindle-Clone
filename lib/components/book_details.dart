import 'package:flutter/material.dart';

import '../models/book.dart';

class BookDetails extends StatelessWidget {
  final Book book;

  const BookDetails({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(book.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),

        Text(book.author, style: Theme.of(context).textTheme.bodySmall),

        if (!book.lastPageRead.isNaN) ...[
          const SizedBox(height: 8),
          Text(
            '${((book.lastPageRead / book.ttlPage) * 100).toStringAsFixed(0)}% completed',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],

      ],
    );
  }
}
