import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/book.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerScreen extends StatefulWidget {
  final Book bookDetail; // Can also be a URL

  PDFViewerScreen({required this.bookDetail});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookDetail.title),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              _pdfViewerController.jumpToPage(1);
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(
        File(widget.bookDetail.filePath),
        controller: _pdfViewerController,
        enableTextSelection: true,
        canShowScrollStatus: true,
        canShowPaginationDialog: true,
      ),
    );
  }
}
