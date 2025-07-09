import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'dart:ui' as ui;

import '../models/book.dart';

class BookCoverImage extends StatefulWidget {
  final Book book;

  const BookCoverImage({super.key, required this.book});

  @override
  State<BookCoverImage> createState() => _BookCoverImageState();
}

class _BookCoverImageState extends State<BookCoverImage> {
  Image? _coverImage;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  @override
  void didUpdateWidget(covariant BookCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book.id != widget.book.id) {
      _loadFirstPage();
    }
  }

  Future<void> _loadFirstPage() async {
    final doc = await PdfDocument.openFile(widget.book.filePath);
    final imgPdf = await doc.pages.first.render();

    final pdfImage = await imgPdf?.createImage();
    final byteData = await pdfImage?.toByteData(format: ui.ImageByteFormat.png);

    final bytes = byteData!.buffer.asUint8List();
    setState(() {
      //Think about potentially storing this to avoid
      //loading each pdf page again and again.
      _coverImage = Image.memory(bytes);
    });

    // Closing document to free up the resources
    // consumed by opening complete pdf.
    doc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 72,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      alignment: Alignment.center,
      child:
          _coverImage ??
          Text(
            widget.book.coverTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.black54),
          ),
    );
  }
}
