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
  String _currentSelection = '';

  Widget _contextMenuBuilder(
      BuildContext context, SelectableRegionState selectableRegionState) {
    final List<ContextMenuButtonItem> items = [
      ...selectableRegionState.contextMenuButtonItems,
      ContextMenuButtonItem(
        label: 'Highlight',
        onPressed: () {
          debugPrint('Highlighted text: $_currentSelection');
          selectableRegionState.hideToolbar();
        },
      ),
    ];

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: selectableRegionState.contextMenuAnchors,
      buttonItems: items,
    );
  }

  void _onTextSelectionChange(List<PdfTextRanges> selections) {
    if (selections.isEmpty) {
      _currentSelection = '';
      return;
    }
    final buffer = StringBuffer();
    for (final range in selections) {
      buffer.write(range.text);
      debugPrint('Selected on page ${range.pageNumber}: ${range.text}');
    }
    _currentSelection = buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookDetail.title)),
      body: PdfViewer.file(
        widget.bookDetail.filePath,
        params: PdfViewerParams(
          enableTextSelection: true,
          selectableRegionInjector: (context, child) => SelectionArea(
            contextMenuBuilder: _contextMenuBuilder,
            child: child,
          ),
          onTextSelectionChange: _onTextSelectionChange,
        ),
      ),
    );
  }
}
