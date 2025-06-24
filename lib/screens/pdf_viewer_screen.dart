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
  List<Rect> _highlightRects = [];
  List<PdfTextRanges> _selectedRanges = [];

  void _addHighlight(List<Rect> rect) {
    setState(() {
      _highlightRects.addAll(rect);
    });
  }

  Widget _contextMenuBuilder(
    BuildContext context,
    SelectableRegionState selectableRegionState,
    PdfPage page,
    Rect pageRect,
  ) {
    final List<ContextMenuButtonItem> items = [
      ...selectableRegionState.contextMenuButtonItems,
      ContextMenuButtonItem(
        label: 'Highlight',
        onPressed: () {
          debugPrint('Highlighted text: $_currentSelection');
          List<Rect> rect = [];
          for (var range in _selectedRanges) {
            final singleRect = range.bounds.toRect(
              page: page,
              scaledPageSize: pageRect.size,
            );
            rect.add(singleRect);
          }
          _addHighlight(rect);
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
    setState(() {
      _selectedRanges = selections;
    });

    if (selections.isEmpty) {
      _currentSelection = '';
    } else {
      final buffer = StringBuffer();
      for (final range in selections) {
        debugPrint('Selected on page ${range.pageNumber}: ${range.text}');
      }
      _currentSelection = buffer.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookDetail.title)),
      body: PdfViewer.file(
        widget.bookDetail.filePath,
        params: PdfViewerParams(
          enableTextSelection: true,
          perPageSelectableRegionInjector: (context, child, page, pageRect) {
            return Stack(
              children: [
                SelectionArea(
                  contextMenuBuilder:
                      (context, selectableRegionState) => _contextMenuBuilder(
                        context,
                        selectableRegionState,
                        page,
                        pageRect,
                      ),
                  child: child,
                ),
                ..._highlightRects.map(
                  (rect) => Positioned.fromRect(
                    rect: rect,
                    child: Container(color: Colors.yellow.withOpacity(0.4)),
                  ),
                ),
              ],
            );
          },
          onTextSelectionChange: _onTextSelectionChange,
        ),
      ),
    );
  }
}
