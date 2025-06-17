import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/book.dart';
import 'package:kindle_clone_v2/models/highlight.dart';
import 'package:kindle_clone_v2/repositories/book_repository.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdfviewer/src/annotation/annotation.dart';

class PDFViewerScreen extends StatefulWidget {
  final Book bookDetail; // Can also be a URL

  PDFViewerScreen({required this.bookDetail});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late PdfViewerController _pdfViewerController;
  final BookRepository _repository = BookRepository.instance;
  List<Highlight> _highlights = [];

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadAnnotations();
  }

  Future<void> _loadAnnotations() async {
    _highlights = await _repository.getHighlights(widget.bookDetail);
    for (final highlight in _highlights) {
      _addAnnotationToViewer(highlight);
    }
  }

  void _addAnnotationToViewer(Highlight ann) {
    Annotation? annotation;
    if (ann.rects.length >= 4) {
      final Rect rect = Rect.fromLTWH(
        ann.rects[0],
        ann.rects[1],
        ann.rects[2],
        ann.rects[3],
      );
      final PdfTextLine line = PdfTextLine(
        rect,
        ann.highlightText,
        ann.pageNumber,
      );
      if (ann.type == 'HighlightAnnotation') {
        annotation = HighlightAnnotation(textBoundsCollection: [line]);
      } else if (ann.type == 'UnderlineAnnotation') {
        annotation = UnderlineAnnotation(textBoundsCollection: [line]);
      } else if (ann.type == 'StrikethroughAnnotation') {
        annotation = StrikethroughAnnotation(textBoundsCollection: [line]);
      } else if (ann.type == 'SquigglyAnnotation') {
        annotation = SquigglyAnnotation(textBoundsCollection: [line]);
      } else if (ann.type == 'StickyNoteAnnotation') {
        annotation = StickyNoteAnnotation(
          pageNumber: ann.pageNumber,
          text: ann.highlightText,
          position: rect.topLeft,
          icon: PdfStickyNoteIcon.note,
        );
      }
    }
    if (annotation != null) {
      annotation.color = _parseColor(ann.color);
      _pdfViewerController.addAnnotation(annotation);
    }
  }

  Color _parseColor(String value) {
    final buffer = StringBuffer();
    if (value.length == 6 || value.length == 7) buffer.write('ff');
    buffer.write(value.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> _saveAnnotation(Annotation annotation) async {
    final rects = <double>[];
    final Rect r = annotation.boundingBox;
    rects.addAll([r.left, r.top, r.width, r.height]);

    final ann = Highlight()
      ..pageNumber = annotation.pageNumber
      ..type = annotation.runtimeType.toString()
      ..rects = rects
      ..highlightText =
          annotation is StickyNoteAnnotation ? annotation.text : ''
      ..color =
          '#${annotation.color.value.toRadixString(16).padLeft(8, '0')}'
      ..timestamp = DateTime.now();

    await _repository.addHighlight(widget.bookDetail, ann);
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
        onAnnotationAdded: _saveAnnotation,
      ),
    );
  }
}
