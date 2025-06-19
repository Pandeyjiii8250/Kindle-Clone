import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/book.dart';
import 'package:pdfrx/pdfrx.dart';

class PDFViewerScreen extends StatefulWidget {
  final Book bookDetail; // Can also be a URL

  PDFViewerScreen({required this.bookDetail});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookDetail.title)),
      body: PdfViewer.file(
        widget.bookDetail.filePath,
        params: const PdfViewerParams(enableTextSelection: true),
      ),
    );
  }
}
